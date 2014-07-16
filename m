Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4496B0087
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:01 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so1332457wiv.3
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:48:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd5si1522843wib.19.2014.07.16.06.48.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:48:55 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 01/15] mm, THP: don't hold mmap_sem in khugepaged when allocating THP
Date: Wed, 16 Jul 2014 15:48:09 +0200
Message-Id: <1405518503-27687-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

When allocating huge page for collapsing, khugepaged currently holds mmap_sem
for reading on the mm where collapsing occurs. Afterwards the read lock is
dropped before write lock is taken on the same mmap_sem.

Holding mmap_sem during whole huge page allocation is therefore useless, the
vma needs to be rechecked after taking the write lock anyway. Furthemore, huge
page allocation might involve a rather long sync compaction, and thus block
any mmap_sem writers and i.e. affect workloads that perform frequent m(un)map
or mprotect oterations.

This patch simply releases the read lock before allocating a huge page. It
also deletes an outdated comment that assumed vma must be stable, as it was
using alloc_hugepage_vma(). This is no longer true since commit 9f1b868a13
("mm: thp: khugepaged: add policy for finding target node").

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 02559ef..107da28 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2295,23 +2295,17 @@ static struct page
 		       int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
+
 	/*
-	 * Allocate the page while the vma is still valid and under
-	 * the mmap_sem read mode so there is no memory allocation
-	 * later when we take the mmap_sem in write mode. This is more
-	 * friendly behavior (OTOH it may actually hide bugs) to
-	 * filesystems in userland with daemons allocating memory in
-	 * the userland I/O paths.  Allocating memory with the
-	 * mmap_sem in read mode is good idea also to allow greater
-	 * scalability.
+	 * Before allocating the hugepage, release the mmap_sem read lock.
+	 * The allocation can take potentially a long time if it involves
+	 * sync compaction, and we do not need to hold the mmap_sem during
+	 * that. We will recheck the vma after taking it again in write mode.
 	 */
+	up_read(&mm->mmap_sem);
+
 	*hpage = alloc_pages_exact_node(node, alloc_hugepage_gfpmask(
 		khugepaged_defrag(), __GFP_OTHER_NODE), HPAGE_PMD_ORDER);
-	/*
-	 * After allocating the hugepage, release the mmap_sem read lock in
-	 * preparation for taking it in write mode.
-	 */
-	up_read(&mm->mmap_sem);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
