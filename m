Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ECF3C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3197921019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c4PTxt6G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3197921019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38626B0008; Thu, 23 May 2019 08:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC1E46B000A; Thu, 23 May 2019 08:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A14386B000C; Thu, 23 May 2019 08:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA8A6B0008
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:42:40 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p123so399236ywg.3
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:42:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=cGzzvH76bZ+iUMGoZzQpcXslOQHBydL2jGnhYsqex16wLuGSuwhebvq1WKk9aLdfk+
         Pn7rpwBO3PobPRiuyH0UxIYjVwAApflXio+/0aPyHsfKtGm19p7YAhNaJZfonWekaNao
         ZNKFKE5d7k/6kLHwnWi+w7MUxc7GsdwWiPUHTHC5mxxl/kqlejI1XDRTjvF6W3a/XwF/
         cDxfgWo5E854iuwDo4m8kTOZF4tHfO0GCWE9zDr7fnTWqvIECLVreVEbAHIZHeXZ7A1u
         6b2DmK437/kMHlzxvkIoSt6ZRGO8bRcRMBwdOzkAK+axooR4V1DTGXivrhMlVcS47sjx
         L7Tw==
X-Gm-Message-State: APjAAAUu2OGAZSmcG7cGQOYPyb2ykEntazHiJQHiHRrk3bRUzXQgXed7
	fWnEzOk5y/t2rCaldXrLZzzbcKUllit7zfSp0kzIJ1fTJ3oKmD7/8tOCSTs9k5/CTA/UJS0bQcy
	LF/ePJN+Laojt+4X0ZdKqJwi245jHYEOdoKXwaZjpEEXdv9/F36qoWGTEsCj8H7GQeg==
X-Received: by 2002:a25:390:: with SMTP id 138mr595613ybd.404.1558615360210;
        Thu, 23 May 2019 05:42:40 -0700 (PDT)
X-Received: by 2002:a25:390:: with SMTP id 138mr595588ybd.404.1558615359493;
        Thu, 23 May 2019 05:42:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615359; cv=none;
        d=google.com; s=arc-20160816;
        b=TUJ5cLcW5eUA2WZ11w48nzBYVr291IXW6UbTWs6KdYuCMtyqd7pHwJLBMg/MdiEDhu
         5jMqQM93M1MH6i2Ny6rS9DplsCRshM+cRFwopS/GbMj1tsEj35j1TIpiAfOODVUH6zRg
         YjfWNzNZJfi6CyjlPKzqMQshKBWBmjgQxFN3xKenz4MgxRMwK6Poa1KMg0GF3mfxBtLU
         vPC/G3O+rOr/nhAVChOjNJS3YfbfVXD4T3u1Y38jLRxHinrHsTN9LScpqt34Ax9iVFGX
         L51Sd+9qLu1wjqmE0E/IuCIABcCN1HQhf0C8zlSPOXBxDubyOdpC3OglvYUPaKzi0bUF
         DHbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=uyCPF/zICzHnQBImgkLmbphz92ti5VUTIFoYzzwA60ouSgEFf70sRPdUTVCUyGDfJu
         BCR5dFc2hRUnDwrg7hDHlHNIKeK/P9iiVOprwagvfOGMymZ2mYSdkmi9X8/twT0n1nwU
         9/MfIZJW4t9E+6PALqPGbHDcJ0dM+0G/ihXUlgZd0o9OwJYvL+NbMcNrlzgTaIIUv+Ea
         TX930c3RJokCRs2lkTrqIYC0R7SrhuFpfihdKmgjuQ3PHCoaP5z0rRViodKoqlljD5ol
         j4EPRxn7yQXWiMF8PY/YJOs7yGJyxv+CkIt2rmVDdkV4F/9OZf9UN4Wlz4FiGmZH6iBE
         BgGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c4PTxt6G;
       spf=pass (google.com: domain of 3p5xmxaykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3P5XmXAYKCPAYdaVWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w18sor3520337ybs.55.2019.05.23.05.42.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 05:42:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3p5xmxaykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=c4PTxt6G;
       spf=pass (google.com: domain of 3p5xmxaykcpaydavwjyggydw.ugedafmp-eecnsuc.gjy@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3P5XmXAYKCPAYdaVWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=c4PTxt6GbbkKh29sih5enoKVGyMiYVYDStyGmFdx5QefGnvHTake1qlrYrHoHEQrCE
         ++1kksetXbRrLBsUzGoBPVIMAAMNahTmjf785FIERAu9VEACDN6Dz1mlWOxOGpbeA7pb
         j/fU9z5gy2GIxuhbsTrOsbsC5W7GBJTGTn7dwa9/LCuRdsWwyAmoyq3PDyg5GU2ug5s+
         HLYCxfheuLXUX4xre/bvMAurMTrcffJpEMMKp+j6Wtq8qnswrfxvwcbQ75DKYA0YMApY
         vroFWYFkyIu9Htfdesto2WrVrIfrGq7SCiUXYBDLUYAih13Eo2rIPWIc+nwn32ib129k
         jpNw==
X-Google-Smtp-Source: APXvYqx6+4Lx9KEyyCmocn+ERDYmrBvW59FCcdrGthGBmVTyeg7hNq7ggY14xUbi5JovTOJdj/wBvcGas8A=
X-Received: by 2002:a5b:888:: with SMTP id e8mr12252456ybq.505.1558615359109;
 Thu, 23 May 2019 05:42:39 -0700 (PDT)
Date: Thu, 23 May 2019 14:42:16 +0200
In-Reply-To: <20190523124216.40208-1-glider@google.com>
Message-Id: <20190523124216.40208-4-glider@google.com>
Mime-Version: 1.0
References: <20190523124216.40208-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 3/3] lib: introduce test_meminit module
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add tests for heap and pagealloc initialization.
These can be used to check init_on_alloc and init_on_free implementations
as well as other approaches to initialization.

Expected test output in the case the kernel provides heap initialization
(e.g. when running with either init_on_alloc=1 or init_on_free=1):

  test_meminit: all 10 tests in test_pages passed
  test_meminit: all 40 tests in test_kvmalloc passed
  test_meminit: all 20 tests in test_kmemcache passed
  test_meminit: all 70 tests passed!

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
 v3:
  - added example test output to the description
  - fixed a missing include spotted by kbuild test robot <lkp@intel.com>
  - added a missing MODULE_LICENSE
  - call do_kmem_cache_size() with size >= sizeof(void*) to unbreak
  debug builds
---
 lib/Kconfig.debug  |   8 ++
 lib/Makefile       |   1 +
 lib/test_meminit.c | 208 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 217 insertions(+)
 create mode 100644 lib/test_meminit.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index fdfa173651eb..036e8ef03831 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2043,6 +2043,14 @@ config TEST_STACKINIT
 
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
index fb7697031a79..05980c802500 100644
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
index 000000000000..d46e2b8c8e8e
--- /dev/null
+++ b/lib/test_meminit.c
@@ -0,0 +1,208 @@
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
+#include <linux/vmalloc.h>
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
+		size = 8 << i;
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
+
+MODULE_LICENSE("GPL");
-- 
2.21.0.1020.gf2820cf01a-goog

