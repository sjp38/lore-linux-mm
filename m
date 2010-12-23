Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 715866B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 04:31:00 -0500 (EST)
Received: by wyj26 with SMTP id 26so5880298wyj.14
        for <linux-mm@kvack.org>; Thu, 23 Dec 2010 01:30:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1292443200.git.m.nazarewicz@samsung.com>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Date: Thu, 23 Dec 2010 18:30:57 +0900
Message-ID: <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

any comments? what's the next step to merge it for 2.6.38 kernel. we
want to use this feature at mainline kernel.

Any idea and comments are welcome.

Thank you,
Kyungmin Park

On Thu, Dec 16, 2010 at 5:34 AM, Michal Nazarewicz
<m.nazarewicz@samsung.com> wrote:
> Hello everyone,
>
> This is yet another version of CMA this time stripped from a lot of
> code and with working migration implementation.
>
> =A0 The Contiguous Memory Allocator (CMA) makes it possible for
> =A0 device drivers to allocate big contiguous chunks of memory after
> =A0 the system has booted.
>
> For more information see 7th patch in the set.
>
>
> This version fixes some things Kamezawa suggested plus it separates
> code that uses MIGRATE_CMA from the rest of the code. =A0This I hope
> will help to grasp the overall idea of CMA.
>
>
> The current version is just an allocator that handles allocation of
> contiguous memory blocks. =A0The difference between this patchset and
> Kamezawa's alloc_contig_pages() are:
>
> 1. alloc_contig_pages() requires MAX_ORDER alignment of allocations
> =A0 which may be unsuitable for embeded systems where a few MiBs are
> =A0 required.
>
> =A0 Lack of the requirement on the alignment means that several threads
> =A0 might try to access the same pageblock/page. =A0To prevent this from
> =A0 happening CMA uses a mutex so that only one cm_alloc()/cm_free()
> =A0 function may run at one point.
>
> 2. CMA may use its own migratetype (MIGRATE_CMA) which behaves
> =A0 similarly to ZONE_MOVABLE but can be put in arbitrary places.
>
> =A0 This is required for us since we need to define two disjoint memory
> =A0 ranges inside system RAM. =A0(ie. in two memory banks (do not confuse
> =A0 with nodes)).
>
> 3. alloc_contig_pages() scans memory in search for range that could be
> =A0 migrated. =A0CMA on the other hand maintains its own allocator to
> =A0 decide where to allocate memory for device drivers and then tries
> =A0 to migrate pages from that part if needed. =A0This is not strictly
> =A0 required but I somehow feel it might be faster.
>
>
> Links to previous versions of the patchset:
> v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
> v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
> v5: (intentionally left out as CMA v5 was identical to CMA v4)
> v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
> v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
> v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
> v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>
>
>
> Changelog:
>
> v8: 1. The alloc_contig_range() function has now been separated from
> =A0 =A0 =A0 CMA and put in page_allocator.c. =A0This function tries to
> =A0 =A0 =A0 migrate all LRU pages in specified range and then allocate th=
e
> =A0 =A0 =A0 range using alloc_contig_freed_pages().
>
> =A0 =A02. Support for MIGRATE_CMA has been separated from the CMA code.
> =A0 =A0 =A0 I have not tested if CMA works with ZONE_MOVABLE but I see no
> =A0 =A0 =A0 reasons why it shouldn't.
>
> =A0 =A03. I have added a @private argument when creating CMA contexts so
> =A0 =A0 =A0 that one can reserve memory and not share it with the rest of
> =A0 =A0 =A0 the system. =A0This way, CMA acts only as allocation algorith=
m.
>
> v7: 1. A lot of functionality that handled driver->allocator_context
> =A0 =A0 =A0 mapping has been removed from the patchset. =A0This is not to=
 say
