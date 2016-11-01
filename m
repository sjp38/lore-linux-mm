Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8DCB6B02B1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:37:35 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so420001wmy.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:37:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x197si13383172wmf.84.2016.11.01.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/21] mm: Remove unnecessary vma->vm_ops check
Date: Tue,  1 Nov 2016 23:36:20 +0100
Message-Id: <1478039794-20253-15-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

We don't check whether vma->vm_ops is NULL in do_shared_fault() so
there's hardly any point in checking it in wp_page_shared() or
wp_pfn_shared() which get called only for shared file mappings as well.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7be96a43d5ac..26b2858e6a12 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2275,7 +2275,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
+	if (vma->vm_ops->pfn_mkwrite) {
 		int ret;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2305,7 +2305,7 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
 
 	get_page(old_page);
 
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+	if (vma->vm_ops->page_mkwrite) {
 		int tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
