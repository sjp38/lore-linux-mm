Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55E1B6B027C
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 19:34:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m83so8997407wmc.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:34:39 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 69si6751534wms.141.2016.10.25.16.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 16:34:38 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y138so2156896wme.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:34:37 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] mm: fixup get_user_pages* comments
Date: Wed, 26 Oct 2016 00:34:35 +0100
Message-Id: <20161025233435.5338-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

In the previous round of get_user_pages* changes comments attached to
__get_user_pages_unlocked() and get_user_pages_unlocked() were rendered
incorrect, this patch corrects them.

In addition the get_user_pages_unlocked() comment seems to have already been
outdated as it referred to tsk, mm parameters which were removed in c12d2da5
("mm/gup: Remove the macro overload API migration helpers from the get_user*()
APIs"), this patch fixes this also.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 mm/gup.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ec4f827..e6147f1 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -857,14 +857,12 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 EXPORT_SYMBOL(get_user_pages_locked);
 
 /*
- * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows to
- * pass additional gup_flags as last parameter (like FOLL_HWPOISON).
+ * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows for
+ * tsk, mm to be specified.
  *
  * NOTE: here FOLL_TOUCH is not set implicitly and must be set by the
- * caller if required (just like with __get_user_pages). "FOLL_GET",
- * "FOLL_WRITE" and "FOLL_FORCE" are set implicitly as needed
- * according to the parameters "pages", "write", "force"
- * respectively.
+ * caller if required (just like with __get_user_pages). "FOLL_GET"
+ * is set implicitly if "pages" is non-NULL.
  */
 __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 					       unsigned long start, unsigned long nr_pages,
@@ -894,10 +892,8 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
  *      get_user_pages_unlocked(tsk, mm, ..., pages);
  *
  * It is functionally equivalent to get_user_pages_fast so
- * get_user_pages_fast should be used instead, if the two parameters
- * "tsk" and "mm" are respectively equal to current and current->mm,
- * or if "force" shall be set to 1 (get_user_pages_fast misses the
- * "force" parameter).
+ * get_user_pages_fast should be used instead if specific gup_flags
+ * (e.g. FOLL_FORCE) are not required.
  */
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
