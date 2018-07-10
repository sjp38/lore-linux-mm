Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67D456B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 14:49:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b185-v6so28383184qkg.19
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 11:49:23 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u1-v6sor3626963qvh.88.2018.07.10.11.49.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 11:49:21 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 10 Jul 2018 11:49:03 -0700
Message-Id: <20180710184903.68239-1-cannonmatthews@google.com>
Subject: [PATCH] mm: hugetlb: don't zero 1GiB bootmem pages.
From: Cannon Matthews <cannonmatthews@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com, Cannon Matthews <cannonmatthews@google.com>

When using 1GiB pages during early boot, use the new
memblock_virt_alloc_try_nid_raw() function to allocate memory without
zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
memset() call is very slow, and can make early boot last upwards of
20-30 minutes on multi TiB machines.

To be safe, still zero the first sizeof(struct boomem_huge_page) bytes
since this is used a temporary storage place for this info until
gather_bootmem_prealloc() processes them later.

The rest of the memory does not need to be zero'd as the hugetlb pages
are always zero'd on page fault.

Tested: Booted with ~3800 1G pages, and it booted successfully in
roughly the same amount of time as with 0, as opposed to the 25+
minutes it would take before.

Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
---
 mm/hugetlb.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3612fbb32e9d..c93a2c77e881 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2101,7 +2101,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
 	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
 		void *addr;

-		addr = memblock_virt_alloc_try_nid_nopanic(
+		addr = memblock_virt_alloc_try_nid_raw(
 				huge_page_size(h), huge_page_size(h),
 				0, BOOTMEM_ALLOC_ACCESSIBLE, node);
 		if (addr) {
@@ -2109,7 +2109,12 @@ int __alloc_bootmem_huge_page(struct hstate *h)
 			 * Use the beginning of the huge page to store the
 			 * huge_bootmem_page struct (until gather_bootmem
 			 * puts them into the mem_map).
+			 *
+			 * memblock_virt_alloc_try_nid_raw returns non-zero'd
+			 * memory so zero out just enough for this struct, the
+			 * rest will be zero'd on page fault.
 			 */
+			memset(addr, 0, sizeof(struct huge_bootmem_page));
 			m = addr;
 			goto found;
 		}
--
2.18.0.203.gfac676dfb9-goog
