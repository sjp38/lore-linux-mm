Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B45DC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B451C21744
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ACzTueeb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B451C21744
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49A8A6B0273; Tue, 30 Apr 2019 09:26:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FD466B0274; Tue, 30 Apr 2019 09:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EB7A6B0275; Tue, 30 Apr 2019 09:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5776B0273
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:26:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id w53so13337693qtj.22
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=CUfyrLNe/T3EcKv5qduPdE7e3xDRgpU9AlrvCv3qwqI=;
        b=DGSxr5+5U0TnBN+4rBiz3m/NtKRqfWRkEi7IDn4m76MmR7Dbfn2iA8dbuqiTP/FHWL
         lBKaHFiCyv8QaQ7KVlyyDx4B/f+vEepcZrmnLDltC1dFioRIuNDl8GYQXMe0jTlNhkTf
         GCubFD7T4tcNWYpFeJDz/wt5+pMIG7VXC0y9xT7nxyMArvFEmTXG/HV09/QyksKzVEvM
         6XrXEX/QMb4XJKVhvR5eCJVEBfEUbFI0Kls+ezaX3vj98XKLllDL9pNnUP6o9FcptYpM
         mpCIQzX8CrovCViyWuinuHp0smPAmGV4NF4sCJUYs+mjQd4qMMd6MdW/HI4HNUHoXJPN
         dixQ==
X-Gm-Message-State: APjAAAXQuoAw7+rFmhNEsYXdEH4e/uL9G1qmLV4LuhR/+31dUPW5GhpE
	PuvmOltpZ5ik2sSKNmNTcorcxeICaT3PPn4UdCHZF5CDKL/hbzZvS8SgQkIZ7/ASYT1H9Ku3CT3
	kPLU43N6AsQcM0uIh+VE2BVt+k+j+OyiQzzod/xx4kDAAZ5YNPuudJ3Waax7XgJmXcg==
X-Received: by 2002:a37:5b86:: with SMTP id p128mr43890910qkb.10.1556630771767;
        Tue, 30 Apr 2019 06:26:11 -0700 (PDT)
X-Received: by 2002:a37:5b86:: with SMTP id p128mr43890859qkb.10.1556630770965;
        Tue, 30 Apr 2019 06:26:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630770; cv=none;
        d=google.com; s=arc-20160816;
        b=ufMg3Ww519CUYecj93lg0ae4pS7ySSUhLoJGY9fR/5dAapNURYv3jMXC9R6JdyrAaV
         vcFtrGCIrGnecHNWwkeYASjqlJ8L11LHvCuwiYVzWbH0+O4HUPRjiJnxhUcrx0Ar5mAU
         AUKNuRmpxWYrFegiL5fRv50HIXgbvsCfn8TIYumKGp7Wndk8V0hHgtYgQKmdZgMci//E
         x/GcAtP1HcAMPfRbObktZ8voJR/1fjPqPIkJ/Q3VOtMJKlo4mPwCx2L4neF5HF21zsBR
         V4voO5vGrE0tkXURbiCva2QOfsHtadPEgYkSi+dtxNiUL5Hk+aTShpjwefrv9zEi2bu/
         if2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=CUfyrLNe/T3EcKv5qduPdE7e3xDRgpU9AlrvCv3qwqI=;
        b=XBQWEgHVZAbrdZDJq5zfGar4VN0vwTMrLOpVNXnmu/Sh1qvnKweaY2ATfy80UiWoLp
         0MoHL/pV+tfewqi7ZvketziSdQp/y7SAb70zHrm1okXPqS0CWx0E+ZvleG4eqGYf7ihn
         oNpH7APJfCVpXWJxxyNSypZOFR+73JpruN80sSZ1U7dSDSC8CgZlnL9LXffBJ6mRXsJY
         ebTqMgrU+JeQptCD5BM9we0p5a0jEZmNXFE0Kf26D3ZNqc31JjBDL5dNLDy5WcLsY3y8
         Qv5rWmaJRfx3b7QTHy+cYnYePbWMDmgY9W8Fx+f+mnqmYFmv3nuTm6gDHjpD+HsictGf
         jk/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ACzTueeb;
       spf=pass (google.com: domain of 38kzixaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38kzIXAoKCJk3G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e123sor16856226qkf.14.2019.04.30.06.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:26:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 38kzixaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ACzTueeb;
       spf=pass (google.com: domain of 38kzixaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38kzIXAoKCJk3G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=CUfyrLNe/T3EcKv5qduPdE7e3xDRgpU9AlrvCv3qwqI=;
        b=ACzTueebTGZuzKKoCgKBIgO56T+v/kmKwHjurWtS7UbHoL/8XDJlDb5ck/BSEBSEkL
         L/cpQLHEpHyLmFxTqXzMv0MYxpPJ/tdSuF6iSO5LSNmbylvOUvYffcEQgPGf+AHIVemF
         X7c/hUL69n/uOjY+uNJSNPAVfbcNbVaSMzD0uei9BaIXpxtVKCRwsIlHAcYOHL9EFavB
         iCJAtq03WGCgnaX+tP7fN2qD5Hnfneud42YH1gQK4xFPHVYPeqPOAqGnfhU4Bvx5JZ4h
         WVQJpJkjflxIoXEbOmqcqlW6kZy64vV5a1g9LW1u4aQq8hQq2UTluPLfVENOwe2MSfHQ
         GaaA==
X-Google-Smtp-Source: APXvYqysB3GTYMj0WGj5xIZkllIRnPABiLNbQUXAXOCL1Y4t6SI5ksxcGzuX1TZYAhDJVUrbxfYKc2E7kTYKjt+4
X-Received: by 2002:a05:620a:482:: with SMTP id 2mr43219855qkr.323.1556630770597;
 Tue, 30 Apr 2019 06:26:10 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:13 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <d8f017e7ab36f698d05e6cc775115730c917ca77.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 17/17] selftests, arm64: add a selftest for passing tagged
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
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
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
2.21.0.593.g511ec345e18-goog

