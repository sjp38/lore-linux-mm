Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E44F1C761A8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9BCC22BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:51:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9BCC22BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8618E007A; Thu, 25 Jul 2019 09:51:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C33BD8E0059; Thu, 25 Jul 2019 09:51:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD2F58E007A; Thu, 25 Jul 2019 09:51:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 593E58E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:51:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so32178051edx.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:51:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3TgGXteFhRCHA/BcXIxir1s/cycIKmyrkuaHYejh8jk=;
        b=k0JTcz55R9ZEM5409OGPEdHLzwm37gwjsz6NA7r6TsWVyKVrycsGuZYzDCQXikv5Mb
         oJneR6tjqPVEbhD5bcldH1AOshpaHibYo4p3keCj/12XRyYyVSTmxFw7vvGawHjK6p3J
         B1mccyD0BDB71Ka8/F+updvs0+TKhh8cfum9HZUpOHcgbSojYMXQKlHmTFTtEcC1I8Sq
         uBuaZj2r43k/ug7CkzL3QSifkUP6vd80/gx5TGoRVXBYv+LqwU3GTdoVM/wv/6FzhWy9
         AT3HswJEEBVTygwfudAdOUGBGMeAStW8QrMRBVf2800FQtD10qCO8U+QWI+WWn/aSbIo
         c4zQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAW+qhSz4s88ENq+triaLUTrHyOuflDCU+39yTLSZLhLLyXKFoiX
	jAeOoPKCZNMu7e0dEqWevULFzaLbYAlFGRJ0HHPN25//vjc3CgIQkd8z2v6wa9x0JJoPemjlFPN
	ya5fNCdXf2Msw28nCRXBrSn7IVmpl2eTQIfW1r60PQDbBZ1w+VgwmBW0SNZB6q7lcug==
X-Received: by 2002:a50:9799:: with SMTP id e25mr75263014edb.79.1564062677935;
        Thu, 25 Jul 2019 06:51:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvZ4J4Y6Q7gkoUGyqlVoYk7ISLdB5syCmoFCmL3c7vyHPLMoHylMUAHJmTT5Mn4xL7sHZh
X-Received: by 2002:a50:9799:: with SMTP id e25mr75262956edb.79.1564062677130;
        Thu, 25 Jul 2019 06:51:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564062677; cv=none;
        d=google.com; s=arc-20160816;
        b=Uq34RyemZ+g3ukUBdTMhJZNm0UNAxV2dKsstwUWof9j4EIsaEMHg9zppToLZYnAcY+
         yOztN2zd2McXQELRO5cltqDfm+AEtZ54+PqhSWFgaXF8LxINYFsExyLtTQTxXim4VeZh
         6h5vUop4LEtvEA2rtgLQwaC7BpHxFyushBE3h01agJuzMNmRASw9ayZx9jl4opjKH3wG
         F03UTLNn8dL7w/fNBEZ6fwM7PMKPsO2WJLLRvIHDSvYg7PSPdWJvOwqatqx4cMiXlQK5
         zfAWzF5AM00uKeek5KbinzgUdylHvGnYdbg8YEUej+f7BDR9We/S0ZYPWHrzIQkdb2E+
         kPAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3TgGXteFhRCHA/BcXIxir1s/cycIKmyrkuaHYejh8jk=;
        b=Pdi+VpquU1TV6ZC8ywWxN/Eg8T2yy1ByXMhoAF12QMCGeDzNOUvysJZyqK3Fg4fUF7
         vRmbHApogvCBtAlWgAWbij+dGvtvqjy8f9E49HFwSeusI3bJ0lDz4R17llgBA0upohK/
         1UT3VfuubWPoyIgdj6DtG/6Qcuocx8mfOcOu5tvXswK7/0pGKMRmnb+rVdwi41LCpYbJ
         vrvBd3PHff4K8HNEpciY6IyU2WnVLHIj6buM/XrXL99UpiVePb5xzRUiBuNpKtuU9KEq
         anQ9umVCLz5pjnFSzCYPdhuNkscy90askZbXvIvrURCT36aUdlIASU0to09TaLDR09lw
         nmNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k21si9434469ejr.44.2019.07.25.06.51.16
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 06:51:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 287B31595;
	Thu, 25 Jul 2019 06:51:16 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AE0983F71F;
	Thu, 25 Jul 2019 06:51:14 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: vincenzo.frascino@arm.com,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>
Subject: [PATCH v6 2/2] arm64: Relax Documentation/arm64/tagged-pointers.rst
Date: Thu, 25 Jul 2019 14:50:44 +0100
Message-Id: <20190725135044.24381-3-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190725135044.24381-1-vincenzo.frascino@arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <20190725135044.24381-1-vincenzo.frascino@arm.com>
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

Relax the requirements described in tagged-pointers.rst to be compliant
with the behaviours guaranteed by the ARM64 Tagged Address ABI.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Acked-by: Szabolcs Nagy <szabolcs.nagy@arm.com>
---
 Documentation/arm64/tagged-pointers.rst | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.rst b/Documentation/arm64/tagged-pointers.rst
index 2acdec3ebbeb..933aaef8d52f 100644
--- a/Documentation/arm64/tagged-pointers.rst
+++ b/Documentation/arm64/tagged-pointers.rst
@@ -20,7 +20,8 @@ Passing tagged addresses to the kernel
 --------------------------------------
 
 All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+an address tag of 0x00, unless the userspace opts-in the ARM64 Tagged
+Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
 
 This includes, but is not limited to, addresses found in:
 
@@ -33,18 +34,23 @@ This includes, but is not limited to, addresses found in:
  - the frame pointer (x29) and frame records, e.g. when interpreting
    them to generate a backtrace or call graph.
 
-Using non-zero address tags in any of these locations may result in an
-error code being returned, a (fatal) signal being raised, or other modes
-of failure.
+Using non-zero address tags in any of these locations when the
+userspace application did not opt-in to the ARM64 Tagged Address ABI
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
+can be found in: Documentation/arm64/tagged-address-abi.rst.
+
 
 Preserving tags
 ---------------
@@ -59,6 +65,9 @@ be preserved.
 The architecture prevents the use of a tagged PC, so the upper byte will
 be set to a sign-extension of bit 55 on exception return.
 
+These behaviours are preserved even when the userspace opts-in to the ARM64
+Tagged Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
+
 
 Other considerations
 --------------------
-- 
2.22.0

