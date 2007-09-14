From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:53:59 -0400
Message-Id: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 0/14] Page Reclaim Scalability
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

As I discussed with some of you in Cambridge:


[PATCH/RFC] 0/14 Page Reclaim Scalability Patches:

The objective of this series of patches is not to make page reclaim
"smarter"--e.g., by improving the heuristics or using a new replacement
algorithm.  Rather, the objective is to make the existing algorithm
more effective by removing from consideration those pages that are 
difficult or impossible to reclaim so that the page reclaim algorithm 
can concentrate on those pages which have a good chance of being 
reclaimed.  This is especially important for servers with large
amounts of memory--in the millions of pages.  Doing this should benefit
any future improvements to the reclaim algorithm itself.

Some of the conditions that make pages difficult or impossible to reclaim:
  1) page is ramdisk page.
  2) page is anon or shmem, but no swap space available
  3) page is mlocked into memory, including SHM_LOCKed shmem pages.
  4) page is anon with an excessive number of related vmas [on the
     anon_vma list]; or is a file-backed page, with an excessive
     number of vmas mapping the page.

Pages that fall in categories 1-3 above remain on the LRU lists,
despite being non-reclaimable.  vmscan can spend a great deal of time
shuffling these pages around the lists.  Pages in category 4 are
theoretically reclaimable, but the system can enter livelock, with
all cpus spinning on the respective anon_vma lock or i_mmap_lock.

The basic mechanism employed to achieve the stated objective is to
manage "non-reclaimable" pages off the LRU active and inactive lists
on a separate "noreclaim" list.  The "noreclaim" list is based on a
patch by Larry Woodman of Red Hat.  I have enhanced this concept to
make the noreclaim list a peer of the LRU active and inactive list--
i.e., yet another LRU list.  This approach simplifies the management
of noreclaim pages, as we have well established protocols for managing
pages on the LRU.  From my discussions with developers who attended
the VM Summit in Cambridge ~2-3Sept, I understand that there is some
agreement with this approach.

This series, although very much still a work in progress, has been
running in various forms for several months on test machines at HP--
fairly large ia64 NUMA servers--under reasonable high stress loads.  
I have posted a previous version of a subset of these patches on
linux-mm.   The current version has ungone a fair amount of rework
based on discussions with vm developers, but there is still much to
be done.  I'm reposting the new series in hopes of kick-starting
the discussion to either progress this series to acceptance, or
to kill it off so that we can direct our attentions to some other
approach.

Here is a brief [promise I'll try] summary of the patches to
follow.  More details and discussion in the patch descriptions.
The patch names are taken from the file names in my series.

Currently atop 2.6.23-rc4-mm1:

1) make-anon_vma-lock-rw
2) make-i_mmap_lock-rw

The first two patches are not part of the noreclaim infrastructure.
Rather, these patches improve parallelism in shrink_page_list()--
specifically in page_referenced() and try_to_unmap()--by making the
anon_vma lock and the i_mmap_lock reader/writer spinlocks.  

3) move-and-rework-isolate_lru_page

>From Nick Piggin's "keep mlocked pages off LRU" patch, this patch
moves the "isolate_lru_page()" function from mm/migrate.c
to mm/vmscan.c from where it is used by both the page migration
code and this noreclaim series [mlock patches below].

4) introduce-page_anon-function

Extracted from Rik van Riel's "split LRU" patch.  Used by
noreclaim series to detect swap-backed pages.

Aside:  at one point, I had this series working with Rik's
split LRU patch in the same tree.  I have separated them
for now, but plan to remerge at some point for further testing.
Rik's patch in more of a "make reclaim smarter" patch.

5) use-indexed-array-of-lru-lists

Christoph Lameter's cleanup of per zone LRU list handling.
Useful here as noreclaim adds an additional "LRU" list.  Will
also be useful with Rik's "split LRU" mechanism.

Aside:  I note that in 23-rc4-mm1, the memory controller has 
its own active and inactive list.  It may also benefit from
use of Christoph's patch.  Further, we'll need to consider 
whether memory controllers should maintain separate noreclaim
lists.

6) noreclaim-01-no-reclaim-infrastructure

This patch provides the basic noreclaim list mechanism and a
skeletal "page_reclaimable()" predicate function to test whether
a page should be diverted to the noreclaim list.  Subsequent
patches add tests to page_reclaimable().

7) noreclaim-02-report-nonreclaimable-memory

Provides basic accounting/statistics for non-reclaimable
pages.

8) noreclaim-03-ramdisk-pages-are-nonreclaimable

Enhances page_reclaimable() to detect ram_disk pages and
"just say no".  See the patch description for details.

9) noreclaim-04-SHM_LOCKed-pages-are-nonreclaimable

Similarly, declare pages in SHM_LOCKED shmem segments as
non-reclaimable.

10) noreclaim-05-track-anon_vma-related-vmas

Reference count anon_vma--number of vmas in the list.
Declare anon pages non-reclaimable if the count exceeds a 
tunable threshold.

TODO:  similar for file-backed pages.  No such patch yet.

11) noreclaim-06-unswappable-anon-and-shmem

Using Rik's page_anon() function, declare swap-backed
pages as non-reclaimable when no swap space exists.

TODO:  bring the pages back when [sufficient] swap space
freed or added.  See patch description.

12) noreclaim-07.1-prepare-for-mlocked-pages
13) noreclaim-07.2-move-mlocked-pages-off-the-LRU

These two patches are a rework of Nick Piggin's series to
do the same thing--move mlocked pages off the LRU.  The rework
eliminates the use of one of the lru list links as the mlock
count, so that these pages can be maintained on the noreclaim
list.  The count is replaced by a single page flag that is
maintained by mlock/munlock/munmap code.

14) noreclaim-08-cull-nonreclaimable-anon-pages-in-fault-path

This is an optional patch, inspired by Nick's mlock patch.  It 
checks for nonreclaimable anon pages created by copy-on-write
and diverts them to the noreclaim list so that vmscan never
sees them.  Without this patch, shrink_active_list() will see
these pages once and move them to the noreclaim list.  

-----------
A note to reviewers:  these patches contain intentional, glaring
style violations:  use of '//TODO' comments.  I KNOW that these are
style violations and will remove them as the questions they raise
are resolved.  I want them to stand out in hopes that you'll read
the contents.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
