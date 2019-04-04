Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F3DFC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18C81206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:57:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18C81206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CE3A6B0003; Thu,  4 Apr 2019 01:57:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87C9A6B0006; Thu,  4 Apr 2019 01:57:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 745FA6B026E; Thu,  4 Apr 2019 01:57:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26FFF6B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:57:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w3so798832edt.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:57:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y+bi4NQArS1VzeWh7XXC5FNgs+8EM5PQ5CBJ928Rp7U=;
        b=E+fVkwaql1y6uheqQRgA5BqQcme+C+39BbqMg3RaklPG78kH/uWVGsWRD2UJA0H2ZK
         9r0Qg1q0lsvhsVKLg5Gps7KIBBjB+G+UCCaWUomy09B9aGZW/D6eCiXd5qBuMyoKKW73
         pYbA7FHUL1fSf+2JtSKv74jx8c4tSbxQpcRTzmHFzxHOiAPBAWfwdGSmgLu7ArHBQLHf
         2+BhMjxbcqti7ptA099NGEdP9o9tvVt/RhtkyP+wT2D1XTpIogb3TBq4XdJWY3l+50Zs
         ZiUnimM4ids9+gZ+oXZnGUjV6IBz1EBEVjnyq1sTInRLmu+ketK4p4prs2TGkqWnvEjq
         jSuQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXu05D/Hn267HjU0Y6RldbxScv9arssN6a760+qPEbN7QZC2Du2
	Hzd4Jebm8zZ8FWBvnw6YvD72KZ5y3EOUgdjwG8b62g5IxGj8ig9KJSQidE2SoxcpC9p7nFC7k0U
	9ADq3e+lM889qpsg3QGdu8vyDv2UQnQioW2QIs4dtQRBno9bGuOn6hNiS6gmtZCU=
X-Received: by 2002:aa7:c803:: with SMTP id a3mr2454178edt.39.1554357425619;
        Wed, 03 Apr 2019 22:57:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0cZyrQfKpU9DzON8E+CDNVtj9QpP3x3XMrKAozscYLUVGRLLc/xcT2758hq2x1OPxRXcp
X-Received: by 2002:aa7:c803:: with SMTP id a3mr2454122edt.39.1554357424762;
        Wed, 03 Apr 2019 22:57:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554357424; cv=none;
        d=google.com; s=arc-20160816;
        b=UHqKSz1vOZsKDIOFUdwtRrxUu5uozfrNSGls0wjZBe8K4W+oxqVn1KaGRP7HE+dFpJ
         UqPqDEMrIuNO5ByEznWeWhC7ZMTVheAlo1R5o543Va0xe+P1R8PI2dzYqMRNSquAx+rg
         eqt6BGqi4MduyetGDw+eivuQjz6j4uet6LqJ7SXWluAl2KevKLRxLRi2qNAFu1W3Oqm1
         XycByctZgervlFlUxyWfNspfrOXUsekg+UW2NPf5qqtZustFqfmr4BPoqhOtcNopl5o5
         ctcDNCGJD52+GqtA9UK8yoGgoGg1Nz4jeVUYmcW3OyoBo38cpDakUkB06TUu+jJQsmKq
         Mr5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Y+bi4NQArS1VzeWh7XXC5FNgs+8EM5PQ5CBJ928Rp7U=;
        b=r1AbBWi6j/gD3Y7eq2v9DnhVBRETBzjdAdL+AeVketHjChQfRUaxsZXSle8BLHnVkS
         q3CCZK20vljLeiulecgWKtVZKjs0KuBofHFZ9xr+8ptQgSo9iFVf95m3uX/6uj5XknlC
         g+rh+nHt+4giwbBIEJJvIku0gaOn6fQ5RFFBh/Nsz0KFsEjVth7KKtl5lCAptHFaSFfj
         nZF8i3mjYrtGYe/AsWPwvvUfuFrBhPI5DUGxImQnalBibL7RvGVc/E/OvI8MbJmVK1Sm
         Lm8hfIM0j+Gnpxr0dCCblcPE58J4Ng/2QIkArU029KqIUgRv73vTUwUT6gLljv6UHB+3
         zfZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id f55si907239edb.217.2019.04.03.22.57.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 22:57:04 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 144E02000D;
	Thu,  4 Apr 2019 05:56:59 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2 5/5] riscv: Make mmap allocation top-down by default
Date: Thu,  4 Apr 2019 01:51:28 -0400
Message-Id: <20190404055128.24330-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404055128.24330-1-alex@ghiti.fr>
References: <20190404055128.24330-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000093, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to avoid wasting user address space by using bottom-up mmap
allocation scheme, prefer top-down scheme when possible.

Before:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
00018000-00039000 rw-p 00000000 00:00 0          [heap]
1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
155556f000-1555570000 rw-p 00000000 00:00 0
1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
1555574000-1555576000 rw-p 00000000 00:00 0
1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
155567a000-15556a0000 rw-p 00000000 00:00 0
3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]

After:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
00018000-00039000 rw-p 00000000 00:00 0          [heap]
3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/riscv/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index eb56c82d8aa1..fe09f38ef9a9 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -49,6 +49,17 @@ config RISCV
 	select GENERIC_IRQ_MULTI_HANDLER
 	select ARCH_HAS_PTE_SPECIAL
 	select HAVE_EBPF_JIT if 64BIT
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
+	select HAVE_ARCH_MMAP_RND_BITS
+
+config ARCH_MMAP_RND_BITS_MIN
+	default 18
+
+# max bits determined by the following formula:
+#  VA_BITS - PAGE_SHIFT - 3
+config ARCH_MMAP_RND_BITS_MAX
+	default 33 if 64BIT # SV48 based
+	default 18
 
 config MMU
 	def_bool y
-- 
2.20.1

