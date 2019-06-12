Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80C01C46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EFEF20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IyYT4Uba"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EFEF20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B58E46B026F; Wed, 12 Jun 2019 07:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05A86B0270; Wed, 12 Jun 2019 07:44:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9595F6B0271; Wed, 12 Jun 2019 07:44:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0226B026F
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:25 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b75so17011153ywh.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=gGgZ3a6eTnEUj++uQZqNg8ohQ9SAhJYSqDRRhc7mNEI=;
        b=T44tBTx971j7pGg7JRjO8iAbA60y8vfQaLNHeMUayxx2AauMDKYdXdB09vN3S7h3gw
         8P8uskEG6wWSFHQuWKkGjq2sPQ3H5pY3O4ca6RPwfhcRxWBVlQpzV3t4/ci9DMjWtzzA
         S2RZ6CJFatng6X5stm9NGGU5d4v1xtWzaIQA/cEe9nUmIZHfxel8pECO+TKhyCdLNPNg
         oKf5CxEN0PKhVaxPwTVE1ImJiDGka+Tzy/pWA/PB6DVtLPqJx3yaj8RTXNFngq+jPpu6
         gdDdw/OQ0ZXxGeD6fMOzm1q+++twKVw4sAWH2h8pm/a65T6qCmuSKDHbxkxGatRXsvzg
         /7TQ==
X-Gm-Message-State: APjAAAWhirBHKSZnjSNqsYKamRUyQyZ5xb2y9sIJWrAg6x5aIHLZwubM
	3xjxam7RWYhw+z2/Enixd92caFngeAdj/nuuOg9kPwnywLjDlNq9VHrekl9uQUDVVTHc7CgtUA0
	24yCTXHk/96jUi3HIsuWe9ka91OSoSe8d2Ii6KOiPnyCvEXoyhIjEexbd9lGAul6P7w==
X-Received: by 2002:a81:f011:: with SMTP id p17mr42126392ywm.89.1560339865177;
        Wed, 12 Jun 2019 04:44:25 -0700 (PDT)
