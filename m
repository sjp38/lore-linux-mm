Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 31FE882F65
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:39 -0500 (EST)
Received: by igpw7 with SMTP id w7so61208864igp.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si12814718igj.97.2015.11.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:34 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/5] mm: add cond_resched() to the rmap walks
Date: Mon,  2 Nov 2015 18:01:27 +0100
Message-Id: <1446483691-8494-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

The rmap walk must reach every possible mapping of the page, so if a
page is heavily shared (no matter if it's KSM, anon, pagecache) there
will be tons of entries to walk through. All optimizations with
prio_tree, anon_vma chains, interval tree, helps to find the right
virtual mapping faster, but if there are lots of virtual mappings, all
mapping must still be walked through.

The biggest cost is for the IPIs, but regardless of the IPIs, it's
generally safer to keep these cond_resched() in all cases, as even if
we massively reduce the number of IPIs, the number of entries to walk
IPI-less may still be large and no entry can be possibly skipped in
the page migration case.

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c  | 2 ++
 mm/rmap.c | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 7ee101e..e87dec7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1914,9 +1914,11 @@ again:
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
