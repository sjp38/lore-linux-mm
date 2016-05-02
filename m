Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD55B6B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 01:36:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t140so110881619oie.0
        for <linux-mm@kvack.org>; Sun, 01 May 2016 22:36:54 -0700 (PDT)
Received: from out1134-201.mail.aliyun.com (out1134-201.mail.aliyun.com. [42.120.134.201])
        by mx.google.com with ESMTP id ke3si17268211igc.21.2016.05.01.22.36.43
        for <linux-mm@kvack.org>;
        Sun, 01 May 2016 22:36:54 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH] include/linux/kasan.h: Notice about 0 for kasan_[dis/en]able_current()
Date: Mon,  2 May 2016 13:35:48 +0800
Message-Id: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

According to their comments and the kasan_depth's initialization, if
kasan_depth is zero, it means disable. So kasan_depth need consider
about the 0 overflow.

Also remove useless comments for dummy kasan_slab_free().

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 include/linux/kasan.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 645c280..37fab04 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -32,13 +32,15 @@ static inline void *kasan_mem_to_shadow(const void *addr)
 /* Enable reporting bugs after kasan_disable_current() */
 static inline void kasan_enable_current(void)
 {
-	current->kasan_depth++;
+	if (current->kasan_depth + 1)
+		current->kasan_depth++;
 }
 
 /* Disable reporting bugs for current task */
 static inline void kasan_disable_current(void)
 {
-	current->kasan_depth--;
+	if (current->kasan_depth)
+		current->kasan_depth--;
 }
 
 void kasan_unpoison_shadow(const void *address, size_t size);
@@ -113,8 +115,6 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags) {}
-/* kasan_slab_free() returns true if the object has been put into quarantine.
- */
 static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
 {
 	return false;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
