Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F96EC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D95F620815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:48:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D95F620815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10D056B0003; Sun, 26 May 2019 09:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BDC16B0005; Sun, 26 May 2019 09:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEE386B0007; Sun, 26 May 2019 09:48:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE5A6B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:48:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y12so23237650ede.19
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:48:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=yFTs4fyLad6UncTfB3veuWFviRBWYra8OYYLkHWIQ0Q=;
        b=ch+Pc290j5/yvhaIyUq+Im88nzX1C+KyJ/O+8A0HleW7Rja9mSd7zc0qmA7MBYm0Kb
         AKu31OQ93HsRCQ/vG8EflJ/ayOSYTLDluUHNtCodZRtFaiHOEV6nhCiN0nirKEuy1Jwm
         DjOtcHDAezW97hfvpdEUfpvSY2hVPHKWHq2TzNBmoQ6cRZTQ62pEl+3VeH/+uFkJRpjy
         1fzCFINTb/oBnpSxqfZu7SQRWIfVxukaKofK7wnF5voQRkFeVtDDThf3Q7Joclga8rGP
         t4xZSwHml4z0N7W9ajC42r2nUWr+WlCpMp1glkD+Ga5uav8WuApTwC5xU1SLHAMQJ9dt
         1f3A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVmL1qz93B7vVheM/I5o+HZ273GOn0UtAxMnclLDlXoqqTE/h0G
	//Ggo9uCqQxE5VfofXT2Nzr+oTBUNgmc9Sv94ucgPS3R7bacE9qcbdPDS4jIa/otx918xCjOxWk
	Xn4TGolw5seegEwCptHuwV7HWbNHH3FMHRnrmO9Tm7sj3MMaElb9kjTPQWSfpaR4=
X-Received: by 2002:a17:906:1c4a:: with SMTP id l10mr25805935ejg.124.1558878480040;
        Sun, 26 May 2019 06:48:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNjT9MZxdaMQ0xfuWYvYPMOPchNquecnxh7FLH0dBGZuWB+j6F/mxUgJr2kKXGD5iMeS+z
X-Received: by 2002:a17:906:1c4a:: with SMTP id l10mr25805876ejg.124.1558878478927;
        Sun, 26 May 2019 06:47:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878478; cv=none;
        d=google.com; s=arc-20160816;
        b=Fl95g7cxtuADUNtVSDUbjESBAh6K74YNO65+5xitJNnCGC2hGGTtAoCZk0ZPxuCz7P
         m7h1NJRnMhpXdVs/25R0aBDh18u8UjF+YfRb9BKn9OO6k38wSyGS3HSzhXzKx/w7adPL
         YfLQaM0t3DZiZI4/iPxohC1Eu5Lb32MjgGiwtjo1c6jOXnHAWikyHMqCtkgLWSJ+L2l1
         TUkTnXbC3upoEouuaz0FLLkD9MAePzBJwjM1GbV61jjOjvbzvXEGmUDeYKkk/+1ULfxv
         mEQLl5JWPNhkmjT+8p34lAveSF1RyCEn8IujU0vA797Lh/Y6gxqKqw8krUoAypkvxr6r
         KyHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=yFTs4fyLad6UncTfB3veuWFviRBWYra8OYYLkHWIQ0Q=;
        b=meE7tSZW0y5hZ9Q8cD7Aem4us57qCmFegp9X7SAWcJezrawtgQI28Y5Y1VklBBgviI
         grSow8V1Gksql6qnqkS/XCATHJnQHC8CusJceTnShooCBaM1WGDLkM7O5UdpFt5vTaWC
         cD9kS9DatUjvfbvlj79woQpQKBaNedWAtqMivbZ+KOCgmBLjk2MQuNHqTq84Dx5VA5UV
         ab8uVcfxav0H62dCblDHJ7hR3Ds13S1U7jMDpE2JCutgeve/biSKhbhDLNJQwCzv1fzh
         JaGqXardk55asTCpEpTUfgF1UjlKiSdqU7Z055AIHStpneRdXpswBBMsU8n8ktrwxI/N
         dckg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id 35si3490189edz.410.2019.05.26.06.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:47:58 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id BD6A0100006;
	Sun, 26 May 2019 13:47:48 +0000 (UTC)
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
Subject: [PATCH v4 00/14] Provide generic top-down mmap layout functions
Date: Sun, 26 May 2019 09:47:32 -0400
Message-Id: <20190526134746.9315-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series introduces generic functions to make top-down mmap layout
easily accessible to architectures, in particular riscv which was
the initial goal of this series.
The generic implementation was taken from arm64 and used successively
by arm, mips and finally riscv.

