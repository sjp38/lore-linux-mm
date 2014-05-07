Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 502F36B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:36:15 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so405642pab.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:36:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id vw5si12918760pab.456.2014.05.06.19.36.13
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 19:36:13 -0700 (PDT)
From: Leon Ma <xindong.ma@intel.com>
Subject: [PATCH] rmap: validate pointer in anon_vma_clone
Date: Wed,  7 May 2014 10:32:09 +0800
Message-Id: <1399429930-5073-1-git-send-email-xindong.ma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, gorcunov@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Leon Ma <xindong.ma@intel.com>

If memory allocation failed in first loop, root will be NULL and
will lead to kernel panic.

Signed-off-by: Leon Ma <xindong.ma@intel.com>
---
 mm/rmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..6e53aed 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -246,8 +246,10 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 
 		avc = anon_vma_chain_alloc(GFP_NOWAIT | __GFP_NOWARN);
 		if (unlikely(!avc)) {
-			unlock_anon_vma_root(root);
-			root = NULL;
+			if (!root) {
+				unlock_anon_vma_root(root);
+				root = NULL;
+			}
 			avc = anon_vma_chain_alloc(GFP_KERNEL);
 			if (!avc)
 				goto enomem_failure;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
