Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEA30C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774D42085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FHR6usGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774D42085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28F1F6B0006; Tue, 14 May 2019 10:36:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F1076B0007; Tue, 14 May 2019 10:36:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF196B0008; Tue, 14 May 2019 10:36:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF1BA6B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:36:05 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id v127so31297297ywb.20
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:36:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=B56NDtOL5xZxqPmoBf4XKPM0hIbi/G3vgoZpQOkU934=;
        b=O1OIHISuG5yqkJiuxH3A+HEDwJS0xeZs9IVyqCt9uArbFeoqPFZVjf0/z9Zm5QS41N
         trBjeZGT9iWXqbjR9EtLk/0jbnM7vYknDrClGD65VjOdFM1yEeVfuqpqFuMTjDDfNDYp
         RrIVvpM6gm+ZwO5HrM735yPcvoQIe5bLx5j7LBm8IAU+QQMSSMJIA11Syvcfha7FdORk
         zEd3blORQ9J6DSZrQLgUV2mp8ke/01ysqMa/8WDFoA9Ah+BkWE1Q/mHLV/aB8iuE7yBb
         nSEmVBZnwiB6ijv7yvHi/I4WU39Cs54sv3l8aOwxV7VbqbXbjQqjlyw+oxZBZ20l4PL0
         elhQ==
X-Gm-Message-State: APjAAAVeKmeyI44TjjQ0bU1UPPTN+0ypRGv3tke2+RTCnl9Pn84FvFoR
	tuGWhOlKO9mQTEVuqe9xO8P5C48hQ/+AAwydfYlE9Ppwntm2ftonLp9kHoIusnIuzbr9pEef+Pn
	rXJsVYJYog35TcdSSnEmyhrcvtSOBG278fpqFxZb0JAyUJtLKFlGPSHOh56f7ieLSIQ==
X-Received: by 2002:a81:5214:: with SMTP id g20mr16976447ywb.365.1557844565625;
        Tue, 14 May 2019 07:36:05 -0700 (PDT)
