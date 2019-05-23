Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AD39C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42ED620863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HxdHAURk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42ED620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E68ED6B000E; Thu, 23 May 2019 10:09:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1AF66B0010; Thu, 23 May 2019 10:09:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D09226B0266; Thu, 23 May 2019 10:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B20E16B000E
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:09:12 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n21so5423104qtp.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:09:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=R32LxICex7oNv1qnM9cB4rhn+mmT9LSXEBUVQ2zWQG5WRfndBWlFMUULK4WYAnffIn
         2764Ug5F7HUqH66G5wSMc0q46bJAHWO84hdfWI65yL03a5VX3HldeCqQS5YQI9VA3yhW
         c09FeZG0EHoY7jzOrneCAgVbrQNbN6UaIjFygu5CEJJVQgh8+VKjrIYwpb/VzJ3SZizk
         5Y7K+zUpiz0kTytAkXIGDfF6sJEKZG3agdcr8AxSWtfURrDwVsLjoVaBvMbJKixGwkaU
         QhjDHu7NUu76fReBo+awZwmziPXhZN8s3zcSFiSpf3rd4JIebX76QdYIt3DWFdwOxfrK
         I9eg==
X-Gm-Message-State: APjAAAUdmRegYSZtZpf6upGbLn72d9QyNxO5rWVdcbPf371cwqQ71QdM
	acyFQ6hvHRNb12+gghJMlxAQ+4rA7NOg0OWcV4pRzKmsz6Z1GEZs68VFDtu8YZ0D2JSIMUodA4a
	A9u/Q7Gg/wvbDIpCsPjf7kvToWL2QXM69KMTc0uBS8FCxXJIjjTYG4HZjFnUXmPR3BA==
X-Received: by 2002:ac8:5246:: with SMTP id y6mr79010251qtn.242.1558620552488;
        Thu, 23 May 2019 07:09:12 -0700 (PDT)
X-Received: by 2002:ac8:5246:: with SMTP id y6mr79010173qtn.242.1558620551740;
        Thu, 23 May 2019 07:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558620551; cv=none;
        d=google.com; s=arc-20160816;
        b=I2oHK7FAdoNBe9fSJTSePHw/QA7vcuVHP5XxxXedRJNFxGbN579ORsmZEasFrfjPSd
         nqHD/Q65MxzNNIxLFPkP7KCddj/Uxv1x5W2x7ltJhCi4gWSakrmqY0DbXpPTBdBs3ewS
         MEzu39Eg2crxIpfvn7ASOHNInAyl2mlVhKPd2OsVXK5nvn//JdQ8wfk9QuSCw6IRwnYX
         2bdNIyE1QJRyo3wimKuF06QcZtwgO9Krleq7tRbJFIUaYVjXJlufcxeI55clhA70ilW8
         3NZMHXAqPeFRpyil3/BPPa9ExiNSkvQHuz0QB2LSmaqjX9RDGDEOjLL4VOG260Vb0O4o
         lVvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=LaZ38kuqXTU3gFw1SxxI0gMkiR0n+yrkrvTjC/SLU2/Qeb1e4GbiN3IPokr9PAd2kM
         CGmkV3Xcy4fDppsPvvfZNhmcNGdTb+TD4uEv/6k9CpdceNpikfWV9X4BxOD4D1fjePH/
         VRRy8RbXjIcK9TW3URjoJvs3a4j62GEkpeqEaigfs7PzWgRE7EC8rHZsOXX4x7GGMaAZ
         VJ9f7TQ3rq5P+giSlRlldFqn03ZUIF9QDnphon1qGKvmnzjuQXNcmzKS1mTaOrSHRJsd
         Muq4BROD+SrB8Sn7Upqr2rbSLHV2NvpF472u2WZopytDf3idNMxUQz1muglXMM6twrXO
         SLzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HxdHAURk;
       spf=pass (google.com: domain of 3h6nmxaykcgiglidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3h6nmXAYKCGIGLIDERGOOGLE.COMLINUX-MMKVACK.ORG@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p30sor21696609qvc.71.2019.05.23.07.09.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 07:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3h6nmxaykcgiglidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HxdHAURk;
       spf=pass (google.com: domain of 3h6nmxaykcgiglidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3h6nmXAYKCGIGLIDERGOOGLE.COMLINUX-MMKVACK.ORG@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=GrPd0Ehzkwgs8flG0McuJvkTnr/DIjfrIhDeOSvXnoY=;
        b=HxdHAURkSl4n27A0yrQIRU1ITTYPBWK1In1KGlmB43xzTe8tfXSa/dWul7q4I/3UzU
         zAXTkoEFSDGlQlwPxRKEPIsS4gx1GWROBjhSdaDe+osjq2IOHCxE8AK8vVLls9jsiCni
         Ah0o+mZ5lkt/KWNdF1YGyCq0Tn9kR2BizpDzBrgZFEG+PKOtey/cz+kMH+/+NJpItHf2
         vzgiCe1wjnIMjaRo26wo/zwzLMMxV+51y6MNX1nzooG5KC1QggYgSZIVxhYV85G0/IFG
         eyM/9zRs+5DIGCsdt23RjOyg9gSR0BPyH9rKZ0GdAzhvalKjcPMUFbug9urWslsi51qX
         M31w==
X-Google-Smtp-Source: APXvYqwTc2z+TMaFN0UPPlnm9rius4RP7zoq7ED5Y5T2qgqHTis5h9UUibnhY+/7LWm7HuiK8P97MvS3qoo=
X-Received: by 2002:a0c:95d5:: with SMTP id t21mr70859708qvt.215.1558620551451;
 Thu, 23 May 2019 07:09:11 -0700 (PDT)
Date: Thu, 23 May 2019 16:08:44 +0200
In-Reply-To: <20190523140844.132150-1-glider@google.com>
Message-Id: <20190523140844.132150-4-glider@google.com>
Mime-Version: 1.0
References: <20190523140844.132150-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v4 3/3] lib: introduce test_meminit module
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

