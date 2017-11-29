Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44E86B0260
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:51:16 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b11so4259352itj.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:51:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e134sor1783008ita.93.2017.11.29.13.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 13:51:15 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v2 2/5] kasan: Add tests for alloca poisonong
Date: Wed, 29 Nov 2017 13:50:47 -0800
Message-Id: <20171129215050.158653-3-paullawrence@google.com>
In-Reply-To: <20171129215050.158653-1-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>

 lib/test_kasan.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index ef1a3ac1397e..2724f86c4cef 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -472,6 +472,26 @@ static noinline void __init use_after_scope_test(void)
 	p[1023] = 1;
 }
 
+static noinline void __init kasan_alloca_oob_left(void)
+{
+	volatile int i = 10;
+	char alloca_array[i];
+	char *p = alloca_array - 1;
+
+	pr_info("out-of-bounds to left on alloca\n");
+	*(volatile char *)p;
+}
+
+static noinline void __init kasan_alloca_oob_right(void)
+{
+	volatile int i = 10;
+	char alloca_array[i];
+	char *p = alloca_array + i;
+
+	pr_info("out-of-bounds to right on alloca\n");
+	*(volatile char *)p;
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -502,6 +522,8 @@ static int __init kmalloc_tests_init(void)
 	memcg_accounted_kmem_cache();
 	kasan_stack_oob();
 	kasan_global_oob();
+	kasan_alloca_oob_left();
+	kasan_alloca_oob_right();
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