X-Received: by 2002:a81:f011:: with SMTP id p17mr42126351ywm.89.1560339864281;
        Wed, 12 Jun 2019 04:44:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339864; cv=none;
        d=google.com; s=arc-20160816;
        b=kBHQCV5W/53qWQKqS3Q2vdGjzkHf+piyDOsQFHd4c9V7zCTdXfxZ7JiMz+F3AsSh7f
         3TIHjdpvdpkLvWEYVupAj7EJ3/UPGuSaC880Un1Ub5pah39VN1v0XFAgf9PFsLaOkC8o
         lcgq70ZxEEiyw6Zqt27BjKhvG1y/Oq89rAltjBNvQ5q4tpy1HWw1oDMWpNp07+dDQajS
         sZhacFH7G06DQLnswRbHaAWINJivfRXP68E3SouR2L04M7nMIsr31n7UvYgXOIBycy7g
         rYrIickoof+ghJLMRG2d4m4NADdJ2EPLvMF7pLLAhMDl3S+0g7aoexbhrLsvVqnnfqRL
         TFLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=gGgZ3a6eTnEUj++uQZqNg8ohQ9SAhJYSqDRRhc7mNEI=;
        b=04tDERl2uNyDOqWYLDv7NKWhGH7CVwgcAYIVLwZ04JZJrVnPHyRyHdCGAaj/HffdQa
         3u/Ycu2kbmNj9cJD5ojYyA5DUXzc34bmUKaoj8L0cebyHFqMaghUA/a7RN82jmGrS+gN
         ARroMUdn2Hr3beXph1tJoifgqZQhMXeCWQZ/Z9ndO7acilSeXOYo1gRKlC9zid9IXmJP
         pyZoXkg6b5LT0s+i5s/FxlGFUvkBSmDRPyfR6u/WEe+AhYcdbXoTBT+3C+9Mevyl8vRx
         6HxIBb6D+3Ppn6K5XUe3DxzhTq226bb8egM0oymSnLytkwM2aeJyjBZNtvQFPTHiwqxF
         k/GA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IyYT4Uba;
       spf=pass (google.com: domain of 3l-uaxqokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3l-UAXQoKCFQw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g7sor4022998ywl.183.2019.06.12.04.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3l-uaxqokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IyYT4Uba;
       spf=pass (google.com: domain of 3l-uaxqokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3l-UAXQoKCFQw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=gGgZ3a6eTnEUj++uQZqNg8ohQ9SAhJYSqDRRhc7mNEI=;
        b=IyYT4UbafS5twM0xOLKRaXywnDFDdbDqJgnUILJhttHP1uH2L+NNxbnxVgYAee8lTj
         qqRpjg9Px1/VzqAAM6upfA449si21/4lJ1XkboyBr77Ub0YTrQLbJn5sOIwz1IVA69V5
         Ap8ARpNEkRP6VF2Emm63QaD9Cx3fvDSKZaN/HHC/Xocn6hv1419HlST6JCQQ1Z5EHlL/
         CiJ+tHOg0rDi38FsnXC87324szrGfxAi8RWcHgDsH+2gfi2ulhbLZaNJ0gAKDJ3X8Gkg
         JxyfovuFPvVfND0iTfX5ByU+bmOloPTC5uiR6JL5swcvm2UzXNQY3tCHhrlAltKj98wk
         GeRA==
X-Google-Smtp-Source: APXvYqw2mEWzgJjQoV5VS4+2oS4fV2R/NqpuRE12+fqx+o9WDuiIlBB+xhQmG1zgiCj0aRJhgLJNrenJlX6SsR3w
X-Received: by 2002:a81:6d46:: with SMTP id i67mr906534ywc.103.1560339863971;
 Wed, 12 Jun 2019 04:44:23 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:32 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <e024234e652f23be4d76d63227de114e7def5dff.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 15/15] selftests, arm64: add a selftest for passing tagged
 pointers to kernel
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

This patch adds a simple test, that calls the uname syscall with a
tagged user pointer as an argument. Without the kernel accepting tagged
user pointers the test fails with EFAULT.

Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/.gitignore      |  2 +
 tools/testing/selftests/arm64/Makefile        | 22 +++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++
 tools/testing/selftests/arm64/tags_lib.c      | 62 +++++++++++++++++++
 tools/testing/selftests/arm64/tags_test.c     | 18 ++++++
 5 files changed, 116 insertions(+)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_lib.c
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

diff --git a/tools/testing/selftests/arm64/.gitignore b/tools/testing/selftests/arm64/.gitignore
new file mode 100644
index 000000000000..9b6a568de17f
--- /dev/null
+++ b/tools/testing/selftests/arm64/.gitignore
@@ -0,0 +1,2 @@
+tags_test
+tags_lib.so
diff --git a/tools/testing/selftests/arm64/Makefile b/tools/testing/selftests/arm64/Makefile
new file mode 100644
index 000000000000..9dee18727923
--- /dev/null
+++ b/tools/testing/selftests/arm64/Makefile
@@ -0,0 +1,22 @@
+# SPDX-License-Identifier: GPL-2.0
+
+include ../lib.mk
+
+# ARCH can be overridden by the user for cross compiling
+ARCH ?= $(shell uname -m 2>/dev/null || echo not)
+
+ifneq (,$(filter $(ARCH),aarch64 arm64))
+
+TEST_CUSTOM_PROGS := $(OUTPUT)/tags_test
+
+$(OUTPUT)/tags_test: tags_test.c $(OUTPUT)/tags_lib.so
+	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $<
+
+$(OUTPUT)/tags_lib.so: tags_lib.c
+	$(CC) -o $@ -shared $(CFLAGS) $(LDFLAGS) $^
+
+TEST_PROGS := run_tags_test.sh
+
+all: $(TEST_CUSTOM_PROGS)
+
+endif
diff --git a/tools/testing/selftests/arm64/run_tags_test.sh b/tools/testing/selftests/arm64/run_tags_test.sh
new file mode 100755
index 000000000000..2bbe0cd4220b
--- /dev/null
+++ b/tools/testing/selftests/arm64/run_tags_test.sh
@@ -0,0 +1,12 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+
+echo "--------------------"
+echo "running tags test"
+echo "--------------------"
+LD_PRELOAD=./tags_lib.so ./tags_test
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
diff --git a/tools/testing/selftests/arm64/tags_lib.c b/tools/testing/selftests/arm64/tags_lib.c
new file mode 100644
index 000000000000..55f64fc1aae6
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_lib.c
@@ -0,0 +1,62 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdlib.h>
+#include <sys/prctl.h>
+
+#define TAG_SHIFT	(56)
+#define TAG_MASK	(0xffUL << TAG_SHIFT)
+
+#define PR_SET_TAGGED_ADDR_CTRL	55
+#define PR_GET_TAGGED_ADDR_CTRL	56
+#define PR_TAGGED_ADDR_ENABLE	(1UL << 0)
+
+void *__libc_malloc(size_t size);
+void __libc_free(void *ptr);
+void *__libc_realloc(void *ptr, size_t size);
+void *__libc_calloc(size_t nmemb, size_t size);
+
+static void *tag_ptr(void *ptr)
+{
+	static int tagged_addr_err = 1;
+	unsigned long tag = 0;
+
+	/*
+	 * Note that this code is racy. We only use it as a part of a single
+	 * threaded test application. Beware of using in multithreaded ones.
+	 */
+	if (tagged_addr_err == 1)
+		tagged_addr_err = prctl(PR_SET_TAGGED_ADDR_CTRL,
+				PR_TAGGED_ADDR_ENABLE, 0, 0, 0);
+
+	if (!ptr)
+		return ptr;
+	if (!tagged_addr_err)
+		tag = rand() & 0xff;
+
+	return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
+}
+
+static void *untag_ptr(void *ptr)
+{
+	return (void *)((unsigned long)ptr & ~TAG_MASK);
+}
+
+void *malloc(size_t size)
+{
+	return tag_ptr(__libc_malloc(size));
+}
+
+void free(void *ptr)
+{
+	__libc_free(untag_ptr(ptr));
+}
+
+void *realloc(void *ptr, size_t size)
+{
+	return tag_ptr(__libc_realloc(untag_ptr(ptr), size));
+}
+
+void *calloc(size_t nmemb, size_t size)
+{
+	return tag_ptr(__libc_calloc(nmemb, size));
+}
diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
new file mode 100644
index 000000000000..263b302874ed
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -0,0 +1,18 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <sys/utsname.h>
+
+int main(void)
+{
+	struct utsname *ptr;
+	int err;
+
+	ptr = (struct utsname *)malloc(sizeof(*ptr));
+	err = uname(ptr);
+	free(ptr);
+	return err;
+}
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

