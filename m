Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C784C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:34:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E96532168B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:34:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qjhPznbY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E96532168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FBBE8E0016; Mon, 24 Jun 2019 10:33:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AE758E0002; Mon, 24 Jun 2019 10:33:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4762E8E0016; Mon, 24 Jun 2019 10:33:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 243B88E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:55 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so17262487qtp.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=N5aQVQiWWtXi9gCv0ztW+dfvhd60giz7b6IoZ6u0OIQ=;
        b=aUu6NulQ/9r5cIKfLGQhcEFsc6E/3IjZex3EZWl0KPHd15prBRN5DFxSYpbF/kTrXo
         ohfh0FfDVzpw8mEmrQUR6Uh1O36WCxdcPeeO1Qs1V+M13p8cNUMrqegQRVODS90W6T/U
         Vkr0HJv/RDePqKf3VPmXF8TNynB2LtK70mc1MeaOX2CFtCWkl3EaPOktdihe+3HJv0Ng
         1EcOtdkRLIzT98SM3y6Gh6+Dos1lo9WDmyjCBTB2ORnYGqzehE3lZBoNDPXWjl7mnZHY
         edbdLx5bl92br7E4bGvv42Ptk+Z260xPZjxHyDfA1yF+s50p5qvRiqxPxPIkQw4x/C7L
         wMmA==
X-Gm-Message-State: APjAAAX8+QybaH0SjnQ02FAN5WfVreD2s8QgAKTUws7B9wMudeTxDt/V
	CSrho6/6XZkuPSfIKfk4ofEfP3Ohwd6b5M0KVZTSjqN9zT0UWXDfpO0PIcp3aIoZkeatj3LgX3N
	i3Mqa/7CPme1WNqNHT5w29xXXYekBDP1t39Yw8jKllJsDe3K7ga1UZazOcY9hPaAK5Q==
X-Received: by 2002:a0c:c782:: with SMTP id k2mr58478068qvj.53.1561386834897;
        Mon, 24 Jun 2019 07:33:54 -0700 (PDT)
