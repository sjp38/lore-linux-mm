Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C679C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52B6120656
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:34:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52B6120656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06B5F6B0008; Wed, 17 Apr 2019 01:34:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A3C6B0266; Wed, 17 Apr 2019 01:34:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4CA96B0269; Wed, 17 Apr 2019 01:34:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 918496B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:34:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so11802129edo.23
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:34:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iSlMSAbalTlRLkI2S8vtmFwy6Fa3L9aABoAOjXi7jg4=;
        b=gb8Bszkj0TO85ZUs+1Lq4TqJeljQZbvZxkO3TFT5T+6mUu6oy3lm6AVdZckviY7i0Y
         2x7zsg4A2TNvr9xjfi2ayTffRFv/Bj5l+Q842MxEBTb2ez6hZCUIQUKcZGOwZLaWm61h
         8jLZaBlBHekcSC2igvAkVqKEltwa5aG3/m0/I7ue5axLFyt+bup9dNpFnDGDJCVszFP7
         sJSepnk4xHQW9NLkhVdO6BzWlJhC8Wf0RaSENawfxO3MX4D6oJezGtMi3aaz+qYcDryS
         VGnY+gcUaATcNNHhosbfVmIzjLX7XkzhRoHYHwNf2tU2jnARgwUFEau3KJoQpgwR53z9
         LwUA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUAQSQOB3DZ1GwUrETH5EsK5QPC4jUg7DQK3AgXGrgAy5NNcZf1
	cnXDVzKRPTQ+nxYUJ9INetJa7hU5Gnc1jHP9bB+0PlRQNTbwc+67HM2TdjYw9Gcl4PSn1FGLFaS
	QJFmV2zzdBAhQGX0zlHE5w4XjhbJJhpup2bjnScK5JKpH75Ao+mhZcE/uMIGKFDw=
X-Received: by 2002:a17:906:a841:: with SMTP id dx1mr44036418ejb.99.1555479295092;
        Tue, 16 Apr 2019 22:34:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWnGX+TkSvQMtL0qS9kn3+lisD5tINniCPZ8okPae3m2NosiBxgo8Nq9hNe0ncLkCrakT8
X-Received: by 2002:a17:906:a841:: with SMTP id dx1mr44036389ejb.99.1555479294120;
        Tue, 16 Apr 2019 22:34:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479294; cv=none;
        d=google.com; s=arc-20160816;
        b=Axxu4wEDHAMiQXA3yQq3mwJ+bWGExXl/CwgO2tSfUFufCKmmIfNw/Bw9AHm5N2GC3c
         B6s7Xhgbo0NIBirm2B6z8UjRi4fzBJEttLrQg1YT1V18FGJryXdYASm4pkPJ08bifc+e
         H3f79jLz0zBi/esJhY945mJEdop1HrcGq/9C7lJjKq9YP2uAJ82lIXk3UAhzh6S692pe
         b109XcEX+Q/KimxjVbOiU8WXOupz1rv64HSWuNEQoECSqioviIOAS92EDhajQcGPxqbH
         II3c5PYUzssL5fYoLyqjmz705MXyt4W+aLFJVVUYZ7H32MEM7XEB1SdsTUe4V4WEMg2N
         3meA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iSlMSAbalTlRLkI2S8vtmFwy6Fa3L9aABoAOjXi7jg4=;
        b=Y4jvS1I2qJmB/J6r0rhvO16uxYuhXuCcZNS6selT5ZO9CYg9wfYxuPsoryNLkKcv85
         FxOXwL8CROOhM6a33gkuLPa4gy0VAgJn+WQ7mDkdR4XGZ6bpL5ixhHqoXPeiLlyQZkkp
         Sbu0Mcm7/jZRFMQdtQnW9XaNy07ee5M/812sBtJhqL/5yNXLdxnoTF9KOKvLHGtfVhHL
         FcAEY5SgoJK95qnvSpx2LGc/BgyyO6CKknK/oOsOZ+y9iNmF6/uQddG58RWwwFU86MhQ
         ci8ORVrq1Erdl5Xn+HfvTxLtLjY+FQTJqPNonfFdMrMghPvePvT9/f4zlZphB+Qu7hHu
         5pcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id k29si1605602edd.337.2019.04.16.22.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:34:54 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 8DE831C0008;
	Wed, 17 Apr 2019 05:34:49 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
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
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 11/11] riscv: Make mmap allocation top-down by default
Date: Wed, 17 Apr 2019 01:22:47 -0400
Message-Id: <20190417052247.17809-12-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index eb56c82d8aa1..f5897e0dbc1c 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -49,6 +49,17 @@ config RISCV
 	select GENERIC_IRQ_MULTI_HANDLER
 	select ARCH_HAS_PTE_SPECIAL
 	select HAVE_EBPF_JIT if 64BIT
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
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

