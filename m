Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C179CC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8777221721
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8777221721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A6486B000E; Wed, 12 Jun 2019 10:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9081F6B0010; Wed, 12 Jun 2019 10:21:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783536B0266; Wed, 12 Jun 2019 10:21:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 292256B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:21:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s5so26122618eda.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:21:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QRcMaFEySNE7+oyFMof/21hlMBXlKIWEs6+M0XBM1hk=;
        b=pfVnZcd8Ge0YPKj86O7ynEqiCxbObcd/RmCQewZU7Dgw+4s5JSKDVCqXf49L46U5xh
         P7Y0250CYUNOcmnx66TLJ/T3q2FL/L1oifSXlvZu+byW1vgD18V9EzOOEYX/5zUl2ar8
         3q18IVh1v9YrGtwJu3feC2lsFDxG6BCj1toEwJ+wXCNisc9gGMiN9akws5lho1Z1i+s8
         oXqI8xliqii1UTfou429L4FeLcmuJXj7cEBSTFgUIusF3D4yNs/4iiMNEB0zzu+8BOWS
         mtSBQkqOL/lqP8wUDjBqNvJyaKWio47Fh0rd2S33OYVCGBZ66rU/T7ego4KgZoetRT1M
         sjOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAV4MBYKJDgjsQ7Edp275uUUBKUyuTBGmsNNhc78/ihpcQK3C34q
	XtFrde2PCbKYVo+bUj0zL9xk/fyYzzuoNCU8jS0nyfVwOX3rsmNQuAQHIwUGj7fiCQciBegBovp
	ayrOZlVc2fZz936F2ZyVFRfMkAqhfhKjaWWydksHx1+qvX9tRIk2v5y71jiGUCXjdxg==
X-Received: by 2002:a17:906:5017:: with SMTP id s23mr59264807ejj.17.1560349291601;
        Wed, 12 Jun 2019 07:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmS5sXhZqq8CgPtuju8d9fM6YXvHw365HHwQJLHR6mFJwWclh7PaSjSewp7crqVW3UGP9H
X-Received: by 2002:a17:906:5017:: with SMTP id s23mr59264672ejj.17.1560349289980;
        Wed, 12 Jun 2019 07:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349289; cv=none;
        d=google.com; s=arc-20160816;
        b=S2g3TDrtbFUuXseCXaWOLJA03CjANfIQJOaw/gFbuGzD3zc8ZkVrAwI8WhdDIPQ7Yc
         makvar3ZcG/1CIlZ+ssTHVMcTVQfAB43TDl4oaer5feVyCmN77Z/WQi4WP4MVy9E5WHR
         1x9J1dtov/Xn/sKiP+3SG9z1ND2V+WKxu1rMpTc3TiO4pn6oMq5xrU9XbzR0tAVtxApI
         xq05xzLl5MUAJdNv0fwY9DV1SxmyZFXHLWj6d1BaAMdXzZfol3VV15CA//+3y6WFrevf
         a1tozO/9wQwyCYSH8l2pXG8I9KnPO1BMrU48z8b8aTZHEKHxGo6QGwuTkX9JLIFs8wL9
         KBgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QRcMaFEySNE7+oyFMof/21hlMBXlKIWEs6+M0XBM1hk=;
        b=HVD19OCqC0XuT9nEgD5OYGS/4KCm3rS0WR99GTwjjb8j75nfop8ivJyKtR6oTNvzzw
         xLGaDeUiMHu0nVZ62bE8CxiYNpz3SBpe0DpKjKstklX0JcvLYOShxFWOAc/6fHfoXRN2
         /+KHXaOJjdZhACI0QCufzHH7oBvaQ84/qT0ezHuZ4zVchgx46qlryqku+GkIUej21lQF
         HSaGI5WQK/7Y+pyFdjco/1ZEptYQaThr0Lc/RBCVIky3WfdLRPHn6UcJ+upJycIdEtCA
         c8tej174fxtLmredCWSP7yYWoi4wHIxJasbdyexLueDkegM9TqFemGWgsFp1eYciMK01
         4YEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e3si3320271edi.280.2019.06.12.07.21.29
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:21:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 03225A78;
	Wed, 12 Jun 2019 07:21:29 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A12863F557;
	Wed, 12 Jun 2019 07:21:27 -0700 (PDT)
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
Subject: [PATCH v4 2/2] arm64: Relax Documentation/arm64/tagged-pointers.txt
Date: Wed, 12 Jun 2019 15:21:11 +0100
Message-Id: <20190612142111.28161-3-vincenzo.frascino@arm.com>
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

With the relaxed ABI proposed in this set, it is now possible to pass
tagged pointers to the syscalls, when these pointers are in memory
ranges obtained by an anonymous (MAP_ANONYMOUS) mmap().

Relax the requirements described in tagged-pointers.txt to be compliant
with the behaviours guaranteed by the ARM64 Tagged Address ABI.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 Documentation/arm64/tagged-pointers.txt | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
index a25a99e82bb1..db58a7e95805 100644
--- a/Documentation/arm64/tagged-pointers.txt
+++ b/Documentation/arm64/tagged-pointers.txt
@@ -18,7 +18,8 @@ Passing tagged addresses to the kernel
 --------------------------------------
 
 All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+an address tag of 0x00, unless the userspace opts-in the ARM64 Tagged
+Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
 
 This includes, but is not limited to, addresses found in:
 
@@ -31,18 +32,23 @@ This includes, but is not limited to, addresses found in:
  - the frame pointer (x29) and frame records, e.g. when interpreting
    them to generate a backtrace or call graph.
 
-Using non-zero address tags in any of these locations may result in an
-error code being returned, a (fatal) signal being raised, or other modes
-of failure.
+Using non-zero address tags in any of these locations when the
+userspace application did not opt-in to the ARM64 Tagged Address ABI,
+may result in an error code being returned, a (fatal) signal being raised,
+or other modes of failure.
 
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
-strongly discouraged.
+For these reasons, when the userspace application did not opt-in, passing
+non-zero address tags to the kernel via system calls is forbidden, and using
+a non-zero address tag for sp is strongly discouraged.
 
 Programs maintaining a frame pointer and frame records that use non-zero
 address tags may suffer impaired or inaccurate debug and profiling
 visibility.
 
+A definition of the meaning of ARM64 Tagged Address ABI and of the
+guarantees that the ABI provides when the userspace opts-in via prctl()
+can be found in: Documentation/arm64/tagged-address-abi.txt.
+
 
 Preserving tags
 ---------------
@@ -57,6 +63,9 @@ be preserved.
 The architecture prevents the use of a tagged PC, so the upper byte will
 be set to a sign-extension of bit 55 on exception return.
 
+This behaviours are preserved even when the the userspace opts-in the ARM64
+Tagged Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
+
 
 Other considerations
 --------------------
-- 
2.21.0