X-Received: by 2002:a0c:c782:: with SMTP id k2mr58477989qvj.53.1561386834209;
        Mon, 24 Jun 2019 07:33:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386834; cv=none;
        d=google.com; s=arc-20160816;
        b=nDdzwdt5xhNSWH0F9VjJQAtxoBeiXd4DD4WXPBg0b2u97rFc9IRNNR9y8tDfH547t+
         wGOt2k0I83CE3FmXEvgIlh0jqmP7OcItfBjrlbyKcbi/DuRejsxSf9IpTUQqsnYlIeww
         RYXnHykHDW6m8FWgpgkhhS1jakegcss+O5jx93Oq38HKgOhb1fpTKTX8ui9BZuJq737A
         shwiPTNiCaTro9sDqaEadtxXIhPIZngl+i9itxe1e0CoGArR31ux76IC1RE8WSK1gmGc
         e/EEoef7Rk2nuYspdCxswKIpsDep0XBPfJi/md08JU3T7E7L8wqJUBuZRRUs7hy2WnBg
         l8qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=N5aQVQiWWtXi9gCv0ztW+dfvhd60giz7b6IoZ6u0OIQ=;
        b=wdpoT9w1Enho9GdWDx7TKHduO81ytvEIfRam+M4yBE/JYfNdqXfI10dwAZk9sAthF1
         J5cJNqibv99d2nNA0NJWxL4s/JWRQ1CR9EBglCdcV7tUg+i9eSpaMwQeXywXDs3eLAGk
         xvMz7tW4NuJdXFC0iXwBOJPzHCsOKi8eGm/WP72KlDV6+nl6KJdlFqIjg65ErwqOqW9D
         vhnTnLwW6PjpSE1UYRvZYC69kj0eBT+PyiaDL5bpbGG8Llu35CwKM0FxpzsMpROsADv/
         Wuf6XCT+OEcNd+tFonrKyGL5ehQytgFJBawMD0kE7s+nrbZFIMsS8YhyO6dYk09Wr7HP
         E5gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qjhPznbY;
       spf=pass (google.com: domain of 3ud8qxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Ud8QXQoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l63sor6525807qke.134.2019.06.24.07.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ud8qxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qjhPznbY;
       spf=pass (google.com: domain of 3ud8qxqokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Ud8QXQoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=N5aQVQiWWtXi9gCv0ztW+dfvhd60giz7b6IoZ6u0OIQ=;
        b=qjhPznbYLqEoUuOd+SbruTmLg2XmfpstnWtNL0BmQkS/9+yQT+WCgWslxOFvIMH1pv
         mALN6TNaetS33pt/RVz6EBDIEWN2quqA6jv67UFd7koLos1e133OMWu359ZPg0J6bPcr
         0XWlGuBxH86U+t+14QRd+rvD4clAF7jsa1nnvo0JS1ZiAdQXZxeWkV8d/rYp0KzGCh88
         IiYVBvmMbwt07ocU9yE6vY4JutitBKtGPSxtSdK50DrOSaBmfZV7Ob9XJeo2Bom5V336
         MrXYPuP6NQaYbAzK3Of68rTmuGoOGsh3GrYLnYHFg0fALTXz/unOR+Jpt7LYdYsFe3Zd
         cEhg==
X-Google-Smtp-Source: APXvYqyNi91IprVlCjHeOaEl/XhVal8I6zy0NHm57SSOUiamYjJ/eflME47kK7EATSbEXYL1nBd99divk4S0n0PC
X-Received: by 2002:ae9:e8ce:: with SMTP id a197mr16822243qkg.484.1561386833898;
 Mon, 24 Jun 2019 07:33:53 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:33:00 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <0999c80cd639b78ae27c0674069d552833227564.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 15/15] selftests, arm64: add a selftest for passing tagged
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

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

This patch adds a simple test, that calls the uname syscall with a
tagged user pointer as an argument. Without the kernel accepting tagged
user pointers the test fails with EFAULT.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 +++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++++++
 tools/testing/selftests/arm64/tags_test.c     | 29 +++++++++++++++++++
 4 files changed, 53 insertions(+)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
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
index 000000000000..a61b2e743e99
--- /dev/null
+++ b/tools/testing/selftests/arm64/Makefile
@@ -0,0 +1,11 @@
+# SPDX-License-Identifier: GPL-2.0
+
+# ARCH can be overridden by the user for cross compiling
+ARCH ?= $(shell uname -m 2>/dev/null || echo not)
+
+ifneq (,$(filter $(ARCH),aarch64 arm64))
+TEST_GEN_PROGS := tags_test
+TEST_PROGS := run_tags_test.sh
+endif
+
+include ../lib.mk
diff --git a/tools/testing/selftests/arm64/run_tags_test.sh b/tools/testing/selftests/arm64/run_tags_test.sh
new file mode 100755
index 000000000000..745f11379930
--- /dev/null
+++ b/tools/testing/selftests/arm64/run_tags_test.sh
@@ -0,0 +1,12 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+
+echo "--------------------"
+echo "running tags test"
+echo "--------------------"
+./tags_test
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
new file mode 100644
index 000000000000..22a1b266e373
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -0,0 +1,29 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <sys/prctl.h>
+#include <sys/utsname.h>
+
+#define SHIFT_TAG(tag)		((uint64_t)(tag) << 56)
+#define SET_TAG(ptr, tag)	(((uint64_t)(ptr) & ~SHIFT_TAG(0xff)) | \
+					SHIFT_TAG(tag))
+
+int main(void)
+{
+	static int tbi_enabled = 0;
+	struct utsname *ptr, *tagged_ptr;
+	int err;
+
+	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0) == 0)
+		tbi_enabled = 1;
+	ptr = (struct utsname *)malloc(sizeof(*ptr));
+	if (tbi_enabled)
+		tagged_ptr = (struct utsname *)SET_TAG(ptr, 0x42);
+	err = uname(tagged_ptr);
+	free(ptr);
+
+	return err;
+}
-- 
2.22.0.410.gd8fdbe21b5-goog

