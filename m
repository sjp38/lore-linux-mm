Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE686B0254
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:29 -0400 (EDT)
Received: by pabur7 with SMTP id ur7so9257437pab.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id by14si22526267pac.128.2015.10.15.09.04.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:28 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/6] ksm: add cond_resched() to the rmap_walks
Date: Thu, 15 Oct 2015 18:04:21 +0200
Message-Id: <1444925065-4841-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

While at it add it to the file and anon walks too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c  | 2 ++
 mm/rmap.c | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 8fc6793..39ef485 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1961,9 +1961,11 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
+		cond_resched();
 		anon_vma_lock_read(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
+			cond_resched();
 			vma = vmac->vma;
 			if (rmap_item->address < vma->vm_start ||
 			    rmap_item->address >= vma->vm_end)
diff --git a/mm/rmap.c b/mm/rmap.c
index f5b5c1f..b949778 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1607,6 +1607,8 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 
+		cond_resched();
+
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
@@ -1656,6 +1658,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
+		cond_resched();
+
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
