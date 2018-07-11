Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4796B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:33:19 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id q141-v6so13140163ywg.5
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:33:19 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d62-v6sor3842970ybd.208.2018.07.11.14.33.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 14:33:18 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 11 Jul 2018 14:33:13 -0700
Message-Id: <20180711213313.92481-1-cannonmatthews@google.com>
Subject: [PATCH v2] mm: hugetlb: don't zero 1GiB bootmem pages.
From: Cannon Matthews <cannonmatthews@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com, mhocko@kernel.org, Cannon Matthews <cannonmatthews@google.com>

When using 1GiB pages during early boot, use the new
memblock_virt_alloc_try_nid_raw() function to allocate memory without
zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
memset() call is very slow, and can make early boot last upwards of
20-30 minutes on multi TiB machines.

The memory does not need to be zero'd as the hugetlb pages are always
zero'd on page fault.

Tested: Booted with ~3800 1G pages, and it booted successfully in
roughly the same amount of time as with 0, as opposed to the 25+
minutes it would take before.

Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
---
v2: removed the memset of the huge_bootmem_page area and added
INIT_LIST_HEAD instead.

 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3612fbb32e9d..488330f23f04 100644
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
@@ -2119,6 +2119,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
 found:
 	BUG_ON(!IS_ALIGNED(virt_to_phys(m), huge_page_size(h)));
 	/* Put them into a private list first because mem_map is not up yet */
+	INIT_LIST_HEAD(&m->list);
 	list_add(&m->list, &huge_boot_pages);
 	m->hstate = h;
 	return 1;
--
2.18.0.203.gfac676dfb9-goog
