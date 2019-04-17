Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B99DEC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D7152073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:22:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D7152073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C02B6B0008; Wed, 17 Apr 2019 01:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06F466B0266; Wed, 17 Apr 2019 01:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA0586B0269; Wed, 17 Apr 2019 01:22:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0AE6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:22:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y7so11970604eds.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:22:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=MfKX62sP+byjTlGphUtVjrlf8VKyM5n2uroo4BseXiI=;
        b=DUZAGOz9vYiWEnFUiy2M6pK2s9YVK9Khn3dLFahcPpUG2/RggtKBg5I1lVEGGUplRe
         AWLMExK4g6LXlauJceJJtKLwZ8ihwHLDrLpKlLcQS2eTbhTXYi2nsO3njUACStReWa8V
         CK3/+Dzl9lXsW1gfaff94DJMdxalv9Ye10vagelroRRaKvW3B56DPNkKmYa3oFkwHVcE
         Bp8UBM8WLHsGwS4eqM+yu/IRWBubBAi3k34V+Hven7tK19YQ6rSGd6S9avzUtqcjcjPN
         NJSAlHEGgQQ2J/ojpVR602K156hYPWgaGMSncB1EW/3rGQENb2kVePP5sLyH9QPhvuJG
         hhTA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV1SYjaDMhplzOMVP0Jgwkqt8ilK4ujsD3+8WKCe2Nv3UqW8ozJ
	+vfw2hwvWqh0krFR2WJuUqeQlphSF/MTI26Q+IdiQqnhokwv8UIoRPpmk1iWiJ5JI/v868SfUYu
	TC2IvSboRZZ3JLtgorft4TlyHyOIZxg2Klf4kT8WRtfqGuvOv77pjiUX3Op1xTjo=
X-Received: by 2002:a17:906:48c7:: with SMTP id d7mr46021309ejt.225.1555478577090;
        Tue, 16 Apr 2019 22:22:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIQ9pZADRhu6A/eYK0AfXEnUQj95xgXKdv176hpZgSRPuyaT+EFuXj5vY3Cp0CTyvIh+Vu
X-Received: by 2002:a17:906:48c7:: with SMTP id d7mr46021266ejt.225.1555478575970;
        Tue, 16 Apr 2019 22:22:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478575; cv=none;
        d=google.com; s=arc-20160816;
        b=UsxxNExnHV/lTfq+rU/gDbwFEJud9OyIlLRrW85LwHQIoRD/vp7htCcm0pNogN/9ji
         jSSOB1XVMy+/eJdvW1i9UTWInVoXy8tbOJyIpbetxqA3rQjrbW8bnTHLo6usFVJqjMRF
         eZeJrxhyJ2qWJCvaIXk70LvufIMJTXoP5aJONGYrh8Jetb+VISwwiTSnAARBaS9w9Khs
         NVoe5pD3FuaJLsukTOv+RxX25ReMqp1jpKOxAjvZrJ+t1+BK5mF11mU7IsSoNU8KxWzZ
         j4AOBWnF3904J380gB22Yj6qDQwugzc8RSyYJXz2VchiLD3xBWOjPZMjpDoY8qizA+pt
         b3MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=MfKX62sP+byjTlGphUtVjrlf8VKyM5n2uroo4BseXiI=;
        b=hCbVsFDv5rhkh0p+Tn6yGT8xASRGeCBTCw8l6As4jrRrM/qxss2eUyLqx4rQYApDHU
         s8E5w84Vd0C25Jl6NN0TmjGwlKoCZ0h99hj7miOEVv2yfNLDcGVLK4ord5Tns1LGwxXR
         lRCB9JEwavmLkAvKyjLAeERP8kClY0tMwPr3Pa3V0qUuci9RT4Gy7PgsXdu+/2a7MbhX
         7gh4eY8gV5e+39aTbYfPxtoMN/CijYi9elSYa5VwGf+H4li3FZZqkDuWBAV+qqiITIvS
         iTPPbhDDbVT1aslscHVZQkfMiJ2iXkOd0Sk6dDxGckL7WRZcG+8Tlwgn87xacF3wBySS
         g13A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id g16si6149294edp.174.2019.04.16.22.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:22:55 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id EC0EEFF808;
	Wed, 17 Apr 2019 05:22:49 +0000 (UTC)
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
Subject: [PATCH v3 00/11] Provide generic top-down mmap layout functions
Date: Wed, 17 Apr 2019 01:22:36 -0400
Message-Id: <20190417052247.17809-1-alex@ghiti.fr>
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

Alexandre Ghiti (11):
  mm, fs: Move randomize_stack_top from fs to mm
  arm64: Make use of is_compat_task instead of hardcoding this test
  arm64: Consider stack randomization for mmap base only when necessary
  arm64, mm: Move generic mmap layout functions to mm
  arm: Properly account for stack randomization and stack guard gap
  arm: Use STACK_TOP when computing mmap base address
  arm: Use generic mmap top-down layout
  mips: Properly account for stack randomization and stack guard gap
  mips: Use STACK_TOP when computing mmap base address
  mips: Use generic mmap top-down layout
  riscv: Make mmap allocation top-down by default

 arch/Kconfig                       |  8 +++
 arch/arm/Kconfig                   |  1 +
 arch/arm/include/asm/processor.h   |  2 -
 arch/arm/mm/mmap.c                 | 52 ----------------
 arch/arm64/Kconfig                 |  1 +
 arch/arm64/include/asm/processor.h |  2 -
 arch/arm64/mm/mmap.c               | 72 ----------------------
 arch/mips/Kconfig                  |  1 +
 arch/mips/include/asm/processor.h  |  5 --
 arch/mips/mm/mmap.c                | 57 ------------------
 arch/riscv/Kconfig                 | 11 ++++
 fs/binfmt_elf.c                    | 20 -------
 include/linux/mm.h                 |  2 +
 kernel/sysctl.c                    |  6 +-
 mm/util.c                          | 96 +++++++++++++++++++++++++++++-
 15 files changed, 123 insertions(+), 213 deletions(-)

-- 
2.20.1

