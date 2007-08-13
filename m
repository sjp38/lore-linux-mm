Subject: Re: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070813074351.GA15609@wotan.suse.de>
References: <20070727084252.GA9347@wotan.suse.de>
	 <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost>
	 <20070813074351.GA15609@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 13 Aug 2007 10:05:01 -0400
Message-Id: <1187013901.5592.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-13 at 09:43 +0200, Nick Piggin wrote:
> On Fri, Aug 10, 2007 at 05:08:18PM -0400, Lee Schermerhorn wrote:
> > On Wed, 2007-08-08 at 16:25 -0400, Lee Schermerhorn wrote:
> > > On Fri, 2007-07-27 at 10:42 +0200, Nick Piggin wrote:
> > > > Hi,
> > > > 
> > > > Just got a bit of time to take another look at the replicated pagecache
> > > > patch. The nopage vs invalidate race and clear_page_dirty_for_io fixes
> > > > gives me more confidence in the locking now; the new ->fault API makes
> > > > MAP_SHARED write faults much more efficient; and a few bugs were found
> > > > and fixed.
> > > > 
> > > > More stats were added: *repl* in /proc/vmstat. Survives some kbuilding
> > > > tests...
> > > > 

<snip>
> 
> Hi Lee,
> 
> Am sick with the flu for the past few days, so I haven't done much more
> work here, but I'll just add some (not very useful) comments....
> 
> The get_page_from_freelist hang is quite strange. It would be zone->lock,
> which shouldn't have too much contention...
> 
> Replication may be putting more stress on some locks. It will cause more
> tlb flushing that can not be batched well, which could cause the call_lock
> to get hotter. Then i_mmap_lock is held over tlb flushing, so it will
> inherit the latency from call_lock. (If this is the case, we could
> potentially extend the tlb flushing API slightly to cope better with
> unmapping of pages from multiple mm's, but that comes way down the track
> when/if replication proves itself!).
> 
> tlb flushing AFAIKS should not do the IPI unless it is deadling with a
> multithreaded mm... does usex use threads?

Yes.  Apparently, there are some tests, perhaps some of the /usr/bin
apps that get run repeatedly, that are multi-threaded.  This job mix
caught a number of races in my auto-migration patches when
multi-threaded tasks race in the page fault paths.

More below...

> 
> 
> > I should note that I was trying to unmap all mappings to the file backed pages
> > on internode task migration, instead of just the current task's pte's.  However,
> > I was only attempting this on pages with  mapcount <= 4.  So, I don't think I 
> > was looping trying to unmap pages with mapcounts of several 10s--such as I see
> > on some page cache pages in my traces.
> 
> Replication teardown would still have to unmap all... but that shouldn't
> particularly be any worse than, say, page reclaim (except I guess that it
> could occur more often).
> 
>  
> > Today, after rebasing to 23-rc2-mm2, I added a patch to unmap only the current
> > task's ptes for ALL !anon pages, regardless of mapcount.  I've started the test
> > again and will let it run over the weekend--or as long as it stays up, which 
> > ever is shorter :-).
> 
> Ah, so it does eventually die? Any hints of why?

No, doesn't die--as in panic.  I was just commenting that I'd leave it
running ...  However [:-(], it DID hang again.  The test window said
that the tests ran for 62h:28m before the screen stopped updating.  In
another window, I was running a script to snap the replication and #
file pages vmstats, along with a timestamp, every 10 minutes.  That
stopped reporting stats at about 7:30am on Saturday--about 14h:30m into
the test.  It still wrote the timestamps [date command] until around 7am
this morning [Monday]--or ~62 hours into test.

So, I do have ~14 hours of replication stats that I can send you or plot
up...

Re: the hang:  again, console was scrolling soft lockups continuously.
Checking the messages file, I see hangs in copy_process(),
smp_call_function [as in prev test], vma_link [from mmap], ...

I also see a number of NaT ["not a thing"] consumptions--ia64 specific
error, probably invalid pointer deref--in swapin_readahead, which my
patches hack.  These might be the cause of the fork/mmap hangs.

Didn't see that in the 8-9Aug runs, so it might be a result of continued
operation after other hangs/problems; or a botch in the rebase to
rc2-mm2.  In any case, I have some work to do there...

> 
> > 
> > I put a tarball with the rebased series in the Replication directory linked
> > above, in case you're interested.  I haven't added the patch description for
> > the new patch yet, but it's pretty simple.  Maybe even correct.
> > 
> > ----
> > 
> > Unrelated to the lockups  [I think]:
> > 
> > I forgot to look before I rebooted, but earlier the previous evening, I checked
> > the vmstats and at that point [~1.5 hours into the test] we had done ~4.88 million
> > replications and ~4.8 million "zaps" [collapse of replicated page].  That's around
> > 98% zaps.  Do we need some filter in the fault path to reduce the "thrashing"--if
> > that's what I'm seeing.  
> 
> Yep. The current replication patch is very much only infrastructure at
> this stage (and is good for stress testing). I feel sure that heuristics
> and perhaps tunables would be needed to make the most of it.

Yeah.  I have some ideas to try...

At the end of the 14.5 hours when it stopped dumping vmstats, we were at
~95% zaps.

> 
> 
> > A while back I took a look at the Virtual Iron page replication patch.  They had
> > set VM_DENY_WRITE when mapping shared executable segments, and only replicated pages
> > in those VMAs.  Maybe 'DENY_WRITE isn't exactly what we want.  Possibly set another
> > flag for shared executables, if we can detect them, and any shared mapping that has
> > no writable mappings ?
> 
> mapping_writably_mapped would be a good one to try. That may be too
> broad in some corner cases where we do want occasionally-written files
> or even parts of files to be replicated, but if we were ever to enable
> CONFIG_REPLICATION by default, I imagine mapping_writably_mapped would
> be the default heuristic.
> 
> Still, I appreciate the testing of the "thrashing" case, because with
> the mapping_writably_mapped heuristic, it is likely that bugs could
> remain lurking even in production workloads on huge systems (because
> they will hardly ever get unreplicated).
> 
>  
> > I'll try to remember to check the replication statistics after the currently
> > running test.  If the system stays up, that is.  A quick look < 10 minutes into
> > the test shows that zaps are now ~84% of replications.  Also, ~47k replicated pages
> > out of ~287K file pages.
> 
> Yeah I guess it can be a little misleading: as time approaches infinity,
> zaps will probably approach replications. But that doesn't tell you how
> long a replica stayed around and usefully fed CPUs with local memory...

May be able to capture that info with a more invasive patch -- e.g., add
a timestamp to the page struct.  I'll think about it.

And, I'll keep you posted.  Not sure how much time I'll be able to
dedicate to this patch stream.  Got a few others I need to get back
to...

Later,
Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
