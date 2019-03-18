Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F54EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE87120863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oy4XANA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE87120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9DB56B026C; Mon, 18 Mar 2019 13:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E26BE6B026D; Mon, 18 Mar 2019 13:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1BA6B026E; Mon, 18 Mar 2019 13:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A322E6B026C
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:30 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x185so14146678ywd.4
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=OXzFpIfvJY+SNJteDujjggobnkjSUdftUEPhdP8e9NZSH9fxtrMn7/Js10J400zMDq
         LLYg3FiCqWM19YiWbMw/8S8qmmwIF/S+3b8HAuGXLXkBe/KXSwirY0hPsExWITs2Kq5n
         cnG9aIAj/tbXzgmzu0F8+7s9tVdfkng0a8DpUgiiuwiMbumhk+wAFkxGOI1s/OMrIN6Y
         N+S9uRdOg6qz5IrrXrcjiCSc3fSyN4iQEzDxjKdL+QHo4VJ06iVCcC5VFTom61mjNa0Z
         /F3ahuQUiRqY7CE1akh/FdMD55e1GBAsMR8in/kDK0wCpI2r+Ia+j4L48YK9VcUerVYT
         lNDQ==
X-Gm-Message-State: APjAAAXq1u0k05s2IWIgfYJzhQXMG8EunmAmfZdr1Xk3+Q5u1i0ahaGB
	XVfVXoTV0Q0VIhZ6Y3yWJlSyEoBQTMpLbM3DxKZo9zsHm0kMgYQZf/6RtkTguxH4i0PhWnRyO7D
	GTgMF3fIGUDzfn6CqeJQezT1i7uLJ/CrIZ5AVPMfV4C/i4YpXILrAsyyEsJQts8jcVw==
X-Received: by 2002:a25:a285:: with SMTP id c5mr15359213ybi.140.1552929510418;
        Mon, 18 Mar 2019 10:18:30 -0700 (PDT)
X-Received: by 2002:a25:a285:: with SMTP id c5mr15359159ybi.140.1552929509551;
        Mon, 18 Mar 2019 10:18:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929509; cv=none;
        d=google.com; s=arc-20160816;
        b=ohwFlcmOT7UQ7xe7zF8VqCRAvCixw20tNFqnwtFwFk03N2rae1XVAMxbKuBxhrSOfk
         Xlg5hW5zbLhQ4zSv33eFN8/uoyA4wT/+BaqU2GvB9MQbWrjrgl1D3OH2vbCBNpiSbzah
         BjWsAylWeNml3OF96ISsxMhb3vxepThVb1WUSr+aRF5YAmz4IrRIT09XYrqfdkayUmFy
         Vgl7u70s6E4tF50vWHyfCMjvFNfHvD9MGTmeHh1QWRTFIxU8UQrqe4Qn7oz0MGZHhv0+
         2iUHOrp/453OHa9bTRuUJN0L61SQd2yDfmcxIx8Y9B5JLQ8aZCmU3OnphJaRDrNfCoZc
         OfsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=xVGt6AEwIMJ3asOlppNRrivjeuYubnRDf9FSQ0GXZ5YxzKPbvbMdnNJGPAdvv9rxt5
         JXb2IULm113pZMztHpj0YakD+ydIKhYguTd3IGJp5Yvlwg/VbSQpCqfxygNRLWVm65nj
         cCoOD/8PtKY/iKJxDjjWCeGY4NRkXBUdqGkfpZIDhyA+bOB82IZAjQt+A/h+KEfkpsdf
         JRNJ4e9DI3VB79TPU4wj+ECG8pScdkhX728U2ELR8efP/N9AoKSzFI/e6oZ01u0ZY5M/
         OIYEZVcTYN5P6W7ywNaDPwbtLgtEVrcTQEMXD2RiqZTLIpvLl5DVGMFFfDVCyC+5AWiD
         IqMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oy4XANA3;
       spf=pass (google.com: domain of 35dkpxaokclquhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35dKPXAoKCLQUhXlYsehpfaiiafY.Wigfchor-ggepUWe.ila@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y15sor1472040ywy.42.2019.03.18.10.18.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of 35dkpxaokclquhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oy4XANA3;
       spf=pass (google.com: domain of 35dkpxaokclquhxlysehpfaiiafy.wigfchor-ggepuwe.ila@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35dKPXAoKCLQUhXlYsehpfaiiafY.Wigfchor-ggepUWe.ila@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SY+rnApq6/oVhWiUcTCOnBf6TcIl5V0rPtZOMhbp5Gs=;
        b=oy4XANA3tbe0/ZzrN3csQScarn1wlppfqaNsYi+hu9yuogoof3toGpiFXztOXvuSIL
         sBMFi0kVcDXhngeXsQ7F8TmpGE5J+YQspuv0IpgE54s+w7Cg2pGhzbc2pvAhwbRlgRSf
         xxwSPdpD5FpRcK2p/HjiDpbPI1EyCU7DiI66uatDv7wNJCkN8c1ymIFnrzCAUJy1zI9w
         EBzcRuRAINzPha2QHRdT3Y/yumtuj6+oKyiMBKvPeEcFGxcVQSEWK2xmW+D8MpHwLMzD
         P1fusntFSsCEjlr/dNu9pSGP243BnVEPFZOFUAmm90Toh6sJXriJra44fSRj/3Svjc/P
         //6g==
X-Google-Smtp-Source: APXvYqzr9z29O2HnZauXqiNwIgfSTj1CVWyp96d9Efuk7E9e9YiyE5NAQn/RDJZ9P2HjA7rm0gHQWomDM7zPkQh8
X-Received: by 2002:a81:6184:: with SMTP id v126mr9643066ywb.17.1552929509203;
 Mon, 18 Mar 2019 10:18:29 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:45 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <0b4d5fb8364a30a51868b6691fff503878d3d82b.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 13/13] selftests, arm64: add a selftest for passing tagged
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
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
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

