Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 178766B026C
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:30:56 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id 18so4705376qtt.10
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:30:56 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y9si4507278qkl.441.2017.11.17.14.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:30:55 -0800 (PST)
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH 5/5] mm/kasan: add advanced check test case
Date: Fri, 17 Nov 2017 14:30:43 -0800
Message-Id: <20171117223043.7277-6-wen.gang.wang@oracle.com>
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: wen.gang.wang@oracle.com, glider@google.com, dvyukov@google.com

This patch is for Kasan advanced check feature.
It adds the advanced check test case in lib/test_kasan.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index a25c976..0ff0101 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -473,6 +473,78 @@ static noinline void __init use_after_scope_test(void)
 	p[1023] = 1;
 }
 
+static noinline void funcA(char *addr)
+{
+	*addr = 'A';
+}
+
+static noinline void funcB(char *addr)
+{
+	*addr = 'B';
+}
+
+static noinline void funcC(char *addr)
+{
+	*addr = 'C';
+}
+
+static noinline void __init kasan_adv(void)
+{
+	struct kasan_owner_set set;
+	int check, ret;
+	char *p;
+
+	pr_info("kasan: advanced check\n");
+
+	set.s_nr = 2;
+	set.s_ptrs[0] = (void *)funcA;
+	set.s_ptrs[1] = (void *)funcC;
+	check = kasan_register_adv_check(KASAN_ADVCHK_OWNER, &set);
+	if (check <= 0) {
+		pr_err("kasan_register_adv_check failedd with %d\n", check);
+		return;
+	}
+
+	p = kmalloc(62, GFP_KERNEL);
+	if (!p) {
+		pr_err("kmalloc failed with 62 bytes request\n");
+		return;
+	}
+
+	ret = kasan_bind_adv_addr(p, 32, check);
+	if (ret < 0) {
+		pr_err("kasan_bind_adv_addr failed with %d\n", ret);
+		kfree(p);
+		return;
+	}
+
+	funcA(&p[12]);
+	funcB(&p[12]);
+	funcC(&p[12]);
+
+	set.s_nr = 1;
+	set.s_ptrs[0] = (void *)funcA;
+
+	check = kasan_register_adv_check(KASAN_ADVCHK_OWNER, &set);
+	if (check <= 0) {
+		pr_err("kasan_register_adv_check failed with %d\n", check);
+		kfree(p);
+		return;
+	}
+
+	ret = kasan_bind_adv_addr(p+32, 30, check);
+	if (ret < 0) {
+		pr_err("kasan_bind_adv_addr failed with %d\n", ret);
+		kfree(p);
+		return;
+	}
+
+	funcA(&p[42]);
+	funcB(&p[42]);
+	funcC(&p[42]);
+
+	kfree(p);
+}
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -506,6 +578,7 @@ static int __init kmalloc_tests_init(void)
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
+	kasan_adv();
 
 	kasan_restore_multi_shot(multishot);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
