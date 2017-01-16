Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 197B26B0253
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 13:04:13 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id l7so101924647qtd.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 10:04:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h184si14744900qkf.91.2017.01.16.10.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 10:04:12 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: shmem: avoid a lockup resulting from corrupted page->flags
Date: Mon, 16 Jan 2017 19:04:08 +0100
Message-Id: <20170116180408.12184-2-aarcange@redhat.com>
In-Reply-To: <20170116180408.12184-1-aarcange@redhat.com>
References: <20170116180408.12184-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Use the non atomic version of __SetPageUptodate while the page is
still private and not visible to lookup operations. Using the non
atomic version after the page is already visible to lookups is unsafe
as there would be concurrent lock_page operation modifying the
page->flags while it runs.

This solves a lockup in find_lock_entry with the userfaultfd_shmem
selftest.

userfaultfd_shm D14296   691      1 0x00000004
Call Trace:
 ? __schedule+0x311/0xb60
 schedule+0x3d/0x90
 schedule_timeout+0x228/0x420
 ? mark_held_locks+0x71/0x90
 ? ktime_get+0x134/0x170
 ? kvm_clock_read+0x25/0x30
 ? kvm_clock_get_cycles+0x9/0x10
 ? ktime_get+0xd6/0x170
 ? __delayacct_blkio_start+0x1f/0x30
 io_schedule_timeout+0xa4/0x110
 ? trace_hardirqs_on+0xd/0x10
 __lock_page+0x12d/0x170
 ? add_to_page_cache_lru+0xe0/0xe0
 find_lock_entry+0xa4/0x190
 shmem_getpage_gfp+0xb9/0xc30
 ? alloc_set_pte+0x56e/0x610
 ? radix_tree_next_chunk+0xf6/0x2d0
 shmem_fault+0x70/0x1c0
 ? filemap_map_pages+0x3bd/0x530
 __do_fault+0x21/0x150
 handle_mm_fault+0xec9/0x1490
 __do_page_fault+0x20d/0x520
 trace_do_page_fault+0x61/0x270
 do_async_page_fault+0x19/0x80
 async_page_fault+0x25/0x30

Reported-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index b1ecd07..873b847 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2247,6 +2247,7 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	VM_BUG_ON(PageLocked(page) || PageSwapBacked(page));
 	__SetPageLocked(page);
 	__SetPageSwapBacked(page);
+	__SetPageUptodate(page);
 
 	ret = mem_cgroup_try_charge(page, dst_mm, gfp, &memcg, false);
 	if (ret)
@@ -2271,8 +2272,6 @@ int shmem_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	if (!pte_none(*dst_pte))
 		goto out_release_uncharge_unlock;
 
-	__SetPageUptodate(page);
-
 	lru_cache_add_anon(page);
 
 	spin_lock(&info->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
