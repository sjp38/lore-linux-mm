Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7C26B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:36:43 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so4268579igb.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:36:43 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id xd13si21101435icb.36.2015.06.25.18.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:36:42 -0700 (PDT)
Received: by igcsj18 with SMTP id sj18so21879891igc.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:36:42 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm: Add error check after call to rmap_walk in the function page_referenced
Date: Thu, 25 Jun 2015 21:36:37 -0400
Message-Id: <1435282597-21728-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, riel@redhat.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This adds a return check after the call to the function rmap_walk
in the function page_referenced as this function call can fail
and thus should signal callers of page_referenced if this happens
by returning the SWAP macro return value as returned by rmap_walk
here. In addition also check if have locked the page pointer as
passed to this particular and unlock it with unlock_page if this
page is locked before returning our SWAP marco return code from
rmap_walk.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/rmap.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 171b687..e4df848 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -814,7 +814,9 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
  *
  * Quick test_and_clear_referenced for all mappings to a page,
- * returns the number of ptes which referenced the page.
+ * returns the number of ptes which referenced the page.On
+ * error returns either zero or the error code returned from
+ * the failed call to rmap_walk.
  */
 int page_referenced(struct page *page,
 		    int is_locked,
@@ -855,7 +857,13 @@ int page_referenced(struct page *page,
 		rwc.invalid_vma = invalid_page_referenced_vma;
 	}
 
+
 	ret = rmap_walk(page, &rwc);
+	if (!ret) {
+		if (we_locked)
+			unlock_page(page);
+		return ret;
+	}
 	*vm_flags = pra.vm_flags;
 
 	if (we_locked)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
