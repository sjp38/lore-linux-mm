Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D8A3C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 639A220866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 639A220866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A58A6B000D; Wed, 12 Jun 2019 10:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 085676B000E; Wed, 12 Jun 2019 10:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E86AD6B0010; Wed, 12 Jun 2019 10:21:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9E76B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:21:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so26154980edo.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:21:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KXksw+smo+RTidfVx1bhxI8VWah6o0Gp2A0c2mbF7xU=;
        b=KQVmAEzILaq/bUYFh9FCm/KCb/+ceRryjPoDAYD8k6Ayrs6bt7F53ip1VqkyAd1Mf/
         D5JdK152/eHev1WNjwcSJSW5T/95qIKbripr+ifJzBoX4yPG1mA13PiuKhsy5O4dyYf8
         nxUoRcz+95B4twbGSx8Pk4tXTsMd1TF08Z89WVS3/51Rdw4sgoxrOoqFYB/Haj8c3u/T
         wPbk3hNcYoYsFlTiDOGaLjxYpAcLdiVxvYpu48FTdGB3IcHAbqHSG36pHHmYxS41snN3
         dKeBX5FpA7vVZn5L6rmdGjsgP+9nHQ0jU0UiSYESLhiN9iJb+9BbGSGrIg7br9U/nsa2
         al8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAWX3WQvdX560csU/D8kiYo775rKueMoAtDHfb0vaNPFUbb6g3ov
	vuFhbovNEIulrQwoDOnLycH4gny0tkYr2+erPVemUbakNIJG42Krdy/CC1+R2++HpM1ifgvPDgu
	qOm1shnRvttdAHW4m+FAB97ZXb5lzh56mCFRUwBMk76MHfuziAEtAMBn/1Kde/Fxfyw==
X-Received: by 2002:a17:906:7801:: with SMTP id u1mr32423229ejm.250.1560349290100;
        Wed, 12 Jun 2019 07:21:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGv4iIHqRy2WLHPhP+BnMaK0jccuP9fvYia2HNRxcNq+zVZVU/zzbOfzoBmMEAQfWxEBWJ
X-Received: by 2002:a17:906:7801:: with SMTP id u1mr32423121ejm.250.1560349288558;
        Wed, 12 Jun 2019 07:21:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349288; cv=none;
        d=google.com; s=arc-20160816;
        b=FwcryQRCPEfZpWSthO2PUtdVrVxyawfIigTofYpl5Uv6EDFvaGfstQeCJbxWD0s7Xl
         Q5v0G9ROSWLl2Ti9E8Deu2OZgntE5THidfLpJBwA3R+DwE8BzB12l0OZkDsu2CkL4r22
         RRX0K69JCQwyui6ldKk5SaTrCNVo1m2hKLdZp420J/yfrNy391p7pTr4bNyGydOFZUDB
         E4SDjgsWiUbNQ0ewznEVQNm5eOSsqUxb8eDg1tlyAyFy9HywN+jrte867K/AXQBwy0DT
         DpEAlEMLkYuqC7PP3cjTcT/zZmsNbnKT6KzyP563mrF72gxQW0m991YpfL30n155RSuO
         0+lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KXksw+smo+RTidfVx1bhxI8VWah6o0Gp2A0c2mbF7xU=;
        b=MOVNAz0eJpPG0cP45q8AMrH6/ItirDDsofnWW9yEraFd7dRVW2cxSkXOrqPkCqlxW4
         YAfNkpZGONxJZSiZeJ8V03qN8C0v8mAI3yjYQKJhnh2FsSguZOEdzqI8NAN9ilZSZnd6
         8mI3nHi1wMRwJV6ByooLR3lhujorwbBoys27/XDpXXHOVSN1aj6WV6//vsbsL3rcAZoL
         gJbWUyV+XWsg5K8MBk5NNu5DYZ+m67Vco9V7+x0Ix/V1lIuCJzAEk1hGXYev/ei7FMVr
         ypB7tkYai+8uxYg+cpR0Os1xfzFOJGBbJ323NP/EChLi2GqobzJcAsVa8e8Txzq7T6uw
         Ojqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n30si7994167edn.79.2019.06.12.07.21.28
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:21:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6C827337;
	Wed, 12 Jun 2019 07:21:27 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 184D13F557;
	Wed, 12 Jun 2019 07:21:25 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v4 1/2] arm64: Define Documentation/arm64/tagged-address-abi.txt
Date: Wed, 12 Jun 2019 15:21:10 +0100
Message-Id: <20190612142111.28161-2-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612142111.28161-1-vincenzo.frascino@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On arm64 the TCR_EL1.TBI0 bit has been always enabled hence
the userspace (EL0) is allowed to set a non-zero value in the
top byte but the resulting pointers are not allowed at the
user-kernel syscall ABI boundary.

