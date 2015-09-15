Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0726C6B025E
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:09:16 -0400 (EDT)
Received: by lagj9 with SMTP id j9so109926753lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:15 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id g3si13873140lag.57.2015.09.15.07.09.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:09:15 -0700 (PDT)
Received: by lbbvu2 with SMTP id vu2so13637919lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:14 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 07/10] mm/mlock: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:17 +0600
Message-Id: <1442326097-7493-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 25936680..e86206b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -560,7 +560,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	struct vm_area_struct * vma, * prev;
 	int error;
 
-	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(offset_in_page(start));
 	VM_BUG_ON(len != PAGE_ALIGN(len));
 	end = start + len;
 	if (end < start)
@@ -616,7 +616,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 	lru_add_drain_all();	/* flush pagevec */
 
-	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
+	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
@@ -645,7 +645,7 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
 
-	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
+	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
 	down_write(&current->mm->mmap_sem);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
