Subject: Re: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070727084252.GA9347@wotan.suse.de>
References: <20070727084252.GA9347@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 16:25:23 -0400
Message-Id: <1186604723.5055.47.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 10:42 +0200, Nick Piggin wrote:
> Hi,
> 
> Just got a bit of time to take another look at the replicated pagecache
> patch. The nopage vs invalidate race and clear_page_dirty_for_io fixes
> gives me more confidence in the locking now; the new ->fault API makes
> MAP_SHARED write faults much more efficient; and a few bugs were found
> and fixed.
> 
> More stats were added: *repl* in /proc/vmstat. Survives some kbuilding
> tests...
> 

Sending this out to give Nick an update and to give the list a
heads up on what I've found so far with the replication patch.

I have rebased Nick's recent pagecache replication patch against
2.6.23-rc1-mm2, atop my memory policy and auto/lazy migration
patch sets.  These include:

+ shared policy
+ migrate-on-fault a.k.a. lazy migration
+ auto-migration - trigger lazy migration on inter-node task
                   task migration
+ migration cache - pseudo-swap cache for parking unmapped
                    anon pages awaiting migrate-on-fault

I added a couple of patches to fix up the interaction of replication
with migration [discussed more below] and a per cpuset control to
enable/disable replication.  The latter allowed me to boot successfully
and to survive any bugs encountered by restricting the effects to 
tasks in the test cpuset with replication enabled.  That was the
theory, anyway :-).  Mostly worked...

Rather than spam the list, I've placed the entire quilt series that
I'm testing, less the 23-rc1 and 23-rc1-mm2 patches, at:

	http://free.linux.hp.com/~lts/Patches/Replication/

It's the 070808 tarball.

I plan to measure the effects on performance with various combinations
of these features enabled.  First, however, I ran into one problem that
required me to investigate further.  In the migrate-on-fault set, I've
introduced a function named "migrate_page_unmap_only()".  It parallels
Christoph's "migrate_pages()" but for lazy migration, it just removes
the pte mappings from the selected pages so that they will incur a fault
on next touch and be migrated to the node specified by policy, if
necessary and "easy" to do.  [don't want to try too hard, as this is 
just a performance optimization.  supposed to be, anyway.]

In migrate_page_unmap_only(), I had a BUG_ON to catch [non-anon] pages
with a NULL page_mapping().  I never hit this in my testing until I
added in the page replication.  To investigate, I took the opportunity
to update my mmtrace instrumentation.   I added a few trace points for
Nick's replication functions and replaced the BUG_ON with a trace
point and skipped pages w/ a NULL mapping.  The kernel patches are in
the patch tarball at the link above.  The user space tools are available
at:

	http://free.linux.hp.com/~lts/Tools/mmtrace-latest.tar.gz

A rather large tarball containing formatted traces from a usex run
that hit the NULL mapping trace point is also available from the
replication patches directory linked above.  I've extracted traces
related to the "bug check" and annotated them--also in the tarball.
See the README.

So what's happening?

I think I'm hitting a race between the page replication code when it
"unreplicates" a page and a task that references one of the replicas
attempting to unmap that replica for lazy migration.  When "unreplicating"
a page, the replication patch nulls out all of the mappings for the 
"slave pages", without locking the pages or otherwise coordinating with
other possible accesses to the page, and then calls unmap_mapping_range()
to unmap them.  Meanwhile, these pages are still referenced by various tasks'
page tables.  

One interesting thing I see in the traces is that, in the couple of
instances I looked at, the attempt to unmap [migrate_pages_unmap_only()]
came approximately a second after the __unreplicate_pcache() call that
apparently nulled out the mapping.  I.e., the slave page remained
referenced by the task's page table for almost a second after unreplication.
Nick does have a comment about unmap_mapping_range() sleeping, but a
second seems like a long time.

I don't know whether this is a real problem or not.  I removed the 
BUG_ON and now just skip pages with NULL mapping.  They're being removed
anyway.  I'm running a stress test now, and haven't seen any obvious
problems yet.  I do have concerns, tho'.  Page migration assumes that
if it can successfully isolate a page from the LRU and lock it, that it
has pretty much exclusive access.

Direct migration [Christoph's implementation] is a bit stricter regarding
reference and map counts, unless "MOVE_ALL" is specified.  In my lazy
migration patches, I want to be able to unmap pages with multiple pte
references [currently a per cpuset tunable threshold] to test the
performance impact of trying harder to unmap vs being able to migrate
fewer pages.  

I'm also seeing a lot of "thrashing"--pages being repeatedly replicated
and unreplicated on every other fault to the page.  I haven't investigated
how long the intervals are between the faults, so maybe the faulting
tasks are getting a good deal of usage of the page between faults.

Other Considerations

I figured that direct migration should not try to migrate a replicated
page [to a new node] because this would mess up Nick's tracking of
slave pages in the pcache_descriptor.  Don't know what the effects
would be, but I added a test to skip replicated pages in migrate_pages().

I didn't want to filter these pages in migrate_page_add() because I
want to be able to unmap at least the current task's pte references
for lazy migration, so that the task will fault on next touch and
use/create a local replica.  [Patch "under consideration".]  
However, I think that migrate_page_add() is too early, because the
page could become replicated after we check.  In fact, where I've
placed the check in migrate_pages() is too early.  Needs to be 
moved into unmap_and_move() after the page lock is obtained.  Replication
DOES lock the page to replicate it.  We'll need to add some checks
after "try_to_replicate_pcache()" obtains the page lock to ensure
that it hasn't been migrated away.  Or, maybe the checks in 
should_replicate_pcache() already handle this?

One also might want to migrate a page to evacuate memory--either for
hotplug or to consolidate contiguous memory to make more higher order
pages available.  In these cases, we might want to handle replicated
pages by just removing the local replica and using a remote copy.

More as the story unfolds.  Film at 11...

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