With the relaxed ABI proposed through this document, it is now possible
to pass tagged pointers to the syscalls, when these pointers are in
memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap().

This change in the ABI requires a mechanism to requires the userspace
to opt-in to such an option.

Specify and document the way in which sysctl and prctl() can be used
in combination to allow the userspace to opt-in this feature.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 Documentation/arm64/tagged-address-abi.txt | 111 +++++++++++++++++++++
 1 file changed, 111 insertions(+)
 create mode 100644 Documentation/arm64/tagged-address-abi.txt

diff --git a/Documentation/arm64/tagged-address-abi.txt b/Documentation/arm64/tagged-address-abi.txt
new file mode 100644
index 000000000000..96e149e2c55c
--- /dev/null
+++ b/Documentation/arm64/tagged-address-abi.txt
@@ -0,0 +1,111 @@
+ARM64 TAGGED ADDRESS ABI
+========================
+
+This document describes the usage and semantics of the Tagged Address
+ABI on arm64.
+
+1. Introduction
+---------------
+
+On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64 kernel,
+hence the userspace (EL0) is allowed to set a non-zero value in the top
+byte but the resulting pointers are not allowed at the user-kernel syscall
+ABI boundary.
+
+This document describes a relaxation of the ABI with which it is possible
+to pass tagged tagged pointers to the syscalls, when these pointers are in
+memory ranges obtained as described in paragraph 2.
+
+Since it is not desirable to relax the ABI to allow tagged user addresses
+into the kernel indiscriminately, arm64 provides a new sysctl interface
+(/proc/sys/abi/tagged_addr) that is used to prevent the applications from
+enabling the relaxed ABI and a new prctl() interface that can be used to
+enable or disable the relaxed ABI.
+
+The sysctl is meant also for testing purposes in order to provide a simple
+way for the userspace to verify the return error checking of the prctl()
+command without having to reconfigure the kernel.
+
+The ABI properties are inherited by threads of the same application and
+fork()'ed children but cleared when a new process is spawn (execve()).
+
+2. ARM64 Tagged Address ABI
+---------------------------
+
+From the kernel syscall interface prospective, we define, for the purposes
+of this document, a "valid tagged pointer" as a pointer that either it has
+a zero value set in the top byte or it has a non-zero value, it is in memory
+ranges privately owned by a userspace process and it is obtained in one of
+the following ways:
+  - mmap() done by the process itself, where either:
+    * flags = MAP_PRIVATE | MAP_ANONYMOUS
+    * flags = MAP_PRIVATE and the file descriptor refers to a regular
+      file or "/dev/zero"
+  - a mapping below sbrk(0) done by the process itself
+  - any memory mapped by the kernel in the process's address space during
+    creation and following the restrictions presented above (i.e. data, bss,
+    stack).
+
+The ARM64 Tagged Address ABI is an opt-in feature, and an application can
+control it using the following prctl()s:
+  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.
+  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
+                             Address ABI.
+
+As a consequence of invoking PR_SET_TAGGED_ADDR_CTRL prctl() by an applications,
+the ABI guarantees the following behaviours:
+
+  - Every current or newly introduced syscall can accept any valid tagged
+    pointers.
+
+  - If a non valid tagged pointer is passed to a syscall then the behaviour
+    is undefined.
+
+  - Every valid tagged pointer is expected to work as an untagged one.
+
+  - The kernel preserves any valid tagged pointers and returns them to the
+    userspace unchanged in all the cases except the ones documented in the
+    "Preserving tags" paragraph of tagged-pointers.txt.
+
+A definition of the meaning of tagged pointers on arm64 can be found in:
+Documentation/arm64/tagged-pointers.txt.
+
+3. ARM64 Tagged Address ABI Exceptions
+--------------------------------------
+
+The behaviours described in paragraph 2, with particular reference to the
+acceptance by the syscalls of any valid tagged pointer are not applicable
+to the following cases:
+  - mmap() addr parameter.
+  - mremap() new_address parameter.
+  - prctl_set_mm() struct prctl_map fields.
+  - prctl_set_mm_map() struct prctl_map fields.
+
+4. Example of correct usage
+---------------------------
+
+void main(void)
+{
+	static int tbi_enabled = 0;
+	unsigned long tag = 0;
+
+	char *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
+			 MAP_ANONYMOUS, -1, 0);
+
+	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE,
+		  0, 0, 0) == 0)
+		tbi_enabled = 1;
+
+	if (!ptr)
+		return -1;
+
+	if (tbi_enabled)
+		tag = rand() & 0xff;
+
+	ptr = (char *)((unsigned long)ptr | (tag << TAG_SHIFT));
+
+	*ptr = 'a';
+
+	...
+}
+
-- 
2.21.0

