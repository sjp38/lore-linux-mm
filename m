Subject: Re: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1186604723.5055.47.camel@localhost>
References: <20070727084252.GA9347@wotan.suse.de>
	 <1186604723.5055.47.camel@localhost>
Content-Type: text/plain
Date: Fri, 10 Aug 2007 17:08:18 -0400
Message-Id: <1186780099.5246.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-08 at 16:25 -0400, Lee Schermerhorn wrote:
> On Fri, 2007-07-27 at 10:42 +0200, Nick Piggin wrote:
> > Hi,
> > 
> > Just got a bit of time to take another look at the replicated pagecache
> > patch. The nopage vs invalidate race and clear_page_dirty_for_io fixes
> > gives me more confidence in the locking now; the new ->fault API makes
> > MAP_SHARED write faults much more efficient; and a few bugs were found
> > and fixed.
> > 
> > More stats were added: *repl* in /proc/vmstat. Survives some kbuilding
> > tests...
> > 
> 
> Sending this out to give Nick an update and to give the list a
> heads up on what I've found so far with the replication patch.
> 
> I have rebased Nick's recent pagecache replication patch against
> 2.6.23-rc1-mm2, atop my memory policy and auto/lazy migration
> patch sets.  These include:
> 
> + shared policy
> + migrate-on-fault a.k.a. lazy migration
> + auto-migration - trigger lazy migration on inter-node task
>                    task migration
> + migration cache - pseudo-swap cache for parking unmapped
>                     anon pages awaiting migrate-on-fault
> 
> I added a couple of patches to fix up the interaction of replication
> with migration [discussed more below] and a per cpuset control to
> enable/disable replication.  The latter allowed me to boot successfully
> and to survive any bugs encountered by restricting the effects to 
> tasks in the test cpuset with replication enabled.  That was the
> theory, anyway :-).  Mostly worked...

After I sent out the last update, I ran a usex job mix overnight ~19.5 hours.
When I came in the next morning, the console window was full of soft lockups
on various cpus with varions stack traces.  /var/log/messages showed 142, in
all.

I've placed the soft lockup reports from /var/log/messages in the Replication
directory on free.linux:

	http://free.linux.hp.com/~lts/Patches/Replication.

The lockups appeared in several places in the traces I looked at.  Here's a
couple of examples:

+ unlink_file_vma() from free_pgtables() during task exit:
	mapping->i_mmap_lock ???

+ smp_call_function() from ia64_global_tlb_purge().
	  Maybe the 'call_lock' in arch/ia64/kernel/smp.c ?
  Traces show us getting to here in one of 2 ways:

  1) try_to_unmap* during auto task migration [migrate_pages_unmap_only()...]

  2) from zap_page_range() when __unreplicate_pcache() calls unmap_mapping_range.

+ get_page_from_freelist -> zone_lru_lock?

An interesting point:  all of the soft lockup messages said that the cpu was
locked for 11s.  Ring any bells?


I should note that I was trying to unmap all mappings to the file backed pages
on internode task migration, instead of just the current task's pte's.  However,
I was only attempting this on pages with  mapcount <= 4.  So, I don't think I 
was looping trying to unmap pages with mapcounts of several 10s--such as I see
on some page cache pages in my traces.

Today, after rebasing to 23-rc2-mm2, I added a patch to unmap only the current
task's ptes for ALL !anon pages, regardless of mapcount.  I've started the test
again and will let it run over the weekend--or as long as it stays up, which 
ever is shorter :-).

I put a tarball with the rebased series in the Replication directory linked
above, in case you're interested.  I haven't added the patch description for
the new patch yet, but it's pretty simple.  Maybe even correct.

----

Unrelated to the lockups  [I think]:

I forgot to look before I rebooted, but earlier the previous evening, I checked
the vmstats and at that point [~1.5 hours into the test] we had done ~4.88 million
replications and ~4.8 million "zaps" [collapse of replicated page].  That's around
98% zaps.  Do we need some filter in the fault path to reduce the "thrashing"--if
that's what I'm seeing.  

A while back I took a look at the Virtual Iron page replication patch.  They had
set VM_DENY_WRITE when mapping shared executable segments, and only replicated pages
in those VMAs.  Maybe 'DENY_WRITE isn't exactly what we want.  Possibly set another
flag for shared executables, if we can detect them, and any shared mapping that has
no writable mappings ?

I'll try to remember to check the replication statistics after the currently
running test.  If the system stays up, that is.  A quick look < 10 minutes into
the test shows that zaps are now ~84% of replications.  Also, ~47k replicated pages
out of ~287K file pages.

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