Note that in addition the series fixes 2 issues:
- stack randomization was taken into account even if not necessary.
- [1] fixed an issue with mmap base which did not take into account
  randomization but did not report it to arm and mips, so by moving
  arm64 into a generic library, this problem is now fixed for both
  architectures.

This work is an effort to factorize architecture functions to avoid
code duplication and oversights as in [1].

[1]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Changes in v4:
  - Make ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT select ARCH_HAS_ELF_RANDOMIZE
    by default as suggested by Kees,
  - ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT depends on MMU and defines the
    functions needed by ARCH_HAS_ELF_RANDOMIZE => architectures that use
    the generic mmap topdown functions cannot have ARCH_HAS_ELF_RANDOMIZE
    selected without MMU, but I think it's ok since randomization without
    MMU does not add much security anyway.
  - There is no common API to determine if a process is 32b, so I came up with
    !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].
  - Mention in the change log that x86 already takes care of not offseting mmap
    base address if the task does not want randomization.
  - Re-introduce a comment that should not have been removed.
  - Add Reviewed/Acked-By from Paul, Christoph and Kees, thank you for that.
  - I tried to minimize the changes from the commits in v3 in order to make
    easier the review of the v4, the commits changed or added are:
    - [PATCH v4 5/14]
    - [PATCH v4 8/14]
    - [PATCH v4 11/14]
    - [PATCH v4 12/14]
    - [PATCH v4 13/14]

Changes in v3:
  - Split into small patches to ease review as suggested by Christoph
    Hellwig and Kees Cook
  - Move help text of new config as a comment, as suggested by Christoph
  - Make new config depend on MMU, as suggested by Christoph

Changes in v2 as suggested by Christoph Hellwig:
  - Preparatory patch that moves randomize_stack_top
  - Fix duplicate config in riscv
  - Align #if defined on next line => this gives rise to a checkpatch
    warning. I found this pattern all around the tree, in the same proportion
    as the previous pattern which was less pretty:
    git grep -C 1 -n -P "^#if defined.+\|\|.*\\\\$"

Alexandre Ghiti (14):
  mm, fs: Move randomize_stack_top from fs to mm
  arm64: Make use of is_compat_task instead of hardcoding this test
  arm64: Consider stack randomization for mmap base only when necessary
  arm64, mm: Move generic mmap layout functions to mm
  arm64, mm: Make randomization selected by generic topdown mmap layout
  arm: Properly account for stack randomization and stack guard gap
  arm: Use STACK_TOP when computing mmap base address
  arm: Use generic mmap top-down layout and brk randomization
  mips: Properly account for stack randomization and stack guard gap
  mips: Use STACK_TOP when computing mmap base address
  mips: Adjust brk randomization offset to fit generic version
  mips: Replace arch specific way to determine 32bit task with generic
    version
  mips: Use generic mmap top-down layout and brk randomization
  riscv: Make mmap allocation top-down by default

 arch/Kconfig                       |  11 +++
 arch/arm/Kconfig                   |   2 +-
 arch/arm/include/asm/processor.h   |   2 -
 arch/arm/kernel/process.c          |   5 --
 arch/arm/mm/mmap.c                 |  52 --------------
 arch/arm64/Kconfig                 |   2 +-
 arch/arm64/include/asm/processor.h |   2 -
 arch/arm64/kernel/process.c        |   8 ---
 arch/arm64/mm/mmap.c               |  72 -------------------
 arch/mips/Kconfig                  |   2 +-
 arch/mips/include/asm/processor.h  |   5 --
 arch/mips/mm/mmap.c                |  84 ----------------------
 arch/riscv/Kconfig                 |  11 +++
 fs/binfmt_elf.c                    |  20 ------
 include/linux/mm.h                 |   2 +
 kernel/sysctl.c                    |   6 +-
 mm/util.c                          | 107 ++++++++++++++++++++++++++++-
 17 files changed, 137 insertions(+), 256 deletions(-)

-- 
2.20.1

