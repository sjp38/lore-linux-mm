Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A35C5C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 594EA21530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="V6RgUx/U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 594EA21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB9126B02C0; Wed,  8 May 2019 11:38:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1B586B02C1; Wed,  8 May 2019 11:38:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D306E6B02C2; Wed,  8 May 2019 11:38:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A95536B02C0
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:38:20 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k90so11231829otk.21
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=VmHYFv+F99NJ5GAkPbTyJyR0t7BgQjeUOj8lTClHhDU=;
        b=c8NfSDhxgCSUDBA6gAXbWOP6YzVOiur3QMDfAodUCP68mdZrbbNSmmQUwir2Vo6FlU
         1YcTVJJkACsniGPgGjZb2Bs9AHtHWSriPoSALNZBdCKto1X0ZBwwJFnBeOWjWNVCv+r8
         psrEdCEXWb/LpWLZYEgoF8HwsvEpMbSl47VxJQThSnNgMFU9NXpXgf+sbbEKYazJ1d4+
         Ju3Zz803cVKmh5joSMqjxlvpRMFgh3M22w1be/Rxo5LS4vV0y+JXqFfFX/fcPFAjC16+
         9IfdNVqvWkn4ceusZk0nb/cO9FflnHeEuTJZwQ3zycJyiGCl35vrqfosFSf3hM4s6/yg
         MDdQ==
X-Gm-Message-State: APjAAAU0vUH43JGD24OV4PwpRuyVUKgwDYnoFG/JcmXI3Rj7HGhofgoi
	6WFkjqS+IYTVikg/Nk2l78gVkFwgOSLiygwEeZrcJI1tmgMPdJHwi92QKWOcdsFckvaHObiqcIP
	ureEV53JI3ZpePbP+O+yj/R4jqcgP+dOuZBAq1SoJR80MRrI9LxIFcQD0ALJyXCgbxg==
X-Received: by 2002:a05:6830:1385:: with SMTP id d5mr9086498otq.163.1557329900383;
        Wed, 08 May 2019 08:38:20 -0700 (PDT)
X-Received: by 2002:a05:6830:1385:: with SMTP id d5mr9086462otq.163.1557329899561;
        Wed, 08 May 2019 08:38:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557329899; cv=none;
        d=google.com; s=arc-20160816;
        b=wuKcB3mNVrZJA8qzYbiK2rdXeGTqE3pr5UaRg1VSToR8okQUfxrQEYx9iPERQX+juT
         gygcRiue88IIhRBLbEZNYycpkHikk3drtLiIO2icGiJEA1bIU8jLhNZ4ZFP/o88zM0rZ
         RfBvz0ozAjbvpVZGWO9SXULjfvzUhm/8s7QHi8x90rO4YJLc9iH+WTgRnU7SUQBQRw61
         rDdhEQnb6oE6E/H6yRI8n+hEddZicI5HCHSkJlaINNDOLfApuVTIG49rUjqCkoBRyfP+
         f0V2mF+K9T8IWADHE66tTFKBHdtIDJQhOe2CzG3Wr3j10ggu0UYeLK4KTyObTsauOI0X
         nNEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=VmHYFv+F99NJ5GAkPbTyJyR0t7BgQjeUOj8lTClHhDU=;
        b=UkWxXORI1lxwX+DG9xNiZogc2KC0xaMNOxBEMP4liT4tsuHLM9I19qY1cX51iKnI/O
         kqcnjgr1hs/9fw21XTr4kv5/ce17aDw6fP2vL5faSjfPrJsNNaRjlZ7eJnvz/EtIer37
         xIdMzqqFZXaHZk4rR3rD7+Yc/pcBddgjBAU6fT+gbVOT3ncb8FSr6+0TIgJtPkJXLcML
         j7ZK6Krlwyq/IJfv+Xxr57nrMsbcdUHZtjWZzys9eiyDmxE4nyo6K1fmXf2g/Vr5ZlJx
         3KetGGl9DQuPjjgo1azgS0Bg65Z32sBHYiZtxFRp422uu3DUrj5VFdrEDzcXVG8rvP94
         y6pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="V6RgUx/U";
       spf=pass (google.com: domain of 36_fsxaykcbq052xyb08805y.w86527eh-664fuw4.8b0@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36_fSXAYKCBQ052xyB08805y.w86527EH-664Fuw4.8B0@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v6sor6966575oic.136.2019.05.08.08.38.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 08:38:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of 36_fsxaykcbq052xyb08805y.w86527eh-664fuw4.8b0@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="V6RgUx/U";
       spf=pass (google.com: domain of 36_fsxaykcbq052xyb08805y.w86527eh-664fuw4.8b0@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36_fSXAYKCBQ052xyB08805y.w86527EH-664Fuw4.8B0@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=VmHYFv+F99NJ5GAkPbTyJyR0t7BgQjeUOj8lTClHhDU=;
        b=V6RgUx/U1VBKqv6Y0GOzPs5293yWXA+JzDDYWYcMGH7PR6fGSpATnshwWJc65r86tm
         evjI4NnaHCXmyFSjPA2e4uhU8mgDmCf1052LmTGATOGwhrRMGtGcb+fDUqAJuIDBAjVw
         cqOtuxMN0hb/KQRV6cHlZ77qWslLhSK31gxj4DT7vtxBA0jHyPxEeDBU96dFhJrzOqW2
         M5QgDxVrTjPSvp2y4EiKVuyl8XBlbHnEkWf58VXDFxeAbNhQIkVEKgdaPxc48yETlgZ0
         8jPZOj4j9VauKtfpH2JNvL7Zk/Tfsvk5YzTBWk6KmvN43ytEvGQdAUf/jONOu3T56/LD
         qKCQ==
X-Google-Smtp-Source: APXvYqx8p4G+pkm0Fz12Uy1bJ0ErL1+MdGYtfHtwmRe+Z/ufjKBFrUj79maLbYIhnXca1ZR0nPwliHvzGpM=
X-Received: by 2002:a54:478a:: with SMTP id o10mr2745917oic.158.1557329899101;
 Wed, 08 May 2019 08:38:19 -0700 (PDT)
Date: Wed,  8 May 2019 17:37:34 +0200
In-Reply-To: <20190508153736.256401-1-glider@google.com>
Message-Id: <20190508153736.256401-3-glider@google.com>
Mime-Version: 1.0
References: <20190508153736.256401-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 2/4] lib: introduce test_meminit module
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org, 
	labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com, yamada.masahiro@socionext.com, 
	jmorris@namei.org, serge@hallyn.com, ndesaulniers@google.com, kcc@google.com, 
	dvyukov@google.com, sspatil@android.com, rdunlap@infradead.org, 
	jannh@google.com, mark.rutland@arm.com
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
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
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
index d5a4a4036d2f..28d20c01eb41 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2010,6 +2010,14 @@ config TEST_STACKINIT
 
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
index 18c2be516ab4..04d49fbb9ae7 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -90,6 +90,7 @@ obj-$(CONFIG_TEST_DEBUG_VIRTUAL) += test_debug_virtual.o
 obj-$(CONFIG_TEST_MEMCAT_P) += test_memcat_p.o
 obj-$(CONFIG_TEST_OBJAGG) += test_objagg.o
 obj-$(CONFIG_TEST_STACKINIT) += test_stackinit.o
+obj-$(CONFIG_TEST_MEMINIT) += test_meminit.o
 
 obj-$(CONFIG_TEST_LIVEPATCH) += livepatch/
 
diff --git a/lib/test_meminit.c b/lib/test_meminit.c
new file mode 100644
index 000000000000..6f4ed118a611
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
+	int iter, bytes;
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

