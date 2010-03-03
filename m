Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 696466B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 14:30:59 -0500 (EST)
Subject: [BUG] 2.6.33-mmotm-100302
 "page-allocator-reduce-fragmentation-in-buddy-allocator..." patch causes
 Oops at boot
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 03 Mar 2010 14:30:32 -0500
Message-Id: <1267644632.4023.28.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Corrado Zoccolo <czoccolo@gmail.com>
Cc: Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Against 2.6.33-mmotm-100302...

The patch:  "page-allocator-reduce-fragmentation-in-buddy-allocator-by-adding-buddies-that-are-merging-to-the-tail-of-the-free-lists.patch"
is causing our ia64 platforms to Oops and hang at boot:

...
Built 5 zonelists in Zone order, mobility grouping on.  Total pages: 1043177
Policy zone: Normal
<snip pci stuff>
Unable to handle kernel paging request at virtual address a07fffff9f000000
swapper[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2018 ifs : 8000000000000996 ip  : [<a0000001001619c0>]    Not tainted (2.6.33-mmotm-100302-1838-dbg)
ip is at free_one_page+0x4e0/0x820
unat: 0000000000000000 pfs : 0000000000000996 rsc : 0000000000000003
rnat: 000000000000000f bsps: 0000000affffffff pr  : 666696015982aa59
ldrs: 0000000000000000 ccv : 0000000000005e9d fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001619b0 b6  : a00000010052e8c0 b7  : a0000001000687a0
f6  : 1003e00000000000014a8 f7  : 1003e0000000000000295
f8  : 1003e0000000000000008 f9  : 1003e0000000000000a48
f10 : 1003e0000000000000149 f11 : 1003e0000000000000008
r1  : a000000100c9d220 r2  : a07ffffddf000000 r3  : a000000100ab5688
r8  : 0000000000000001 r9  : 0000000000000000 r10 : 0000000000080000
r11 : 000000000000000d r12 : a0000001009bfe00 r13 : a0000001009b0000
r14 : 0000000000000000 r15 : ffffffffffff0000 r16 : a07fffff9f200000
r17 : 0000000000000001 r18 : a07fffff9f20003f r19 : 0000000000200000
r20 : a07ffffddf000000 r21 : 0000000000008000 r22 : fffffffffff00000
r23 : ffffffffffffc000 r24 : 0000000000000000 r25 : 0000000000008000
r26 : ffffffffffffbfff r27 : ffffffffffffbfff r28 : a000000100ab5b30
r29 : a000000100ab5688 r30 : 000000000883fc00 r31 : a000000100ab5b38

<2nd Oops>
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 11012296146944 [2]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 0000121008022018 ifs : 800000000000040b ip  : [<a0000001001cdbb1>]    Not tainted (2.6.33-mmotm-100302-1838-dbg)
ip is at kmem_cache_alloc+0x1b1/0x380
unat: 0000000000000000 pfs : 0000000000000792 rsc : 0000000000000003
rnat: 0000000000000000 bsps: c0000ffc50057290 pr  : 6666960159826965
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000444c0 b6  : a0000001000447a0 b7  : a00000010000c170
f6  : 1003eaca103779b0a35c6 f7  : 1003e9e3779b97f4a7c16
f8  : 1003e0a00000010001589 f9  : 1003e0000000000000a48
f10 : 1003e0000000000000149 f11 : 1003e0000000000000008
r1  : a000000100c9d220 r2  : 0000000012000000 r3  : a0000001009b0014
r8  : 0000000000000000 r9  : 00000000003fff2f r10 : a000000100a18788
r11 : a000000100a9da68 r12 : a0000001009bf2e0 r13 : a0000001009b0000
r14 : 0000000000000000 r15 : a0000001009bf344 r16 : 0000000000000000
r17 : 0000000000200000 r18 : 0000000000000000 r19 : a0000001009bf318
r20 : 0000000000000000 r21 : 0000000000000000 r22 : 0000000000000000
r23 : a0000001009bf340 r24 : a0000001009bf344 r25 : a000000100ab3d30
r26 : 0000000000000000 r27 : 0000000000000000 r28 : a0000001009bf340
r29 : 0000000000000000 r30 : a0000001009b0d94 r31 : a00000010070bca0


I think this is pointing at:

	free_one_page+0x4e0:
	 => static inline void __free_one_page()
	    =>static inline int page_is_buddy()
		if (page_zone_id(page) != page_zone_id(buddy))
	               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   ???

I expect this has something to do with the alignment of the
virtual mem_map w/rt the actual start of valid page structs.
The instrumentation shows that the problem occurs when the
combined_idx for the last coalesced page == 0, resulting in
a page struct address < start of node 0's node_mem_map.

I've included a work-around patch below, but I'm pretty sure
it's not the right long-term solution.


More info from the boot log, including some ad hoc
instrumentation of the patched region of __free_one_page().

...

Virtual mem_map starts at 0xa07ffffddf000000
Node 0 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffff9f080000
!!! -------------------------------------------------------------^^^^^^
Node 1 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffbf000000
Node 2 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffdf000000
Node 3 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07fffffff000000
Node 4 memmap at 0xa07ffffddf000000 size 0 first pfn 0xa07ffffddf000000

On node 0 totalpages: 252672
free_area_init_node: node 0, pgdat e000070020100000, node_mem_map a07fffff9f080000
  Normal zone: 247 pages used for memmap
  Normal zone: 252425 pages, LIFO batch:1
On node 1 totalpages: 261120
free_area_init_node: node 1, pgdat e000078000110080, node_mem_map a07fffffbf000000
  Normal zone: 255 pages used for memmap
  Normal zone: 260865 pages, LIFO batch:1
On node 2 totalpages: 261119
free_area_init_node: node 2, pgdat e000080000120100, node_mem_map a07fffffdf000000
  Normal zone: 255 pages used for memmap
  Normal zone: 260864 pages, LIFO batch:1
On node 3 totalpages: 261097
free_area_init_node: node 3, pgdat e000088000130180, node_mem_map a07fffffff000000
  Normal zone: 255 pages used for memmap
  Normal zone: 260842 pages, LIFO batch:1
On node 4 totalpages: 8189
free_area_init_node: node 4, pgdat e000000000140200, node_mem_map a07ffffddf000000
  DMA zone: 8 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 8181 pages, LIFO batch:0

...

Instrumentation from __free_one_page() when combined_idx == 0:

__free_one_page:  page = a07fffff9f100000, order = 14, page_idx = 16384
        combined_idx = 0, higher_page = a07fffff9f000000, higher_buddy = a07fffff9f200000
__free_one_page:  page = a07fffff9f200000, order = 15, page_idx = 32768
        combined_idx = 0, higher_page = a07fffff9f000000, higher_buddy = a07fffff9f400000

>The higher_page's above appear to be below the start of node 0's node_mem_map.
>The first combined_idx == 0 was causing the Oops.


> Some [most? all?] of the following from nodes 0 and 1 may be OK?  page addresses appear
> to be in range of their respecitive node's node_mem_map.

__free_one_page:  page = a07fffff9f800000, order = 6, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f802000
__free_one_page:  page = a07fffff9f800000, order = 7, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f804000
__free_one_page:  page = a07fffff9f800000, order = 8, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f808000
__free_one_page:  page = a07fffff9f800000, order = 9, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f810000
__free_one_page:  page = a07fffff9f800000, order = 10, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f820000
__free_one_page:  page = a07fffff9f800000, order = 11, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f840000
__free_one_page:  page = a07fffff9f800000, order = 12, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f880000
__free_one_page:  page = a07fffff9f800000, order = 13, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9f900000
__free_one_page:  page = a07fffff9f800000, order = 14, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9fa00000
__free_one_page:  page = a07fffff9f800000, order = 15, page_idx = 0
        combined_idx = 0, higher_page = a07fffff9f800000, higher_buddy = a07fffff9fc00000
<Node 1>
__free_one_page:  page = a07fffffbf008000, order = 9, page_idx = 512
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf010000
__free_one_page:  page = a07fffffbf010000, order = 10, page_idx = 1024
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf020000
__free_one_page:  page = a07fffffbf020000, order = 11, page_idx = 2048
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf040000
__free_one_page:  page = a07fffffbf040000, order = 12, page_idx = 4096
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf080000
__free_one_page:  page = a07fffffbf080000, order = 13, page_idx = 8192
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf100000
__free_one_page:  page = a07fffffbf100000, order = 14, page_idx = 16384
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf200000
__free_one_page:  page = a07fffffbf200000, order = 15, page_idx = 32768
        combined_idx = 0, higher_page = a07fffffbf000000, higher_buddy = a07fffffbf400000
__free_one_page:  page = a07fffffbf800000, order = 6, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf802000
__free_one_page:  page = a07fffffbf800000, order = 7, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf804000
__free_one_page:  page = a07fffffbf800000, order = 8, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf808000
__free_one_page:  page = a07fffffbf800000, order = 9, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf810000
__free_one_page:  page = a07fffffbf800000, order = 10, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf820000
__free_one_page:  page = a07fffffbf800000, order = 11, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf840000
__free_one_page:  page = a07fffffbf800000, order = 12, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf880000
__free_one_page:  page = a07fffffbf800000, order = 13, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbf900000
__free_one_page:  page = a07fffffbf800000, order = 14, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbfa00000
__free_one_page:  page = a07fffffbf800000, order = 15, page_idx = 0
        combined_idx = 0, higher_page = a07fffffbf800000, higher_buddy = a07fffffbfc00000
<snip similar lines for nodes 2, 3, & 4>
Memory: 66735232k/66807296k available (6886k code, 93440k reserved, 4015k data, 704k init)

---

The following patch--unsigned and almost certainly bogus--avoids
the problem by ignoring pages with combined_idx == 0.  This will
cause __free_one_page() to skip some valid higher order potential
buddies.  It would probably be more generic to verify that the
resulting higher_page is in range of the node's mem_map.  I haven't
figured out how to do that efficiently here, yet.

Maybe something like:

	pg_data_t *pgdat = NODE_DATA[zone_to_nid(zone)];
	if (higher_page > pgdat->node_mem_map && higher_buddy > pgdat->node_mem_map &&
	    page_is_buddy()...

But this might be a bit heavy for this path?  And should we check the end of the
node_mem_map as well?


 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.33-rc7-mmotm-100211-2155/mm/page_alloc.c
===================================================================
--- linux-2.6.33-rc7-mmotm-100211-2155.orig/mm/page_alloc.c
+++ linux-2.6.33-rc7-mmotm-100211-2155/mm/page_alloc.c
@@ -494,7 +494,8 @@ static inline void __free_one_page(struc
 		combined_idx = __find_combined_index(page_idx, order);
 		higher_page = page + combined_idx - page_idx;
 		higher_buddy = __page_find_buddy(higher_page, combined_idx, order + 1);
-		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
+		if (combined_idx &&
+		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
 				&zone->free_area[order].free_list[migratetype]);
 			goto out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
