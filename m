Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBDF6B0005
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 17:48:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so5257220pfm.15
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 14:48:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t70-v6si7047485pgc.481.2018.06.15.14.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 14:47:58 -0700 (PDT)
Date: Fri, 15 Jun 2018 14:47:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: skip invalid pages block at a time in
 zero_resv_unresv
Message-Id: <20180615144756.89479279f1506697f87bc61e@linux-foundation.org>
In-Reply-To: <20180615155733.1175-1-pasha.tatashin@oracle.com>
References: <20180615155733.1175-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, osalvador@suse.de, willy@infradead.org, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

On Fri, 15 Jun 2018 11:57:33 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> The role of zero_resv_unavail() is to make sure that every struct page that
> is allocated but is not backed by memory that is accessible by kernel is
> zeroed and not in some uninitialized state.
> 
> Since struct pages are allocated in blocks (2M pages in x86 case), we can
> skip pageblock_nr_pages at a time, when the first one is found to be
> invalid.
> 
> This optimization may help since now on x86 every hole in e820 maps
> is marked as reserved in memblock, and thus will go through this function.
> 
> This function is called before sched_clock() is initialized, so I used my
> x86 early boot clock patches to measure the performance improvement.
> 
> With 1T hole on i7-8700 currently we would take 0.606918s of boot time, but
> with this optimization 0.001103s.

This conflicts with mm-zero-remaining-unavailable-struct-pages.patch, below.

mm-zero-remaining-unavailable-struct-pages.patch (which you have yet to
review, please) fixes an oops and is rather higher priority.



From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: mm: zero remaining unavailable struct pages

