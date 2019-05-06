Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1193C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A61E20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RgL6sD0q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A61E20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D1F36B0281; Mon,  6 May 2019 12:32:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AA8D6B0282; Mon,  6 May 2019 12:32:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BF8E6B0283; Mon,  6 May 2019 12:32:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3577F6B0281
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:32:02 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id w84so6107460vkd.23
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:32:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SWVsw2knEHBiqwTje+QZ95uhvJ0Eq8KQC+Uh3mHLIrs=;
        b=LGTUUEKUtvsLM70YJ67mBr1mu7GnVGFv0OVAB33JL4SVSmfGSrVePHt71cuRekFdWi
         Rv/M6urJHrrTs8nbmvw3ZJX0lJQK1vvYuk/b7TjErm6PRzCaqpXprm9kbDmuv69csy2R
         AegJ/ZYNpE2ngH3pT7v0N5lHW19hPCZUyQXinREJyxcE7h16JDlKXALUUIiGCskzAlH5
         hHBusI0+UWb8NxPklCblX3lCvxEQR8kz20moqirdLd/+liUEBbPmmXtBJvwjRJjuMbvS
         ooaZlEhReHeT+045R7dJs39hJ49YM/8vCP+ZLlGTVjx91oLSM1fVyIKZZBJwbA6w7Pl9
         5SJA==
X-Gm-Message-State: APjAAAVrE0cdNJF4RJVNtW7ixBSto5Yr8aSN7VwDsDOrfZ0b1VAud3vn
	JqB8i5FXI96qbzDNWlmylQTFrxxtACUoJyzdRFXP387WS6D0zO5DqFvIL9slqHw2IoD68gImGcf
	F9gnsiN+jBrKFsUwiAV+wNpxI0nXCniMGUmKqEq2AcLMyuJd5/4aTwXoBcJ6Ag3zABw==
X-Received: by 2002:a9f:2c09:: with SMTP id r9mr13724382uaj.56.1557160321778;
        Mon, 06 May 2019 09:32:01 -0700 (PDT)
X-Received: by 2002:a9f:2c09:: with SMTP id r9mr13724279uaj.56.1557160320269;
        Mon, 06 May 2019 09:32:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160320; cv=none;
        d=google.com; s=arc-20160816;
        b=ole57Ct3Sc5c50Y3za1FrZQvm7gSSeoLIdL3xK1AULng+yGgqrWZ43kynTFSLGBtWf
         mBPtz2yz6hpUiqMeTUjFyXcMvXe3srtzLOq2yT4RFBudGxECA6ah7wQarrbpVwjKJLNZ
         oH69gni73eiduHYzxQnGMstCqKqvfRwFFxtcDK/g1iHGKLi/ozGak30tAwe+at4MwGJs
         R2x4Umu5MU8tzF3i7HVAu5fBquddki4qGQ5e41451DDQdLj+zNKkNbiy4pS6qPBeYa6X
         lS/pDEJ+CSM1aEZwh7wUbP+G2B3MAM7VmI2CHlPK0dtE/mCJz448R/1N8SdFW4rYQmFC
         uxpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SWVsw2knEHBiqwTje+QZ95uhvJ0Eq8KQC+Uh3mHLIrs=;
        b=uacmlhTVFRm5Vzy0mwFuX7Eh8YugacYQSqlIBnc0JqjiO9TQwOqRMCaUtp0h1wbKr6
         RNZBkM/m6hR4HrbRTpKwQNaZVzRiRIbkXXSSMQ4vOCvlkjokIZgBanw1Kw3wRmdhR1Ke
         G1Aasd7EFglgW3FzG3YtYmE1HleswNgrreLY0dmpmJtYdR2hIJeAJ+cfEemOa81ME/Gf
         QFdy5tIbxA9/5Zm7GUcPymGzzKXYl6+5kP3efhdYUJuHQyx+Zy8/mri3AsRPCIL7sjYL
         bpocYB97hU1PWeG4cv50wooGHzk98Kt8zU9eJ1S1pVk5eBkogXH5JrkLZ7Fm3BEJmFy9
         ZsCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RgL6sD0q;
       spf=pass (google.com: domain of 3f2hqxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3f2HQXAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b21sor5456811vso.57.2019.05.06.09.32.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:32:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3f2hqxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RgL6sD0q;
       spf=pass (google.com: domain of 3f2hqxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3f2HQXAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SWVsw2knEHBiqwTje+QZ95uhvJ0Eq8KQC+Uh3mHLIrs=;
        b=RgL6sD0qMVVBo2W6IqHUBM5jj9VtirOB0KEMhgfz8sMUxbZ1FQX2voyY3kT1G83YUB
         c2NHug1MaUbvaiT2/kwsYJcX1LID/13F0wNOf2AHICLEHy5XvFyjYislt0SYk+XJ6yKP
         649zRPJ+NdSdXSoussFiI5QFPPYrqQUh3ojhtBNMt1d4e4tKjAnQkQjx5Eh1zuXQvQIM
         JcTGFQAzGxQj9nG+dHgIo2BfMYCnSXgaj1ghPhO7L6oN78p0fysyobcM96NyuviAQaqi
         YZLFqu1hahvJ559CgByQZZLzdRPUlocjvpj3Ingemtoy/aM5Di1UnW6jML/TVEYZ07jc
         pviA==
X-Google-Smtp-Source: APXvYqzqHfit8S9j9GkAK338RCzBXfh/l/pOO+ozkZWr4c4UHEKzTSoAg+io9ZiclURMXMIijYhqt5pgUoOVGv8c
X-Received: by 2002:a67:f6c4:: with SMTP id v4mr13696595vso.182.1557160319808;
 Mon, 06 May 2019 09:31:59 -0700 (PDT)
Date: Mon,  6 May 2019 18:31:03 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <e31d9364eb0c2eba8ce246a558422e811d82d21b.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 17/17] selftests, arm64: add a selftest for passing tagged
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
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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
2.21.0.1020.gf2820cf01a-goog

