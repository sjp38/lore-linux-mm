Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2B44C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FA912133D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:36:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FA912133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 238186B0008; Mon, 18 Mar 2019 12:36:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2176B000A; Mon, 18 Mar 2019 12:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08AC36B000C; Mon, 18 Mar 2019 12:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5FA96B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:36:14 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 65so6194397wri.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:36:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XEELYYF6lc/hWetNLA+zrjJi6XxuwPk+tQQR+ZM7sY8=;
        b=ln7vCazJD4bHessIuvM+3Rf07uAFyc0K3LQ7AUS8CEQO5iKiud4ktNmYX11NVb7dE0
         VpYlupPIKBl8objr7QTwpIYcYzjAuDTy3PQxmLJTTtP5iwNsX7a20VYmCJlJgGEgjY0g
         ZFwt7oxyz8i6J9/Q5C5Y5a/Ag+kE5Rzy4kaL+3jUTY0IFhPFr4CO9OIBG10KhSnzjhNa
         DkuxGvTzwAcRjUyPJFO0ERaxzTUacHCFuqyApMTP2zpc128NcpzfELDt202X8wgxOXCH
         26qXYkL5Nmx6RqRKsZYt+2gepXNXXhj6VuV61AFqMpWCQTE+YZEN0Un+SG9+aoOP1YO7
         nTwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUNm0EAaQkkiSG9iW11tZUev0d8gSAEZehGkal2PgOe1RnotNS/
	mIVp2q2RPgFZyqxEOPoGOOXBRYHwR5UtjjHx5KxhVR0S19K5lV6/7R1WbAy8RNYKr56EWoRd51o
	4zcMP+vE8uENEc2qbSoFCLyHarxn5WSyHXD+ZdnaQxswU47N3DN5mt+DdBD9HQimYKA==
X-Received: by 2002:a5d:4f91:: with SMTP id d17mr13853865wru.67.1552926974070;
        Mon, 18 Mar 2019 09:36:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf/R8ATqf44IIM8cDif04FKiCVdx5LerBWWDAI5YwVEBcJRqzHKZWudp4DJRJJi2HZ4SuN
X-Received: by 2002:a5d:4f91:: with SMTP id d17mr13853811wru.67.1552926973210;
        Mon, 18 Mar 2019 09:36:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926973; cv=none;
        d=google.com; s=arc-20160816;
        b=EMajpXr17DSWbklqRifHQZ9UFPtGhNvx9E9hYE0dvDLJab/WNhw9IQyExWKyfuTfb1
         Rf2GyGrr1vfgSpfvXCFr5iDQ/0Ow1BVamwhUGivf9OI0JsShuMqaYGkp68zr9TTr8dse
         tuBjKE18SiDYhoFLvcC0bMjLmoEGWj1WX0qjos/k8CwZ3NpmqmjsgkILRcNJsLdjH3W2
         RwdOo+m016+S7cyjZHi6RS4SvPP9XILfWFhlq7jixomz99n1s3YbrHh7hVDthAsP2qbd
         7xHSNIcZuZgz7TtLPOV7fh6L07ecSIPp1HQiVyDHFLeqdG2EUgMs0yuF50WUWOdA3KgW
         rjlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XEELYYF6lc/hWetNLA+zrjJi6XxuwPk+tQQR+ZM7sY8=;
        b=B2M2Iyr5vy+d8KFRlrWhQLBTophMcz9qruzwTy5FATDPr5ndegcEQyGIf/ztkDRIKF
         huB5J0ux0/dpCZZU3Mvjky32PeKxKkeEM24DpEMJJ1MX6VLDzNM4patKrQNtaILIAOAI
         X8FH5HDUpGc98/fbbfg5SeNR4JgSpthYgNGkJR+OOqWKnDU3ASDnVeuqf4HXngoMKweC
         irKiBRQjolzIyo/ZLqL39RcCwHbzhPIRj5qQY3U96u8NTQWemVMhjLqMr0mMwbS49MZ4
         u/9rJ0BJ4TUkzJgtL3fEoYloCqV1HQraWp0sJWi8td3RYAy0B6WGaV/ne0Nti41epIay
         LT5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v62si6517277wma.181.2019.03.18.09.36.12
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 09:36:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EEC7B174E;
	Mon, 18 Mar 2019 09:36:11 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C9F083F614;
	Mon, 18 Mar 2019 09:36:05 -0700 (PDT)
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
Subject: [PATCH v2 3/4] arm64: Relax Documentation/arm64/tagged-pointers.txt
Date: Mon, 18 Mar 2019 16:35:32 +0000
Message-Id: <20190318163533.26838-4-vincenzo.frascino@arm.com>
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
the userspace (EL0) is allowed to set a non-zero value in the
top byte but the resulting pointers are not allowed at the
user-kernel syscall ABI boundary.

With the relaxed ABI proposed in this set, it is now possible to pass
tagged pointers to the syscalls, when these pointers are in memory
ranges obtained by an anonymous (MAP_ANONYMOUS) mmap() or sbrk().

Relax the requirements described in tagged-pointers.txt to be compliant
with the behaviours guaranteed by the ABI deriving from the introduction
of the ARM64_AT_FLAGS_SYSCALL_TBI flag.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 Documentation/arm64/tagged-pointers.txt | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
index a25a99e82bb1..df27188b9433 100644
--- a/Documentation/arm64/tagged-pointers.txt
+++ b/Documentation/arm64/tagged-pointers.txt
@@ -18,7 +18,8 @@ Passing tagged addresses to the kernel
 --------------------------------------
 
 All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+an address tag of 0x00, unless the ARM64_AT_FLAGS_SYSCALL_TBI flag is
+set by the kernel.
 
 This includes, but is not limited to, addresses found in:
 
@@ -31,18 +32,23 @@ This includes, but is not limited to, addresses found in:
  - the frame pointer (x29) and frame records, e.g. when interpreting
    them to generate a backtrace or call graph.
 
-Using non-zero address tags in any of these locations may result in an
-error code being returned, a (fatal) signal being raised, or other modes
-of failure.
+Using non-zero address tags in any of these locations when the
+ARM64_AT_FLAGS_SYSCALL_TBI flag is not set by the kernel, may result in
+an error code being returned, a (fatal) signal being raised, or other
+modes of failure.
 
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
-strongly discouraged.
+For these reasons, when the flag is not set, passing non-zero address
+tags to the kernel via system calls is forbidden, and using a non-zero
+address tag for sp is strongly discouraged.
 
 Programs maintaining a frame pointer and frame records that use non-zero
 address tags may suffer impaired or inaccurate debug and profiling
 visibility.
 
+A definition of the meaning of ARM64_AT_FLAGS_SYSCALL_TBI and of the
+guarantees that the ABI provides when the flag is set by the kernel can
+be found in: Documentation/arm64/elf_at_flags.txt.
+
 
 Preserving tags
 ---------------
@@ -57,6 +63,9 @@ be preserved.
 The architecture prevents the use of a tagged PC, so the upper byte will
 be set to a sign-extension of bit 55 on exception return.
 
+This behaviours are preserved even when the ARM64_AT_FLAGS_SYSCALL_TBI flag
+is set by the kernel.
+
 
 Other considerations
 --------------------
-- 
2.21.0

