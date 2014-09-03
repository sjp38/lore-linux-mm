Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CF2CB6B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 18:26:22 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so2715849pdj.14
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 15:26:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rn15si13694602pab.76.2014.09.03.15.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 15:26:21 -0700 (PDT)
Date: Wed, 3 Sep 2014 15:26:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 251/287] lib/test-string_helpers.c:293:1:
 warning: the frame size of 1316 bytes is larger than 1024 bytes
Message-Id: <20140903152619.c26f0c7b9031a1d39d729fab@linux-foundation.org>
In-Reply-To: <54010c8c.wA2PyooCbGtrpuaG%fengguang.wu@intel.com>
References: <54010c8c.wA2PyooCbGtrpuaG%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Sat, 30 Aug 2014 07:28:12 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
> commit: 626105764fd29c75bd8b01d36b54d0aaca61ac36 [251/287] lib / string_helpers: introduce string_escape_mem()
> config: make ARCH=i386 allyesconfig
> 
> All warnings:
> 
>    lib/test-string_helpers.c: In function 'test_string_escape':
> >> lib/test-string_helpers.c:293:1: warning: the frame size of 1316 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>     }

1k isn't excessive for an __init function but I guess we should fix it
to avoid drawing attention to ourselves.

Andy, please review, test, etc?


I figure the out-of-memory warning means we don't need a warning
printk.  It won't happen anyway.


--- a/lib/test-string_helpers.c~lib-string_helpers-introduce-string_escape_mem-fix
+++ a/lib/test-string_helpers.c
@@ -5,6 +5,7 @@
 
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/random.h>
 #include <linux/string.h>
@@ -62,10 +63,14 @@ static const struct test_string strings[
 static void __init test_string_unescape(const char *name, unsigned int flags,
 					bool inplace)
 {
-	char in[256];
-	char out_test[256];
-	char out_real[256];
-	int i, p = 0, q_test = 0, q_real = sizeof(out_real);
+	int q_real = 256;
+	char *in = kmalloc(q_real, GFP_KERNEL);
+	char *out_test = kmalloc(q_real, GFP_KERNEL);
+	char *out_real = kmalloc(q_real, GFP_KERNEL);
+	int i, p = 0, q_test = 0;
+
+	if (!in || !out_test || !out_real)
+		goto out;
 
 	for (i = 0; i < ARRAY_SIZE(strings); i++) {
 		const char *s = strings[i].in;
@@ -100,6 +105,10 @@ static void __init test_string_unescape(
 
 	test_string_check_buf(name, flags, in, p - 1, out_real, q_real,
 			      out_test, q_test);
+out:
+	kfree(out_real);
+	kfree(out_test);
+	kfree(in);
 }
 
 struct test_string_1 {
@@ -255,10 +264,15 @@ static __init void test_string_escape(co
 				      const struct test_string_2 *s2,
 				      unsigned int flags, const char *esc)
 {
-	char in[256];
-	char out_test[512];
-	char out_real[512], *buf = out_real;
-	int p = 0, q_test = 0, q_real = sizeof(out_real);
+	int q_real = 512;
+	char *out_test = kmalloc(q_real, GFP_KERNEL);
+	char *out_real = kmalloc(q_real, GFP_KERNEL);
+	char *in = kmalloc(256, GFP_KERNEL);
+	char *buf = out_real;
+	int p = 0, q_test = 0;
+
+	if (!out_test || !out_real || !in)
+		goto out;
 
 	for (; s2->in; s2++) {
 		const char *out;
@@ -289,7 +303,12 @@ static __init void test_string_escape(co
 
 	q_real = string_escape_mem(in, p, &buf, q_real, flags, esc);
 
-	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test, q_test);
+	test_string_check_buf(name, flags, in, p, out_real, q_real, out_test,
+			      q_test);
+out:
+	kfree(in);
+	kfree(out_real);
+	kfree(out_test);
 }
 
 static __init void test_string_escape_nomem(void)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