There is a kernel panic that is triggered when reading /proc/kpageflags on
the kernel booted with kernel parameter 'memmap=nn[KMG]!ss[KMG]':

  BUG: unable to handle kernel paging request at fffffffffffffffe
  PGD 9b20e067 P4D 9b20e067 PUD 9b210067 PMD 0
  Oops: 0000 [#1] SMP PTI
  CPU: 2 PID: 1728 Comm: page-types Not tainted 4.17.0-rc6-mm1-v4.17-rc6-180605-0816-00236-g2dfb086ef02c+ #160
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.fc28 04/01/2014
  RIP: 0010:stable_page_flags+0x27/0x3c0
  Code: 00 00 00 0f 1f 44 00 00 48 85 ff 0f 84 a0 03 00 00 41 54 55 49 89 fc 53 48 8b 57 08 48 8b 2f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 01 0f 84 10 03 00 00 31 db 49 8b 54 24 08 4c 89 e7
  RSP: 0018:ffffbbd44111fde0 EFLAGS: 00010202
  RAX: fffffffffffffffe RBX: 00007fffffffeff9 RCX: 0000000000000000
  RDX: 0000000000000001 RSI: 0000000000000202 RDI: ffffed1182fff5c0
  RBP: ffffffffffffffff R08: 0000000000000001 R09: 0000000000000001
  R10: ffffbbd44111fed8 R11: 0000000000000000 R12: ffffed1182fff5c0
  R13: 00000000000bffd7 R14: 0000000002fff5c0 R15: ffffbbd44111ff10
  FS:  00007efc4335a500(0000) GS:ffff93a5bfc00000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: fffffffffffffffe CR3: 00000000b2a58000 CR4: 00000000001406e0
  Call Trace:
   kpageflags_read+0xc7/0x120
   proc_reg_read+0x3c/0x60
   __vfs_read+0x36/0x170
   vfs_read+0x89/0x130
   ksys_pread64+0x71/0x90
   do_syscall_64+0x5b/0x160
   entry_SYSCALL_64_after_hwframe+0x44/0xa9
  RIP: 0033:0x7efc42e75e23
  Code: 09 00 ba 9f 01 00 00 e8 ab 81 f4 ff 66 2e 0f 1f 84 00 00 00 00 00 90 83 3d 29 0a 2d 00 00 75 13 49 89 ca b8 11 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 db d3 01 00 48 89 04 24

According to kernel bisection, this problem became visible due to commit
f7f99100d8d9 which changes how struct pages are initialized.

Memblock layout affects the pfn ranges covered by node/zone. Consider
that we have a VM with 2 NUMA nodes and each node has 4GB memory, and
the default (no memmap= given) memblock layout is like below:

  MEMBLOCK configuration:
   memory size = 0x00000001fff75c00 reserved size = 0x000000000300c000
   memory.cnt  = 0x4
   memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
   memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
   memory[0x2]     [0x0000000100000000-0x000000013fffffff], 0x0000000040000000 bytes on node 0 flags: 0x0
   memory[0x3]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
   ...

If you give memmap=1G!4G (so it just covers memory[0x2]),
the range [0x100000000-0x13fffffff] is gone:

  MEMBLOCK configuration:
   memory size = 0x00000001bff75c00 reserved size = 0x000000000300c000
   memory.cnt  = 0x3
   memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
   memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
   memory[0x2]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
   ...

This causes shrinking node 0's pfn range because it is calculated by
the address range of memblock.memory. So some of struct pages in the
gap range are left uninitialized.

We have a function zero_resv_unavail() which does zeroing the struct
pages outside memblock.memory, but currently it covers only the reserved
unavailable range (i.e. memblock.memory && !memblock.reserved).
This patch extends it to cover all unavailable range, which fixes
the reported issue.

Link: http://lkml.kernel.org/r/20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp
Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Tested-by: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memblock.h |   16 ----------------
 mm/page_alloc.c          |   33 ++++++++++++++++++++++++---------
 2 files changed, 24 insertions(+), 25 deletions(-)

diff -puN include/linux/memblock.h~mm-zero-remaining-unavailable-struct-pages include/linux/memblock.h
--- a/include/linux/memblock.h~mm-zero-remaining-unavailable-struct-pages
+++ a/include/linux/memblock.h
@@ -236,22 +236,6 @@ void __next_mem_pfn_range(int *idx, int
 	for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved,	\
 			       nid, flags, p_start, p_end, p_nid)
 
-/**
- * for_each_resv_unavail_range - iterate through reserved and unavailable memory
- * @i: u64 used as loop variable
- * @flags: pick from blocks based on memory attributes
- * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
- * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
- *
- * Walks over unavailable but reserved (reserved && !memory) areas of memblock.
- * Available as soon as memblock is initialized.
- * Note: because this memory does not belong to any physical node, flags and
- * nid arguments do not make sense and thus not exported as arguments.
- */
-#define for_each_resv_unavail_range(i, p_start, p_end)			\
-	for_each_mem_range(i, &memblock.reserved, &memblock.memory,	\
-			   NUMA_NO_NODE, MEMBLOCK_NONE, p_start, p_end, NULL)
-
 static inline void memblock_set_region_flags(struct memblock_region *r,
 					     unsigned long flags)
 {
diff -puN mm/page_alloc.c~mm-zero-remaining-unavailable-struct-pages mm/page_alloc.c
--- a/mm/page_alloc.c~mm-zero-remaining-unavailable-struct-pages
+++ a/mm/page_alloc.c
@@ -6390,25 +6390,40 @@ void __paginginit free_area_init_node(in
  * struct pages which are reserved in memblock allocator and their fields
  * may be accessed (for example page_to_pfn() on some configuration accesses
  * flags). We must explicitly zero those struct pages.
+ *
+ * This function also addresses a similar issue where struct pages are left
+ * uninitialized because the physical address range is not covered by
+ * memblock.memory or memblock.reserved. That could happen when memblock
+ * layout is manually configured via memmap=.
  */
 void __paginginit zero_resv_unavail(void)
 {
 	phys_addr_t start, end;
 	unsigned long pfn;
 	u64 i, pgcnt;
+	phys_addr_t next = 0;
 
 	/*
-	 * Loop through ranges that are reserved, but do not have reported
-	 * physical memory backing.
+	 * Loop through unavailable ranges not covered by memblock.memory.
 	 */
 	pgcnt = 0;
-	for_each_resv_unavail_range(i, &start, &end) {
-		for (pfn = PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
-			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
-				continue;
-			mm_zero_struct_page(pfn_to_page(pfn));
-			pgcnt++;
+	for_each_mem_range(i, &memblock.memory, NULL,
+			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
+		if (next < start) {
+			for (pfn = PFN_DOWN(next); pfn < PFN_UP(start); pfn++) {
+				if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
+					continue;
+				mm_zero_struct_page(pfn_to_page(pfn));
+				pgcnt++;
+			}
 		}
+		next = end;
+	}
+	for (pfn = PFN_DOWN(next); pfn < max_pfn; pfn++) {
+		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
+			continue;
+		mm_zero_struct_page(pfn_to_page(pfn));
+		pgcnt++;
 	}
 
 	/*
@@ -6419,7 +6434,7 @@ void __paginginit zero_resv_unavail(void
 	 * this code can be removed.
 	 */
 	if (pgcnt)
-		pr_info("Reserved but unavailable: %lld pages", pgcnt);
+		pr_info("Zeroed struct page in unavailable ranges: %lld pages", pgcnt);
 }
 #endif /* CONFIG_HAVE_MEMBLOCK */
 
_
