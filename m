Date: Fri, 13 Jan 2006 22:05:33 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: use-once-cleanup testing 
Message-ID: <20060114000533.GA4111@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, Peter Zijlstra <peter@programming.kicks-ass.net>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

Rik's use-once cleanup patch (1) gets rid of a nasty problem. The
use-once logic does not work for mmaped() files, due to the questionable
assumption that any referenced pages of such files should be held in
memory:

1 - http://lwn.net/Articles/134387/

static int shrink_list(struct list_head *page_list, struct scan_control *sc)
{
...
                referenced = page_referenced(page, 1);
                /* In active use or really unfreeable?  Activate it. */
                if (referenced && page_mapping_inuse(page))
                        goto activate_locked;

The page activation scheme relies on mark_page_accessed() (exported
function) to do the list move itself, which is the only way for in-cache
non mapped pages to be promoted to the active list.

Rik's patch instead only sets the referenced bit at
mark_page_accessed(), changing the use-once logic to work by means
of a newly created PG_new flag. The flag, set at add_to_pagecache()
time, gives pages a second round on the inactive list in case they
get referenced. Page activation is then performed if the page is
re-referenced.

Another clear advantage of not doing the list move at mark_page_accessed()
time is decreased zone->lru_lock contention and cache thrashing in 
general (profiling on SMP machines would be interesting).

A possibly negative side-effect of PG_new, already mentioned by Nikita
in this list, is that used-once pages lurk around longer in cache, which
can slowdown particular workloads (it should not be hard to create such
loads).

However, the ongoing non-resident book keeping implementation makes it
possible to completly get rid of "second chance" behaviour: re-accessed
evicted pages are automatically promoted to the active list.

For example this is a real scenario where use-once mmap() is 
performed:
http://www.uwsg.iu.edu/hypermail/linux/kernel/0109.2/0078.html

Patch being used for the tests is:
http://programming.kicks-ass.net/kernel-patches/page-replace/2.6.16-rc1/use_once-cleanup.patch

And here are results of larger than RAM sequential access with mmap():

2.6-git-jan-12:
        Command being timed: "iozone -B -s 143360 -i 1 -i 1 -i 1 -i 1 -w"
        Percent of CPU this job got: 6%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:34.74

2.6-git-jan-12+useonce:
        Command being timed: "iozone -B -s 143360 -i 1 -i 1 -i 1 -i 1 -w"
        Percent of CPU this job got: 13%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:16.22

And a few graphs of the active/inactive sizes with both read and mmap 
mode, with the vanilla and use-once patched kernels:

http://hera.kernel.org/~marcelo/mm/iozone_useonce/iozone_useonce.html

Its possible to note that even using read() the vanilla VM moves
used-once pages to the active list (ie. the logic is not working as
expected).

I would vote for inclusion of the first version of use-once-cleanup
(without the arguable refill_inactive_zone() page_referenced change)
into -mm.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
