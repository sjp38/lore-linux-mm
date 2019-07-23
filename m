Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FD71C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC08218A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="h3Kq7We2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC08218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FD7E8E0016; Tue, 23 Jul 2019 13:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ADAC8E0002; Tue, 23 Jul 2019 13:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89CBC8E0016; Tue, 23 Jul 2019 13:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 566DF8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t18so16467484pgu.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=jOShWl3tVsknYDB/YoUvrUIV3eQMt6LYV5d/jQUs6fk=;
        b=qVVkv4i6hBWZGddV8hLms5WpHc9z+5e1nAwdSK7Y5tnK6yPQ/iX26U2kh1RstONwmR
         in7LLc7162EgJ+qYP8UTMXACwZ03OHP8ZkL2gPIKECIS9GTo+9Oah69VASDyuobSrzvE
         uZKtBVrKi18rHbCIZozTF5rbGh6WLm4qEBUpew6STYJ0qc5FfNBd/iHh3p52ix6Sd58d
         o3xD4hd0eFu+C4qvbUa8us48ulRPBnkQq7U2UoPjyBksl1VV49ERE11/mgJ8Bmbo8l8i
         qdQPk7Zux23BOjICWAtS0xOhPpQO1ePLq938aBza0nBG61S1x3V+BIBhpmGMW1YHgf5T
         yfEg==
X-Gm-Message-State: APjAAAXzYcLE9nFZtXXxtR4cdodkjWW98jyjY4UoNgrQ6emDP0+xXLNN
	6+hwdxcevRXizC3QTuNoLLYm5xOlP3gWhCyinBcZmA2+yt+ty5DX3PIw5W1UsZLOVPRrFmUKd0V
	9vbZuXnDHKAAH5qH9qUOc/hp7bmK4/Gsn2AzxQ752omQC+Qwx1rLdy+HWnF4q8Dgu+A==
X-Received: by 2002:aa7:8a99:: with SMTP id a25mr7068332pfc.127.1563904797026;
        Tue, 23 Jul 2019 10:59:57 -0700 (PDT)
X-Received: by 2002:aa7:8a99:: with SMTP id a25mr7068305pfc.127.1563904796371;
        Tue, 23 Jul 2019 10:59:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904796; cv=none;
        d=google.com; s=arc-20160816;
        b=YwefM/HTxqnE29CFwp8gqAqAcZws5q0gWX2zinGFu2dQItRY2gaVU3iCmLOep7yRru
         cDePJoMnDwyCFOyvvSUh2k3/qGBeTqz0o/wpcx8ZJ2bsk8WoqvHHE4G5+492mxZJmQS2
         YyLgcsN7URUxU59YNoAJSEvaILPwBSGOCPQWsduai+o+Y6CZlnoxVrCPCdJUfm3xMSX3
         1QLWehF2r9rs812mrWoFU7FyW6SyWvFa74b/8kYSxCvD/VNcrVuGIgLcQrg3dwytVQMf
         ZgHTUlMz95CS3vCu8IrgIRUJF/bCc2j3d9SQupXZwY/rquL9hGslgUbmFIKKAnd2WkG5
         K/jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=jOShWl3tVsknYDB/YoUvrUIV3eQMt6LYV5d/jQUs6fk=;
        b=qaqJKQfJSkdMsbePitUECZllnDFYxNWqkh1BJSD0apuXSvG1Hna1oOUWfiqpjSgLvx
         Ofmz1XWtP+VYaoEocp2WCuAO3mKxd9ZKAkNjlFPk8FXNnniV+QurMb+ZAkpv2CGGtepz
         NV22Po+TNz3W+tHSeOoGAnW07JupsxOj4BdXu8Um8XZPqZ9IkReUsvmXv5PIn/MazCBZ
         giRdiDDwRSTv0sI8PfELqOIKfuxCWc7OjEKpC5xHsf3eZN3ykZ7a3aqY5/TLSUxdfu6a
         gNkSv0E/MQ764q4zdyhImvGClthsfGgZneDUWxXvL0HrpEbSWDaygzsU9EBjett/Ojej
         j0HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h3Kq7We2;
       spf=pass (google.com: domain of 3g0s3xqokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3G0s3XQoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b3sor23660910pgc.45.2019.07.23.10.59.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3g0s3xqokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h3Kq7We2;
       spf=pass (google.com: domain of 3g0s3xqokch4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3G0s3XQoKCH4cpftg0mpxniqqing.eqonkpwz-oomxcem.qti@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=jOShWl3tVsknYDB/YoUvrUIV3eQMt6LYV5d/jQUs6fk=;
        b=h3Kq7We2lcnT64/ZTs7I4tdBthajlqrQq0s3uG0rcdUUGUvc4KeWtl8Lap+IaEU0xC
         yYJQXzHFT7D2Jqscee4HDCwPCbx8Wu4vGwr8iHjoxORK9KGqLusafVkNZ/vi+rdiyHeG
         jdIKwPH4OSoAMEvF/wL6dPzkou8jWXYcRntfsmvla/c6SEeJlZfF2ghZPEbGkeY9ptz1
         cvZXKirYuxY3KSRTfpbbshoiYk3G2vA59VITNzPxXSGn8hhh7sloFpM7Eqe6wa8z0eYK
         HPQ0vNQ1FWKABTpWUeLw9Zvt3IMDsn825fB13HkZ/3l6+zJgRTNpYSRvvg1VGXgpvW9L
         /8xQ==
X-Google-Smtp-Source: APXvYqxAti31RDws7lqydpjpU2QNSIYIBexpp6X7xTgogP1B1IYuH3vnzKrv44nIChFaGEFwrbMkdTHOIZSmLzhz
X-Received: by 2002:a65:5a44:: with SMTP id z4mr77715645pgs.41.1563904795339;
 Tue, 23 Jul 2019 10:59:55 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:52 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <c1e6aad230658bc175b42d92daeff2e30050302a.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 15/15] selftests, arm64: add a selftest for passing tagged
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

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
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
2.22.0.709.g102302147b-goog

