Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA9E9C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B5852087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B5852087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1036F8E001A; Tue, 30 Jul 2019 02:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08CD88E0003; Tue, 30 Jul 2019 02:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBECC8E001A; Tue, 30 Jul 2019 02:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4AA8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:06:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so39653743edt.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9RuQF310S86wrHSQrr0Pr/NRSfRDai7GSr6TTvA6MPE=;
        b=X2aQXjL/pW0Rp4AxLIE1lfuf3jJmblhxT0MIiJM0C/hjOaR/auC4UL9RNQeHbW+kjP
         C6XfgptBAkn1tQ+GtqAR/oJkwxhrqW/k3ychxX2jclmh6tUkJucMcLe1ve9PxOznfwS/
         RwEpeMpsOWwgWLUtR2d8oJd5SKnnBcl+/TdCJ6aL/gKmHGKYV+P998jJzm5QTaDyc9Fv
         C0CXi70uOVQ98hHYjYLZWTF7xVmA8p+H+v6FCaIMNFZE1LDSXGSyChfykhjKGs2OYd9e
         1Lifa0rnmvOnFs9oB77M337UkNMuz09KyWewUNFNEBACH9FHL/ivsFGTHMhDoGfdDCHv
         QnLg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUKrMRA21C8QUzj0lEmYC8oH+l+Ht0ViqngxUNkGPh/orqw0HXt
	6wTu/EttIrBKl35U+s0MfCOSDBfP4Z+ZX/y1ZsJNeY6Cado4bk9aCfyYUdCTRUxfpnc95Ybg1uZ
	h22BXt73tdrILP3m5s7OidOsrmYuFfupYOIjnDzuNpv49Nv9VaiQsoFAr01jJNOA=
X-Received: by 2002:aa7:d6d3:: with SMTP id x19mr99181007edr.119.1564466802197;
        Mon, 29 Jul 2019 23:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvpjs4arJj1/zeoOrmbAT0Iv2ZP9u0zUOTmRO/EAToz1EFrc9Tqax0yiAmgP47voJANjs8
X-Received: by 2002:aa7:d6d3:: with SMTP id x19mr99180943edr.119.1564466800978;
        Mon, 29 Jul 2019 23:06:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466800; cv=none;
        d=google.com; s=arc-20160816;
        b=pMvhyejkZrhVun7pqus9rF0FbQW7A3elVCC8amwqJoMdqMlsVp68SXu4ax4GvIhn07
         HYuTotJzu2WzdQFJOD8Axe2JOUde2AmKiG2VB92kACCquJxGXgVitMlHSKC97TQT01Iu
         EH+gr1vBvFBN2tSdtDRay8nmKnoMbb+e2fH7OliQEzni5tP8+FFic2ZOjVLGJC9KXrWs
         bTva+ccxKECwXo8pUdP0xDL0Q92tChGu17AoAj4M22VvpF7/FD+PmsDBx9rOn5UZGeoJ
         sVww+CsRLBgle634fubsP6789ZSyvsWz8zvDjWUezqgQogi7r/5w9thbfSyyPVmsPHpX
         STJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9RuQF310S86wrHSQrr0Pr/NRSfRDai7GSr6TTvA6MPE=;
        b=cxFClOcZ0m/awK2fj64P6ful8mL6EMvn2cnAdp0ld/m7sWgmrIpk5MHtY8EVVpSzfw
         S8YXPbeIexffSfTcVUek1RrVkIj7mDRQByd6UfFQ7e8FJCV4F5w/Fr4mxCteD/lWEOBa
         M3oZhoLFfgS8h9Jwfa1MwTyNmaF5XHNtyr6fgRP8y4Iv21iT6WQjsX2NbJZpAKnNTZ4E
         hjLL2Uj+HjBbFOAyBLPUrqkSIZVWm+UJmO4tPTox6+Y3DS18pFfy+yVWLUWNEAl9z4TR
         siz+KDfmy3qPFgrIbjBgtE2HVZc6FyXTg4bbsw177xtRLae/27vK8Cqv04H8QbUoKpdc
         Pnsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id p50si6565736eda.338.2019.07.29.23.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:06:40 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 9A460E0009;
	Tue, 30 Jul 2019 06:06:36 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v5 14/14] riscv: Make mmap allocation top-down by default
Date: Tue, 30 Jul 2019 01:51:13 -0400
Message-Id: <20190730055113.23635-15-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/riscv/Kconfig | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 8ef64fe2c2b3..8d0d8af1a744 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -54,6 +54,19 @@ config RISCV
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
+	default 33 if RISCV_VM_SV48
+	default 24 if RISCV_VM_SV39
+	default 17 if RISCV_VM_SV32
 
 config MMU
 	def_bool y
-- 
2.20.1

