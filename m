Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 586916B0269
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 16:23:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id u28-v6so33941709qtu.3
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 13:23:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23-v6sor3540275qkj.70.2018.10.18.13.23.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 13:23:38 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 6/7] mm: allow ->page_mkwrite to do retries
Date: Thu, 18 Oct 2018 16:23:17 -0400
Message-Id: <20181018202318.9131-7-josef@toxicpanda.com>
In-Reply-To: <20181018202318.9131-1-josef@toxicpanda.com>
References: <20181018202318.9131-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

Before we didn't set the retry flag on our vm_fault.  We want to allow
file systems to drop the mmap_sem if they so choose, so set this flag
and deal with VM_FAULT_RETRY appropriately.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/memory.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 433075f722ea..c5e81edd94f9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2384,11 +2384,13 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 	unsigned int old_flags = vmf->flags;
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf->flags |= old_flags & FAULT_FLAG_ALLOW_RETRY;
 
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+			    VM_FAULT_RETRY)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
@@ -2683,7 +2685,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
-				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+				       VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
@@ -3716,7 +3719,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 		unlock_page(vmf->page);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp ||
-				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+					VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
-- 
2.14.3
