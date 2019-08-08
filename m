Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4E17C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94407217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:33:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94407217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478046B000D; Thu,  8 Aug 2019 02:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429246B000E; Thu,  8 Aug 2019 02:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33D436B0010; Thu,  8 Aug 2019 02:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA4F86B000D
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:33:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so57548671ede.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hhD4vBSrp0XSthw0GklS6gaJ3KMWMaDwTu/gQP9IYFM=;
        b=YNQPfbL+HN4SZuzU5gdowYbwrEOTdUwZLzjkSFRyNFoJJGSkKUcAOeUQADbYatMwLl
         lG+8n/R90xdHVJgxJrCmJ6G0RC98j9qBIIXe39H/yA2eMCvzHU+OfnmIe5jN7Ttsobin
         ZMMYiSQb99d3iEY+CX7xWT4gFH1IVa2ieFLPpzUR1SYEbt03mCRzinRwodSRbyGLxLYL
         8TFUQJztt+McSaEj6/cE5kO02EJwOMVPHR65q2yxsHuRojpThbXq4yrZB6GLvI9Y/N04
         zSrzeg+kWBqQPQRGUATPvCzrmePwbsDJQF8R9DFy9LoGDVCBwprTrkAhgIqDFbboU7ZZ
         SSQA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUNA8cBeBWwIMRjtCoO7cn+UkKvnsFoeCV1hDJ7OVP1I5GSEuxq
	pQ8hI5sdKx34aWXpWrtiz0yI/VqNZXVJ24it93tor9ohL0dPrkdjzVJ/NlEowPwUBlJBw+ikCQi
	yre4pF8/K3udWWE0GcYaQseMSlT+grr8Jvf0x45o0uyp/wEJPApK+XRfHjXpMLOY=
X-Received: by 2002:a50:ba19:: with SMTP id g25mr13866080edc.123.1565246006486;
        Wed, 07 Aug 2019 23:33:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyLH7Xfv3KNAjnHDRQx/BwnLPJu7BRuPtABTSk2kRXDAB9HKDcywYrLefdtXezRLj3y69+
X-Received: by 2002:a50:ba19:: with SMTP id g25mr13866035edc.123.1565246005705;
        Wed, 07 Aug 2019 23:33:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565246005; cv=none;
        d=google.com; s=arc-20160816;
        b=CR8MnPXBNs1SCj89uEB+E4P71nzcjIJnWq+6Zf2ahowCi+5/fbZaUJqD/Dd5Sw0sul
         4lRkbw1eoHW91Xwe4FY2qn55IthCve5dKdodJ3OcyfFjIFTCq3SNr3cMdHmKVGxnPNJX
         4oqepvdgzps6SCTJfBL7PWvju5PMYZNlapxVX27wSA6La2oWQq5ATIZ1QiLNwqtz4iYF
         4EvggbB4xDxuasXdkzrRopW7EdppwwngrMUubyE3B/AIg2G+kNIQb8kRzLBYjTi1aclI
         eZKuxe149GIdIMACPpFWvsDqI3mlvvA6AR8Oq6P2/otQO0mqHUo6HzO7erahiG0es9pX
         z0VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hhD4vBSrp0XSthw0GklS6gaJ3KMWMaDwTu/gQP9IYFM=;
        b=fbdLWYVLF9G+tr7jaab8DKwAGoFTuCsnCJKLZqMVVLwRpx1+0m1DSQZaAL1vrq2bfv
         GusPlbYPxe63e4divqrb0KduXbRf6Km7UFSdk6sYkBU9wtuPwVAkgHXvBhbcvtyaa/Vn
         TpC6uIT66UyEcm8UYRJPZCNpeP71uRU0IgDXZ+xRpD0N2hjiI1KfQTnhiqeDdQismtGB
         To0mKaWdoruKXKxUZlXo0p2eMpN/AEE3vKHXm26bA5yu8ZHGQnHXjFDdDYLf1yZTKY2a
         onMP1yH6IdkIXT6D1cYHAwa8QkBKkae3kNTGXNGwYxfozU1FtCygHP1s0694mkREjiQL
         TExg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id 39si35107966edq.151.2019.08.07.23.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:33:25 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id 6957F1BF207;
	Thu,  8 Aug 2019 06:33:19 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 14/14] riscv: Make mmap allocation top-down by default
Date: Thu,  8 Aug 2019 02:17:56 -0400
Message-Id: <20190808061756.19712-15-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
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
2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
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
Acked-by: Paul Walmsley <paul.walmsley@sifive.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/riscv/Kconfig | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 59a4727ecd6c..87dc5370becb 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -54,6 +54,18 @@ config RISCV
 	select EDAC_SUPPORT
 	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
+	select HAVE_ARCH_MMAP_RND_BITS
+
+config ARCH_MMAP_RND_BITS_MIN
+	default 18 if 64BIT
+	default 8
+
+# max bits determined by the following formula:
+#  VA_BITS - PAGE_SHIFT - 3
+config ARCH_MMAP_RND_BITS_MAX
+	default 24 if 64BIT # SV39 based
+	default 17
 
 config MMU
 	def_bool y
-- 
2.20.1

