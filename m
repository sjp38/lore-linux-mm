Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 734E4C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B7EF274E3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="E8Ist5LC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B7EF274E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAF306B0279; Mon,  3 Jun 2019 12:56:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C12AF6B027A; Mon,  3 Jun 2019 12:56:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C126B027B; Mon,  3 Jun 2019 12:56:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 717D76B0279
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:17 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y190so965572qkc.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=v9MzlIb7HY1yKtXIqdaDnLUOCgnoLYityVGh+V+FCFI=;
        b=CjlVJyzJnxIGF3+8FMLZSR2r9lxRCQUXpn4cnnNhN0w4fkU5v/FcKZnmiHkgwYCDAA
         7tQNLGqAaIY2eTO6Q3UiaxpbVefBfC568ZHfu4pBHp1hw2kcivfU/MRbdZnaGHoKmF4W
         VZ1X54IGV46PwZtRipbG6JCWYy2MGTzdEkgwFZqYHuoy0pSPJ3UWR0x6fOwbFUFJuYtz
         6BxTGb5TsV70NC8pODTHP9zZk/SoME5hM7P6+91SJfQpC/Z9zvoenJn8QCtTptu7efZR
         hiCqVIETbMvOlTn9an5M4sPl8xqh4EQG63Q9HWRkoodUE9izOTbnowryMNlKQn1kes76
         gkcg==
X-Gm-Message-State: APjAAAVIB7sMigB45fI6rAGjlvQCoUmiLsVJPw6aoI5IngBYZFMuDRit
	BSTfApXgWyXOcAk1YAeM3tQZ2SXcjlVXdGlBq95SfFsBjrWXGV9eVR0rXCnOeHNJ1xgTCpRFVTm
	OsV4Xj4yiZoZ6W6WXnR+4ocQBzzEBEq+Xo8RweJmcNv87Lva9Y5SBLek0J3dAJ7AB8w==
X-Received: by 2002:a0c:afaa:: with SMTP id s39mr22633051qvc.117.1559580977191;
        Mon, 03 Jun 2019 09:56:17 -0700 (PDT)
X-Received: by 2002:a0c:afaa:: with SMTP id s39mr22633006qvc.117.1559580976562;
        Mon, 03 Jun 2019 09:56:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580976; cv=none;
        d=google.com; s=arc-20160816;
        b=Ba/kwPc3imNZDRNiZlrlZ+fCy8B8JiLFwjod1KDbxKg5CT6qdn5wOIgp634LT4WQRw
         G1uchv+cIFS0Ox61vTXx0wVelk7r12pVlhzLhVv8h/XjhWI5IsOlN1WbJHcJXEeOgEOI
         T66MhKE08YKKB9djRTHgZvlsat0JWWO04uXw+q+CJvP2PagaVqiyUVvsfZITUXxgTmAc
         M110+Yx3ksUMMNUXQtlipF1VHLyZEphz+qLrbxGGqDNQQ0jVixSXTz47aNj3oWkKhHNx
         P4EFuI38FcfS28SQZ5uSlCbhiyUYu8ZohtP4PRUtB/9hvFJh6ZPVvHqc5eHh+F3FptOZ
         +bkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=v9MzlIb7HY1yKtXIqdaDnLUOCgnoLYityVGh+V+FCFI=;
        b=059RWfIwSqEBLonM+E5bR2AT0pHWxCnd+Osw9RSNuGA1dy7jiL6DaHbNukUUYV5sS0
         /qhQdbXnk6RWS1Z8V5LfGc/s/o/A3dN7lbAuZkvbES0J4mV9iRoHGoYr7VYBEGcxylU9
         Lp1+VHLcs8k8VZTPLtV4bA3G4wJdw+FVzCr0Y7Yt53vNhb0DWO/77h5JR7YZViEOPeFS
         oX+9UaNPtEteP2y3fy5mca9EDl8Fw4hTtnHwsoJ9P4g6GEHbd6jo4wBXalT89PSlj+uO
         Mp5RfDNcZC33TGbny7O1/LfVacYDmdw2x6O8zYCcK00q5vYkj5wzQM3c+b7nx6FsKC7h
         slsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E8Ist5LC;
       spf=pass (google.com: domain of 3mfh1xaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MFH1XAoKCJUzC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o66sor1249276qkf.101.2019.06.03.09.56.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mfh1xaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E8Ist5LC;
       spf=pass (google.com: domain of 3mfh1xaokcjuzc2g3n9cka5dd5a3.1dba7cjm-bb9kz19.dg5@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MFH1XAoKCJUzC2G3N9CKA5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=v9MzlIb7HY1yKtXIqdaDnLUOCgnoLYityVGh+V+FCFI=;
        b=E8Ist5LC6WVHrU8hj11VtWQb5rjU7iBORWjaptcqcX3l9oPWYIMo05KmXzzCVgt3cu
         lYJ4Yvl8mbNlJpJWSEYMIryL5scHXmPmVUqUSjI9X7Fuxa39wo8rzDRZFWMAkoj3uwjY
         mqiCqrBWPtOVkiL+4ZV5H/HhzxJmpTR97uHC/IdXM4tljhuvgYTiLw3741mzKX8NYLUt
         uc6Aqh8uuXDuaxHP4yeJ0XLPpMovyAE85DGwVCzioR0Gt6moVfBUOYshZAWVCnGUBbU4
         06NzOvSR4tkaeqT9+eniQMZF90V1u65K6kkbFscWsH7pqN+ptT1wb5JpdkKVZRneJwoH
         CGYw==
X-Google-Smtp-Source: APXvYqyupRnjjQO94efnTljbt6p9DxywyyDuZaQUfwBf3Y405Fl40dWCznelJThhDpEIkj52c6mVbKSb6DjD/rvF
X-Received: by 2002:a37:de06:: with SMTP id h6mr3881914qkj.322.1559580976267;
 Mon, 03 Jun 2019 09:56:16 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:18 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 16/16] selftests, arm64: add a selftest for passing tagged
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

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 22 ++++++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++++
 tools/testing/selftests/arm64/tags_lib.c      | 42 +++++++++++++++++++
 tools/testing/selftests/arm64/tags_test.c     | 18 ++++++++
 5 files changed, 95 insertions(+)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_lib.c
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

diff --git a/tools/testing/selftests/arm64/.gitignore b/tools/testing/selftests/arm64/.gitignore
new file mode 100644
index 000000000000..e8fae8d61ed6
--- /dev/null
+++ b/tools/testing/selftests/arm64/.gitignore
@@ -0,0 +1 @@
+tags_test
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
index 000000000000..8a674509216e
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_lib.c
@@ -0,0 +1,42 @@
+#include <stdlib.h>
+
+#define TAG_SHIFT	(56)
+#define TAG_MASK	(0xffUL << TAG_SHIFT)
+
+void *__libc_malloc(size_t size);
+void __libc_free(void *ptr);
+void *__libc_realloc(void *ptr, size_t size);
+void *__libc_calloc(size_t nmemb, size_t size);
+
+static void *tag_ptr(void *ptr)
+{
+	unsigned long tag = rand() & 0xff;
+	if (!ptr)
+		return ptr;
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
2.22.0.rc1.311.g5d7573a151-goog

