Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 945316B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 21:58:07 -0400 (EDT)
Received: by laeb10 with SMTP id b10so18817077lae.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 18:58:06 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id wc4si8756316lbb.123.2015.09.09.18.58.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 18:58:06 -0700 (PDT)
Received: by lagj9 with SMTP id j9so18761006lag.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 18:58:05 -0700 (PDT)
From: Alexey Klimov <klimov.linux@gmail.com>
Subject: [PATCH] syscall/mlockall: reorganize return values and remove goto-out label
Date: Thu, 10 Sep 2015 04:57:58 +0300
Message-Id: <1441850278-11173-1-git-send-email-klimov.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, jeffv@google.com, kirill.shutemov@linux.intel.com, rientjes@google.com, akpm@linux-foundation.org, alexey.klimov@linaro.org, yury.norov@gmail.com, Alexey Klimov <klimov.linux@gmail.com>

In mlockall syscall wrapper after out-label for goto code
just doing return. Remove goto out statements and return error
values directly.
Also instead of rewriting ret variable before every if-check
move returns to 'error'-like path under if-check.

Objdump asm listing showed me reducing by few asm lines.
Object file size descreased from 220592 bytes to 220528 bytes
for me (for aarch64).

Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>
---
 mm/mlock.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 25936680..7e6ad9c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -684,14 +684,13 @@ out:
 SYSCALL_DEFINE1(mlockall, int, flags)
 {
 	unsigned long lock_limit;
-	int ret = -EINVAL;
+	int ret;
 
 	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
-		goto out;
+		return -EINVAL;
 
-	ret = -EPERM;
 	if (!can_do_mlock())
-		goto out;
+		return -EPERM;
 
 	if (flags & MCL_CURRENT)
 		lru_add_drain_all();	/* flush pagevec */
@@ -708,7 +707,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	up_write(&current->mm->mmap_sem);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
-out:
+
 	return ret;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
