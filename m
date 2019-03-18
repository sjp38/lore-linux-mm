Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58F9EC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B7252133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B7252133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B88A06B000A; Mon, 18 Mar 2019 12:36:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B37E06B000C; Mon, 18 Mar 2019 12:36:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A02646B000D; Mon, 18 Mar 2019 12:36:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 499DE6B000A
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:36:22 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p3so7874395wrs.7
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:36:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ezRVeTwRbKjwyCBcJ/VbvBoL5xr9mdv2L018wxn1S2c=;
        b=Uj3cuOAGDUDfZEqe3WHzlzAQjnNapAFYUnnzKzDx6sj3zGnYzqHom9EcgqFfq1afrq
         W2k6TfrSe9RVazg4fyh+VHf4X7+Uz7e91t7hTi6J7fsPphmYS85OWWfDoIREdg8vHtP2
         5AB19SjIT5l8fcFp2/9A6GwUHLFg9qBIHEYtByCDIBJRC2f2UlQ7ySrX/ArXMRorBE0E
         +7xJmDipo/z4UbIjSxq/xHFgINZ/GuC6rnxuYlqwIUqWFM0cGdSv8lqpvBhu/VkqD/2G
         pkdPuxl1n2ujtLVfQren+3zyULhuumGEGBwyxcmggQKwusE04b0AQRvofJZVKxD3vsKZ
         D6ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXBwha9xOpE7FkXjqyjUDZyujHgrQo9kuj6MF9C1FXGBeJaudrh
	yz7IbnOszMiyEzJ0Isf9FMAC4zuV1xODZgrgxaoug5R7tVsEpkdhyt9vPw975TR4U8uqrvlNMvr
	83YerWylqi6emLxp2Gimki9UwzzN4lEPJZ1fH65NFFUB+NQCVwZYmlNRlzvG33NfkQA==
X-Received: by 2002:a1c:7f0f:: with SMTP id a15mr8946449wmd.99.1552926981706;
        Mon, 18 Mar 2019 09:36:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyta15SG+iExsV3qfI8mwzoCxcAxyCMW+6QNuBnvUcBhuiG5uXzt+kAyxXIZQqbIXXsXIrE
X-Received: by 2002:a1c:7f0f:: with SMTP id a15mr8946313wmd.99.1552926979501;
        Mon, 18 Mar 2019 09:36:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926979; cv=none;
        d=google.com; s=arc-20160816;
        b=hH+VAYfWTDJl6KFZinfpVrtFl4O+bzApGXI0oOz82Rd7HAViBK9wlHn+49jwwsNiBN
         hp/WsXbPpHem9NQGwNg+urQM4cVfb/rh2YP3UmuBV996saJkI/N+fcpoXNhcgnNIDA3v
         AEFwXDT50sDHUj5oY77KGsKHyIGb6J23EA/R1RO7P/m8SE1WfNgcMZLZgigSN/g6cbc3
         bFP9vPWI+pgLpOqgww6ZIHjuf6jx8FN+exxxoIbDXN89t/ToJhiusVZ1f3VTLrmPJML3
         XWyJ0VcLDQE2Kn+cQQ+WG48L0B0z3Yn4mLqD1HQxdVjGY0NXQFqwDxJthT6jXiH0cN2T
         6NXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ezRVeTwRbKjwyCBcJ/VbvBoL5xr9mdv2L018wxn1S2c=;
        b=OmiDno/Ez3eOJ/qb0ACwUhuL7jum3UPO2kY9sPteHEBAA//uEJYnMcQQM3CnboRyg0
         nyPZsPQcJtavSzILOh3ueJJzOdtzN3aBkEQtfSc0fMwKJHPTQvkriWKHXtK8akpcQP6p
         wJXo1Dd1lt2I5JYmAl3Uel6rzFmNOTk+DDmZKMcXyjGbMdUaJVgDID/4Z5FChxaRL5mA
         4xFRUr6MJrIQ/+k4NFo1Baw2K4TbcVuQBJPQeJz09RM2fH50+9cuLCqqcHAzGqqvkK6+
         C55txyJ+VnoacAt/zhm5Qzdz3ls8hJy9Bbw+KZz2lft/HOIUGbT5caVRTFg6HGoJ8Z8h
         ELYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i10si7140479wrp.248.2019.03.18.09.36.19
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 09:36:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 623681A25;
	Mon, 18 Mar 2019 09:36:18 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3D9E83F614;
	Mon, 18 Mar 2019 09:36:12 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Alexei Starovoitov <ast@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Branislav Rankov <Branislav.Rankov@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Dave Martin <Dave.Martin@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Graeme Barnes <Graeme.Barnes@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Kostya Serebryany <kcc@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Shuah Khan <shuah@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 4/4] arm64: elf: Advertise relaxed ABI
