Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3C6F16B0098
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:44:06 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH 0/3] swap/frontswap: allow movement of zcache pages to swap
Date: Wed,  3 Oct 2012 15:43:51 -0700
Message-Id: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, hughd@google.com, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, dan.magenheimer@oracle.com, aarcange@redhat.com, mgorman@suse.de, gregkh@linuxfoundation.org

INTRODUCTION

This is an initial patchset attempting to address Andrea Arcangeli's concern
expressed in https://lwn.net/Articles/516538/ "Moving zcache towards the
mainline".  It works, but not well, so feedback/help/expertise is definitely
needed!  Note that the zcache code that invokes this already exists in
zcache2, currently housed in Linus' 3.7-rc0 tree in drivers/staging/ramster,
so is not included in this patchset.  All relevant code in zcache is
conveniently marked with "#ifdef FRONTSWAP_UNUSE" which this patchset enables.

This patchset currently applies cleanly in Linus' tree following commit
33c2a174120b2c1baec9d1dac513f9d4b761b26a

[PROMOTION NOTE: Due to the great zcache compromise, the author won't take a
position on whether this "unuse" capability is a new zcache feature nor
whether this capability is necessary for production use of zcache.  This post
merely documents the motivation, mechanism, and policy of a possible solution
and provides a work-to-date patch, and requests discussion and feedback from
mm experts to ensure that, at some point in zcache's future, this important
capability can be completed and made available to zcache users.]

MOTIVATION

Several mm developers have noted that one of the key limiters to zcache
is that zcache may fill up with pages from frontswap and, once full,
there is no mechanism (or policy) to "evict" pages to make room for
newer pages.  This is problematic for some workloads, especially those
with a mix of long-lived-rarely-running threads (type A) such as system
services that run at boot and shutdown, and short-lived-always-running
threads (type B).  In a non-zcache system under memory pressure, type A
pages will be swapped to ensure that type B pages remain in RAM.  With
zcache, if even with compression there is insufficient RAM for both,
type A pages will fill zcache and type B pages will be swapped, resulting
in noticably reduced performance for type B threads.  Not good.

So it would be good if zcache had some mechanism for saying "oops, this
frontswap page saved in zcache should go out to the swap device after all."
We will call this "eviction".  (Note that zcache already supports eviction
of cleancache pages because these need only be "reclaimed"... the data
contained in cleancache pages can be discarded.  For the remainder of this
discussion, "eviction" implies a frontswap page.)

This begs the question: What page should zcache choose to evict?  While it
is impossible to predict what pages will be used when, the memory management
subsystem normally employs some form of LRU queue to minimize the probability
that an actively used page will be evicted.  Note, however, that evicting
one zcache page ("zpage") may or may not free up a pageframe as two (or,
in the case of the zsmalloc, more than two) zpages may reside in the same
pageframe.  Since freeing up a part of a pageframe has little value and,
indeed, even swapping a page to a swap device requires a full pageframe,
the zcache eviction policy must evict all zpages in a pageframe.  We will
call this "unuse".  For the remainder of this discussion, we will assume
a zcache pageframe contains exactly two zpages (though this may change in
the future).

MECHANISM

Should zcache write entire pageframes to the swap device, with multiple
zpages contained intact?  This might be possible, and could be explored,
but raises some interesting metadata challenges;  a fair amount of
additional RAM would be necessary to track these sets of zpages.  It might
also be easier if each swap disk had a "shadow": one swap device for
uncompressed pages, and a shadow device for compressed pages, else we
must take great care to avoid overwriting one with the other, which would
likely require some fairly invasive changes to the swap subsystem, which
already has a number of interesting coherency problems solved.  A shadow
swap disk would also require additional devices and/or disk space, which
may not be available, plus userland/sysadmin changes, which would be
difficult to mainstream.

So, we'd like an implementation that has a low requirement for in-RAM
metadata and has no requirement for additional swap device/space or
additional userland changes.

To achieve this, we will rely heavily on the existing swapcache.  When
zcache wishes to unuse a zcache pageframe, it first allocates two pageframes,
one for each zpage, and decompresses each zpage into a pageframe.  It then
frontswap to mark a new bit (in a one-bit-per-swap-page array) called a
"denial" bit.  Next it puts the uncompressed pageframe back into the swap
cache, at the least-recently-used end of the anonymous-inactive queue which,
presumably, makes it a candidate for immediate swapwrite.  At this point,
zcache is now free to release the pageframe that contained the two zpages.
Soon, memory pressure causes kswapd to select some pages to write
to swap.  As with all swap attempts, frontswap will first be called,
but since the denial bit is set, frontswap will reject the page
and the swap subsystem will write the page to the true swapdisk.

There are a number of housekeeping details, but that's the proposed
mechanism, implemented in this patchset, in a nutshell.

POLICY

There are some policy questions: How do we maintain an LRU queue
of zpages?  How do we know when zcache is "full"?  If zcache is
full, how do we ensure we can allocate two fresh pageframes for
decompression, and won't this potentially cause an OOM?  The
new zcache implementation (aka zcache2) attempts a trial policy
for each of these, but without a known working mechanism, the
policy may be irrelevant or wrong.  So let's focus first on
getting a working mechanism, OK?

CALL FOR INPUT/HELP

The patchset proposed does work and, in limited testing, does not OOM.
However, performance is much slower than expected and, with extensive
debug output, it appears that "immediate swapwrite" is not very immediate.
This may be related to the performance degradation.  Or there may be
a stupid bug lingering.  Or... the patchset may be completely braindead!
Any help or input in getting this working (or perhaps justifying why a
completely different mechanism might work better) would be appreciated!

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---
Diffstat:

 include/linux/frontswap.h |   57 ++++++++++++++++++++++++++++++++
 include/linux/swap.h      |   12 +++++++
 mm/frontswap.c            |   29 ++++++++++++++++
 mm/swap.c                 |   16 +++++++++
 mm/swap_state.c           |   80 +++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c             |   18 +++++++---
 6 files changed, 207 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