> =A0 =A0 =A0 that this code is not needed, it's just not worth posting
> =A0 =A0 =A0 everything in one patchset.
>
> =A0 =A0 =A0 Currently, CMA is "just" an allocator. =A0It uses it's own
> =A0 =A0 =A0 migratetype (MIGRATE_CMA) for defining ranges of pageblokcs
> =A0 =A0 =A0 which behave just like ZONE_MOVABLE but dispite the latter ca=
n
> =A0 =A0 =A0 be put in arbitrary places.
>
> =A0 =A02. The migration code that was introduced in the previous version
> =A0 =A0 =A0 actually started working.
>
>
> v6: 1. Most importantly, v6 introduces support for memory migration.
> =A0 =A0 =A0 The implementation is not yet complete though.
>
> =A0 =A0 =A0 Migration support means that when CMA is not using memory
> =A0 =A0 =A0 reserved for it, page allocator can allocate pages from it.
> =A0 =A0 =A0 When CMA wants to use the memory, the pages have to be moved
> =A0 =A0 =A0 and/or evicted as to make room for CMA.
>
> =A0 =A0 =A0 To make it possible it must be guaranteed that only movable a=
nd
> =A0 =A0 =A0 reclaimable pages are allocated in CMA controlled regions.
> =A0 =A0 =A0 This is done by introducing a MIGRATE_CMA migrate type that
> =A0 =A0 =A0 guarantees exactly that.
>
> =A0 =A0 =A0 Some of the migration code is "borrowed" from Kamezawa
> =A0 =A0 =A0 Hiroyuki's alloc_contig_pages() implementation. =A0The main
> =A0 =A0 =A0 difference is that thanks to MIGRATE_CMA migrate type CMA
> =A0 =A0 =A0 assumes that memory controlled by CMA are is always movable o=
r
> =A0 =A0 =A0 reclaimable so that it makes allocation decisions regardless =
of
> =A0 =A0 =A0 the whether some pages are actually allocated and migrates th=
em
> =A0 =A0 =A0 if needed.
>
> =A0 =A0 =A0 The most interesting patches from the patchset that implement
> =A0 =A0 =A0 the functionality are:
>
> =A0 =A0 =A0 =A0 09/13: mm: alloc_contig_free_pages() added
> =A0 =A0 =A0 =A0 10/13: mm: MIGRATE_CMA migration type added
> =A0 =A0 =A0 =A0 11/13: mm: MIGRATE_CMA isolation functions added
> =A0 =A0 =A0 =A0 12/13: mm: cma: Migration support added [wip]
>
> =A0 =A0 =A0 Currently, kernel panics in some situations which I am trying
> =A0 =A0 =A0 to investigate.
>
> =A0 =A02. cma_pin() and cma_unpin() functions has been added (after
> =A0 =A0 =A0 a conversation with Johan Mossberg). =A0The idea is that when=
ever
> =A0 =A0 =A0 hardware does not use the memory (no transaction is on) the
> =A0 =A0 =A0 chunk can be moved around. =A0This would allow defragmentatio=
n to
> =A0 =A0 =A0 be implemented if desired. =A0No defragmentation algorithm is
> =A0 =A0 =A0 provided at this time.
>
> =A0 =A03. Sysfs support has been replaced with debugfs. =A0I always felt
> =A0 =A0 =A0 unsure about the sysfs interface and when Greg KH pointed it
> =A0 =A0 =A0 out I finally got to rewrite it to debugfs.
>
>
> v5: (intentionally left out as CMA v5 was identical to CMA v4)
>
>
> v4: 1. The "asterisk" flag has been removed in favour of requiring
> =A0 =A0 =A0 that platform will provide a "*=3D<regions>" rule in the map
> =A0 =A0 =A0 attribute.
>
> =A0 =A02. The terminology has been changed slightly renaming "kind" to
> =A0 =A0 =A0 "type" of memory. =A0In the previous revisions, the documenta=
tion
> =A0 =A0 =A0 indicated that device drivers define memory kinds and now,
>
> v3: 1. The command line parameters have been removed (and moved to
> =A0 =A0 =A0 a separate patch, the fourth one). =A0As a consequence, the
> =A0 =A0 =A0 cma_set_defaults() function has been changed -- it no longer
> =A0 =A0 =A0 accepts a string with list of regions but an array of regions=