Date: Mon, 18 Mar 2019 16:35:33 +0000
Message-Id: <20190318163533.26838-5-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318163533.26838-1-vincenzo.frascino@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On arm64 the TCR_EL1.TBI0 bit has been always enabled hence
the userspace (EL0) is allowed to set a non-zero value in the top
byte but the resulting pointers are not allowed at the user-kernel
syscall ABI boundary.

Set ARM64_AT_FLAGS_SYSCALL_TBI (bit[0]) in the AT_FLAGS to advertise
the relaxation of the ABI to the userspace.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 arch/arm64/include/asm/atflags.h      | 7 +++++++
 arch/arm64/include/asm/elf.h          | 5 +++++
 arch/arm64/include/uapi/asm/atflags.h | 8 ++++++++
 3 files changed, 20 insertions(+)
 create mode 100644 arch/arm64/include/asm/atflags.h
 create mode 100644 arch/arm64/include/uapi/asm/atflags.h

diff --git a/arch/arm64/include/asm/atflags.h b/arch/arm64/include/asm/atflags.h
new file mode 100644
index 000000000000..b20093d61bf2
--- /dev/null
+++ b/arch/arm64/include/asm/atflags.h
@@ -0,0 +1,7 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __ASM_ATFLAGS_H
+#define __ASM_ATFLAGS_H
+
+#include <uapi/asm/atflags.h>
+
+#endif
diff --git a/arch/arm64/include/asm/elf.h b/arch/arm64/include/asm/elf.h
index 6adc1a90e7e6..73d5184a4dd9 100644
--- a/arch/arm64/include/asm/elf.h
+++ b/arch/arm64/include/asm/elf.h
@@ -16,6 +16,7 @@
 #ifndef __ASM_ELF_H
 #define __ASM_ELF_H
 
+#include <asm/atflags.h>
 #include <asm/hwcap.h>
 
 /*
@@ -167,6 +168,10 @@ do {									\
 		NEW_AUX_ENT(AT_IGNORE, 0);				\
 } while (0)
 
+/* Platform specific AT_FLAGS */
+#define ELF_AT_FLAGS			ARM64_AT_FLAGS_SYSCALL_TBI
+#define COMPAT_ELF_AT_FLAGS		0
+
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES
 struct linux_binprm;
 extern int arch_setup_additional_pages(struct linux_binprm *bprm,
diff --git a/arch/arm64/include/uapi/asm/atflags.h b/arch/arm64/include/uapi/asm/atflags.h
new file mode 100644
index 000000000000..1cf25692ffd6
--- /dev/null
+++ b/arch/arm64/include/uapi/asm/atflags.h
@@ -0,0 +1,8 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __UAPI_ASM_ATFLAGS_H
+#define __UAPI_ASM_ATFLAGS_H
+
+/* Platform specific AT_FLAGS */
+#define ARM64_AT_FLAGS_SYSCALL_TBI	(1 << 0)
+
+#endif
-- 
2.21.0