X-Received: by 2002:a81:5214:: with SMTP id g20mr16976396ywb.365.1557844564894;
        Tue, 14 May 2019 07:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844564; cv=none;
        d=google.com; s=arc-20160816;
        b=pT2zHg+MiiQ3Y3Yme2vldZDKiqQK0LsX8m/lWrvqWa3VwWgh2joOnYj/3Uu7vmklYt
         wJmUUOFrIg6kvXNtkHmzoVBHbYX7L265tCW3f5fKs9Jo76ZQ2JxSNit1Wb/NErz9ZASu
         BN3T4btXstfF0U5R4nx8i5evT/8t7cghHhhZJRluDYwPhfYBLcMvzYLNtn1InKNXTYZ7
         2+EUuuhNEk+za+49H5s3BaQry2PuKSS1MOXiay5nYpHobbzl6Z9vwo3jJNicHQPuUOlF
         392pt6RB6TT/aNRA5gRLWCDmHleyussj97vWdOyddmPps8nr3j9Gk6pLI7hWy8qxriRe
         kV4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=B56NDtOL5xZxqPmoBf4XKPM0hIbi/G3vgoZpQOkU934=;
        b=OTE1aN3+e3S2Qw6tUV5GRwkbYmILNqjgCoarDVPAYKWmhooLr7Wy5SoKxY4ppNe6BO
         nAr3CKQzNc7nWdm0qbOhNP03J/Rgz24OJPmWqBR/rWEfyMd+SmjRWHVcMFjBvWUJ49Ob
         C8pvHTmsCZI9WUf8yRQxevfI/JUrQuBAo8/1PTQoerp4Nn7VkfIl9nmFYju+j+CEv8LK
         tGr9nCd4reLesnVZt5SdIu7ArTG6w0fwZi5Z2vZ0CPZC4DoVAuH99u2+wD8hHogCWtNI
         oozgIwhAvh5FrLx4DFWcgiNAgHyoTuvqYpQKSDS0Vl7cUrFd6bMnT+qLVONmXzYhhj+R
         LAdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FHR6usGJ;
       spf=pass (google.com: domain of 3vnlaxaykcfez41wxaz77z4x.v75416dg-553etv3.7az@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VNLaXAYKCFEz41wxAz77z4x.v75416DG-553Etv3.7Az@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 74sor8151621ywp.167.2019.05.14.07.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 07:36:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vnlaxaykcfez41wxaz77z4x.v75416dg-553etv3.7az@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FHR6usGJ;
       spf=pass (google.com: domain of 3vnlaxaykcfez41wxaz77z4x.v75416dg-553etv3.7az@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VNLaXAYKCFEz41wxAz77z4x.v75416DG-553Etv3.7Az@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=B56NDtOL5xZxqPmoBf4XKPM0hIbi/G3vgoZpQOkU934=;
        b=FHR6usGJshdPyEV8Aak1BgcwnljqtriHJkgj5J2aYlmLYw4AidY6SxiAGKzPI6heGk
         M7s4k+7pcnSrJZaLLKZgghkGGT/JmXsDUr+smqm13C/NSTZ/qTLK7V/WoT+FYxSlhMmU
         h5INfaZnRIBMAtH7ivc/Ax9f1GJRcH+Ip7kZBMi+4qux53yuZc3BYyOVNFfnnoDvD7BP
         5MJZ6n5EequqoW63YBpjaXn0du8xnOhQkd34Pyjz4i3iNz7iQfgQ8AgLqI81tuxaPGBi
         6t8ZG+QZQZdizKlEiyFBZm32K+OiwvVqYEV8p+T6KSyE6w3DTDweXhdIyDkmLE5xF2ow
         cAxg==
X-Google-Smtp-Source: APXvYqzaMJGf9ZwPtTAOK12Dhjk0gPbDIoj+2PJs7jr1TXz7qsRVrx7qy+Q3P9umvaEiKNqB4jAt38BOZ9c=
X-Received: by 2002:a81:35cc:: with SMTP id c195mr16506221ywa.311.1557844564255;
 Tue, 14 May 2019 07:36:04 -0700 (PDT)
Date: Tue, 14 May 2019 16:35:35 +0200
In-Reply-To: <20190514143537.10435-1-glider@google.com>
Message-Id: <20190514143537.10435-3-glider@google.com>
Mime-Version: 1.0
References: <20190514143537.10435-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2 2/4] lib: introduce test_meminit module
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add tests for heap and pagealloc initialization.
These can be used to check init_on_alloc and init_on_free implementations
as well as other approaches to initialization.

Signed-off-by: Alexander Potapenko <glider@google.com>
To: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Jann Horn <jannh@google.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 lib/Kconfig.debug  |   8 ++
 lib/Makefile       |   1 +
 lib/test_meminit.c | 205 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 214 insertions(+)
 create mode 100644 lib/test_meminit.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d695ec1477f3..6c3fc68a4a77 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2020,6 +2020,14 @@ config TEST_STACKINIT
 
 	  If unsure, say N.
 
+config TEST_MEMINIT
+	tristate "Test level of heap/page initialization"
+	help
+	  Test if the kernel is zero-initializing heap and page allocations.
+	  This can be useful to test init_on_alloc and init_on_free features.
+
+	  If unsure, say N.
+
 endif # RUNTIME_TESTING_MENU
 
 config MEMTEST
diff --git a/lib/Makefile b/lib/Makefile
index 83d7df2661ff..29c5afbe9882 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -91,6 +91,7 @@ obj-$(CONFIG_TEST_DEBUG_VIRTUAL) += test_debug_virtual.o
 obj-$(CONFIG_TEST_MEMCAT_P) += test_memcat_p.o
 obj-$(CONFIG_TEST_OBJAGG) += test_objagg.o
 obj-$(CONFIG_TEST_STACKINIT) += test_stackinit.o
+obj-$(CONFIG_TEST_MEMINIT) += test_meminit.o
 
 obj-$(CONFIG_TEST_LIVEPATCH) += livepatch/
 
diff --git a/lib/test_meminit.c b/lib/test_meminit.c
new file mode 100644
index 000000000000..67d759498030
--- /dev/null
+++ b/lib/test_meminit.c
@@ -0,0 +1,205 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Test cases for SL[AOU]B/page initialization at alloc/free time.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+#define GARBAGE_INT (0x09A7BA9E)
+#define GARBAGE_BYTE (0x9E)
+
+#define REPORT_FAILURES_IN_FN() \
+	do {	\
+		if (failures)	\
+			pr_info("%s failed %d out of %d times\n",	\
+				__func__, failures, num_tests);		\
+		else		\
+			pr_info("all %d tests in %s passed\n",		\
+				num_tests, __func__);			\
+	} while (0)
+
+/* Calculate the number of uninitialized bytes in the buffer. */
+static int count_nonzero_bytes(void *ptr, size_t size)
+{
+	int i, ret = 0;
+	unsigned char *p = (unsigned char *)ptr;
+
+	for (i = 0; i < size; i++)
+		if (p[i])
+			ret++;
+	return ret;
+}
+
+static void fill_with_garbage(void *ptr, size_t size)
+{
+	unsigned int *p = (unsigned int *)ptr;
+	int i = 0;
+
+	while (size >= sizeof(*p)) {
+		p[i] = GARBAGE_INT;
+		i++;
+		size -= sizeof(*p);
+	}
+	if (size)
+		memset(&p[i], GARBAGE_BYTE, size);
+}
+
+static int __init do_alloc_pages_order(int order, int *total_failures)
+{
+	struct page *page;
+	void *buf;
+	size_t size = PAGE_SIZE << order;
+
+	page = alloc_pages(GFP_KERNEL, order);
+	buf = page_address(page);
+	fill_with_garbage(buf, size);
+	__free_pages(page, order);
+
+	page = alloc_pages(GFP_KERNEL, order);
+	buf = page_address(page);
+	if (count_nonzero_bytes(buf, size))
+		(*total_failures)++;
+	fill_with_garbage(buf, size);
+	__free_pages(page, order);
+	return 1;
+}
+
+static int __init test_pages(int *total_failures)
+{
+	int failures = 0, num_tests = 0;
+	int i;
+
+	for (i = 0; i < 10; i++)
+		num_tests += do_alloc_pages_order(i, &failures);
+
+	REPORT_FAILURES_IN_FN();
+	*total_failures += failures;
+	return num_tests;
+}
+
+static int __init do_kmalloc_size(size_t size, int *total_failures)
+{
+	void *buf;
+
+	buf = kmalloc(size, GFP_KERNEL);
+	fill_with_garbage(buf, size);
+	kfree(buf);
+
+	buf = kmalloc(size, GFP_KERNEL);
+	if (count_nonzero_bytes(buf, size))
+		(*total_failures)++;
+	fill_with_garbage(buf, size);
+	kfree(buf);
+	return 1;
+}
+
+static int __init do_vmalloc_size(size_t size, int *total_failures)
+{
+	void *buf;
+
+	buf = vmalloc(size);
+	fill_with_garbage(buf, size);
+	vfree(buf);
+
+	buf = vmalloc(size);
+	if (count_nonzero_bytes(buf, size))
+		(*total_failures)++;
+	fill_with_garbage(buf, size);
+	vfree(buf);
+	return 1;
+}
+
+static int __init test_kvmalloc(int *total_failures)
+{
+	int failures = 0, num_tests = 0;
+	int i, size;
+
+	for (i = 0; i < 20; i++) {
+		size = 1 << i;
+		num_tests += do_kmalloc_size(size, &failures);
+		num_tests += do_vmalloc_size(size, &failures);
+	}
+
+	REPORT_FAILURES_IN_FN();
+	*total_failures += failures;
+	return num_tests;
+}
+
+#define CTOR_BYTES 4
+/* Initialize the first 4 bytes of the object. */
+void some_ctor(void *obj)
+{
+	memset(obj, 'A', CTOR_BYTES);
+}
+
+static int __init do_kmem_cache_size(size_t size, bool want_ctor,
+				     int *total_failures)
+{
+	struct kmem_cache *c;
+	void *buf;
+	int iter, bytes = 0;
+	int fail = 0;
+
+	c = kmem_cache_create("test_cache", size, 1, 0,
+			      want_ctor ? some_ctor : NULL);
+	for (iter = 0; iter < 10; iter++) {
+		buf = kmem_cache_alloc(c, GFP_KERNEL);
+		if (!want_ctor || iter == 0)
+			bytes = count_nonzero_bytes(buf, size);
+		if (want_ctor) {
+			/*
+			 * Newly initialized memory must be initialized using
+			 * the constructor.
+			 */
+			if (iter == 0 && bytes < CTOR_BYTES)
+				fail = 1;
+		} else {
+			if (bytes)
+				fail = 1;
+		}
+		fill_with_garbage(buf, size);
+		kmem_cache_free(c, buf);
+	}
+	kmem_cache_destroy(c);
+
+	*total_failures += fail;
+	return 1;
+}
+
+static int __init test_kmemcache(int *total_failures)
+{
+	int failures = 0, num_tests = 0;
+	int i, size;
+
+	for (i = 0; i < 10; i++) {
+		size = 4 << i;
+		num_tests += do_kmem_cache_size(size, false, &failures);
+		num_tests += do_kmem_cache_size(size, true, &failures);
+	}
+	REPORT_FAILURES_IN_FN();
+	*total_failures += failures;
+	return num_tests;
+}
+
+static int __init test_meminit_init(void)
+{
+	int failures = 0, num_tests = 0;
+
+	num_tests += test_pages(&failures);
+	num_tests += test_kvmalloc(&failures);
+	num_tests += test_kmemcache(&failures);
+
+	if (failures == 0)
+		pr_info("all %d tests passed!\n", num_tests);
+	else
+		pr_info("failures: %d out of %d\n", failures, num_tests);
+
+	return failures ? -EINVAL : 0;
+}
+module_init(test_meminit_init);
-- 
2.21.0.1020.gf2820cf01a-goog

