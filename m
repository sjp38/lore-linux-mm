Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5FC6B029F
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 68so8527641wmz.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ql1si12941935wjc.85.2016.11.03.21.25.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/21] mm: Remove unnecessary vma->vm_ops check
Date: Fri,  4 Nov 2016 05:25:07 +0100
Message-Id: <1478233517-3571-12-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

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
