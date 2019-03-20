Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DE8FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3526206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qoeAL/PT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3526206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90F6A6B0003; Wed, 20 Mar 2019 10:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE116B0281; Wed, 20 Mar 2019 10:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4766B0282; Wed, 20 Mar 2019 10:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED316B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so2893230pgf.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=jXi2jeYooV/qCSR4Qs1DXrgKH5u+8lvQy5Zlam/3NIS2N2UAJQ7x0nYN19O/QNzhpo
         60Mkd10/VDEPQK8uIZ6vSGEugK0EnmmQ4KNRtmjMxfcAeqvUFEh4fwjJHyq2IHg3LQ8H
         HmTxPHSSewbPOsvNPBdoHFGiPX9q4FWLW9ygqI1hp49QP4Yr6Qy6658++Tk0c1rX1gJ1
         qdnb0I1bmijiKeVcR+1towa0ina3EUIfg3UKwPgLQdk5wCZOfWaOHL6M96aRiXXyPKY1
         WeaRULtoL9edilbEFSmWtZWcWzYPShhZsF0X4ZoZmMTsUxOIiolu9upMgt3px2FMy6Ku
         M/lg==
X-Gm-Message-State: APjAAAVy84+tpySMUQesL9JaOJ8ldYm6YGSbbFbbYUNONhdBe8I0OcA8
	SCzG1D/lwlEiAKhbjH0r6i5eT6poUdzAOti5A5hdN4rzIvO2GBKqLUK+ndOmZlrCT0wRSzBTyR3
	fS0uFLujzpbrN4k/61f1TS7KfRVkX8eYSWDKghcYVhDVli0ESbDp+MoN1zTZHTLBddQ==
X-Received: by 2002:a62:168a:: with SMTP id 132mr8463974pfw.155.1553093571619;
        Wed, 20 Mar 2019 07:52:51 -0700 (PDT)
X-Received: by 2002:a62:168a:: with SMTP id 132mr8463908pfw.155.1553093570477;
        Wed, 20 Mar 2019 07:52:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093570; cv=none;
        d=google.com; s=arc-20160816;
        b=eB2KnjveIrFoXZ7okFYJ9FGE9kbg6KsAjIN5F+9EQFPAkGbAEUX03iNIiG+75WwpzT
         WUf6qT+XwzhNZpU7QfVjuOp6yIB4LHQb+52aW5n0k4FkqINAxWaOyMnPFouvCWS+dRrs
         lL/BLFNY3j2UaS/Z2r3gKYafvRk+PWw48cdX9wGs2N3qklNtbOKNIN7KU2vbzNfIJZC+
         fMOtdy0GDQimwHdxq857n5VuGWyB995Mz3UZ1VRFtZUZjwpaSRaShyY8UYfQEqKuAVG3
         nJxWOQJFHSMFYIUgTBLn8b6kTYYZmC7asPTedFifWXJzT5B3d9O3Ai6Hrh6fQ+pjVcYC
         ROWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=YsVCmbNiYT1JBcH+zP7b7m5Alf3kKjrpUKjVLs3IMi7WjXbHFlTjzRBhzxz8qHe3CM
         6mrV+rLpmf/lXTGCUI6FwHb2W0qqeeGUBQLDcLLSOvu77pLAZw6PNKNuihyt7l9FsWvL
         jp/NsYsWCeiGyUxqilGXFiiWFiHGpb+UJtZhk1Bzp2/29dGqf7LzNx/TEU+vmOwjtqcw
         7YTcCgcBYnxn1J4/UY2g+V92wxdvg0Gi8dVD3ZfdIb6OIfP9APoddqKzB39xjiGbLZ0u
         mkRi8W7cHsyjg6YvIaVNfu4KUcAXnrTNHiVaUVDKwA3PQrA1sbjzltRwPphBrnB+JmKq
         sejQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="qoeAL/PT";
       spf=pass (google.com: domain of 3wvosxaokcjw6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wVOSXAoKCJw6J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x8sor1330257pgi.26.2019.03.20.07.52.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wvosxaokcjw6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="qoeAL/PT";
       spf=pass (google.com: domain of 3wvosxaokcjw6j9naugjrhckkcha.8kihejqt-iigr68g.knc@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wVOSXAoKCJw6J9NAUGJRHCKKCHA.8KIHEJQT-IIGR68G.KNC@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=qoeAL/PTMnTmhgXnl3RGCTw81JMF7TMbNpbYC6F1pr3TGPdCwVaIeU85uj/B77baMA
         VAfUOVehMewxrlPBnMcvR10msEYwYWF8Hf58msk5Kne+FBqRyuY30tbXpt8IkSkZrha9
         BopC5S+Fs8co9IFKm2kvowWttr/p77PwwjO1CLveVN2yF4PwY74t43GhYeQZYNqL2hkb
         Lb66rbH+aemh2G4/5BTzrD1WRMcmhL2lokvByiGUsVSSzbRXBf7wNtl5qMTt1G6arf7d
         2SGd6xj3du+G5dFYrDQjaku3ogveIBZkyDoiC7RnaR7D3ZV5QwX7GQmkBx2mnQVW5OQ5
         WLOg==
X-Google-Smtp-Source: APXvYqz6JBh3VPqVViw3H16uoW27hFqlC/o1l863wBn8e7Vx/uAhxhmqW+NafnSe+CxZM3eW2zA7LqhlL1qr07K2
X-Received: by 2002:a63:5117:: with SMTP id f23mr5792228pgb.3.1553093569898;
 Wed, 20 Mar 2019 07:52:49 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:34 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <60757dd548eefd5cda129c73486dfac5e838084a.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 20/20] selftests, arm64: add a selftest for passing tagged
 pointers to kernel
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
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
 tools/testing/selftests/arm64/Makefile        | 11 ++++++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 +++++++++++
 tools/testing/selftests/arm64/tags_test.c     | 21 +++++++++++++++++++
 4 files changed, 45 insertions(+)
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
index 000000000000..2bd1830a7ebe
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -0,0 +1,21 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <sys/utsname.h>
+
+#define SHIFT_TAG(tag)		((uint64_t)(tag) << 56)
+#define SET_TAG(ptr, tag)	(((uint64_t)(ptr) & ~SHIFT_TAG(0xff)) | \
+					SHIFT_TAG(tag))
+
+int main(void)
+{
+	struct utsname *ptr = (struct utsname *)malloc(sizeof(*ptr));
+	void *tagged_ptr = (void *)SET_TAG(ptr, 0x42);
+	int err = uname(tagged_ptr);
+
+	free(ptr);
+	return err;
+}
-- 
2.21.0.225.g810b269d1ac-goog

