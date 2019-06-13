Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E863C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:29:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC45E2133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:29:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC45E2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772766B0003; Thu, 13 Jun 2019 01:29:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 748866B0005; Thu, 13 Jun 2019 01:29:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 610F96B0006; Thu, 13 Jun 2019 01:29:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 141486B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:29:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d13so29298066edo.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:29:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=B8xxex4ZNPNwnPt52l2xw6CNMPhHPZAZAKc0IZWi5Ss=;
        b=bpcDL74zjpsN/F0gvF3b2c8bDfb4jsWaCnkxqbvr6+RplkJwLyF2r3LMRC7h2sxoGL
         LYOdRp+rXacAyTrGsGPd8otmnLvU3bO5baQvYHzX8f9stnaFA69Z4PL6sD6ufaUtmp4Q
         dGehNYVahfBfLSUuwW3JwgS8gLzziyuFRUdn1uVBE9K3Emc3xOsg7SRGXgs23Drku+Qg
         8JqTIlg+n6QY75YkqvLr25Zl0cVWT4f8beYTuJl4WzLqOvX+mRSTx0pakNVaKikRzUyR
         1h5k7dzp3AvwOuRu9UFk9wi0LdBqJTrI5S4QAZWU0e/DwuyoXCVhifuhy90DoVNkJw4m
         guyw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVH4HgrNLiyhuzrFeZuc51cIlDlznO3x9hEfuXCXy7TzpD1MPZ6
	Pn2aX/287MLT1IBeNLCGfK4JFBoKpi9e6eEHJS1bhxsfltwP3rrWLQ/nFS5zed2QLMUX/esyRjH
	uLkvsDxXQdbqHE/wkA7vWXphOR2KxEUUSAUMP72vWLUuUga41Xz348jR5otPnTSs=
X-Received: by 2002:a17:906:4694:: with SMTP id a20mr60666551ejr.67.1560403777620;
        Wed, 12 Jun 2019 22:29:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl0cZE/RVbnTxzLZGXPsObTRLFDegaVUVOAFJbbbmpWTe6yD/hAmbj+Q9feqT3Uzhw70RT
X-Received: by 2002:a17:906:4694:: with SMTP id a20mr60666510ejr.67.1560403776694;
        Wed, 12 Jun 2019 22:29:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560403776; cv=none;
        d=google.com; s=arc-20160816;
        b=TAhDfQKK4v02fgZ1mbAvpyajrthHg+v7P1uT2FzpBwXhPljiHwgo2zSK1KWN0WuJ2P
         mlLMNUpSvNlP/8GsHB05/KN1GwZx+0X1CKVKPsFKZPudxoDDDJEW46rOAkJvx7ly5+bc
         saCMzOroNNRIzILQvBhFkO5n4rWQKKJKg7LBdLzzh2i3IrH994DQED0aUjLIHV3luscA
         /ewPmY2VsBwFIZYtyJ+XPFUNfh3dKOgmBtDralGzAzxLkq6VyMjKLk1E4PB7koeUEVh5
         Z1Q3VbDvjKU8oH9/LLe/onxTBYDjo1g3BPCNYlLu56X/UE2AYKXiqMm38YWAFBblpSuB
         BEqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=B8xxex4ZNPNwnPt52l2xw6CNMPhHPZAZAKc0IZWi5Ss=;
        b=U/oPHcUKtzG1hWRE9nq4KwOIrVE+2rf6uheieTZ04zI2miukj9E2u2vv2w30vFUWS9
         aQntw/ICTOu042aE+aC1P9krZJ1ejWVQCVof5EE1Biy2c6DvHcY0/sa6zYOIU68sLvbc
         dF987JXwSEGQyFQqZfWNH4WIGE0L3z9ZVfK3SbeGgVkq3y+w5Ohh0nuW/79UWXmGFHVj
         xq7lFpd7m3omEb+FbgfAYZj2Z5FQr584Z8DwmXzT53og+7lKXvPN+Ho8HUqeDl11miPW
         eG7teM1h67gKB7o0GQLOJT8J8L/FMKevnA6g/KOQiR3FdpCdZSLIYwR3JD+RwGGNF+++
         30hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id r15si1368223eju.331.2019.06.12.22.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 22:29:36 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 30F5620007;
	Thu, 13 Jun 2019 05:29:26 +0000 (UTC)
Subject: Re: [PATCH v4 00/14] Provide generic top-down mmap layout functions
To: Paul Burton <paul.burton@mips.com>
Cc: Christoph Hellwig <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Andrew Morton <akpm@linux-foundation.org>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190526134746.9315-1-alex@ghiti.fr>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <bfb1565d-0468-8ea8-19f9-b862faa4f1d4@ghiti.fr>
Date: Thu, 13 Jun 2019 01:29:26 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/26/19 9:47 AM, Alexandre Ghiti wrote:
> This series introduces generic functions to make top-down mmap layout
> easily accessible to architectures, in particular riscv which was
> the initial goal of this series.
> The generic implementation was taken from arm64 and used successively
> by arm, mips and finally riscv.
>
> Note that in addition the series fixes 2 issues:
> - stack randomization was taken into account even if not necessary.
> - [1] fixed an issue with mmap base which did not take into account
>    randomization but did not report it to arm and mips, so by moving
>    arm64 into a generic library, this problem is now fixed for both
>    architectures.
>
> This work is an effort to factorize architecture functions to avoid
> code duplication and oversights as in [1].
>
> [1]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
>
> Changes in v4:
>    - Make ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT select ARCH_HAS_ELF_RANDOMIZE
>      by default as suggested by Kees,
>    - ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT depends on MMU and defines the
>      functions needed by ARCH_HAS_ELF_RANDOMIZE => architectures that use
>      the generic mmap topdown functions cannot have ARCH_HAS_ELF_RANDOMIZE
>      selected without MMU, but I think it's ok since randomization without
>      MMU does not add much security anyway.
>    - There is no common API to determine if a process is 32b, so I came up with
>      !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].
>    - Mention in the change log that x86 already takes care of not offseting mmap
>      base address if the task does not want randomization.
>    - Re-introduce a comment that should not have been removed.
>    - Add Reviewed/Acked-By from Paul, Christoph and Kees, thank you for that.
>    - I tried to minimize the changes from the commits in v3 in order to make
>      easier the review of the v4, the commits changed or added are:
>      - [PATCH v4 5/14]
>      - [PATCH v4 8/14]
>      - [PATCH v4 11/14]
>      - [PATCH v4 12/14]
>      - [PATCH v4 13/14]

Hi Paul,

Compared to the previous version you already acked, patches 11, 12 and 13
would need your feedback, do you have time to take a look at them ?

Hope I don't bother you,

Thanks,

Alex


>
> Changes in v3:
>    - Split into small patches to ease review as suggested by Christoph
>      Hellwig and Kees Cook
>    - Move help text of new config as a comment, as suggested by Christoph
>    - Make new config depend on MMU, as suggested by Christoph
>
> Changes in v2 as suggested by Christoph Hellwig:
>    - Preparatory patch that moves randomize_stack_top
>    - Fix duplicate config in riscv
>    - Align #if defined on next line => this gives rise to a checkpatch
>      warning. I found this pattern all around the tree, in the same proportion
>      as the previous pattern which was less pretty:
>      git grep -C 1 -n -P "^#if defined.+\|\|.*\\\\$"
>
> Alexandre Ghiti (14):
>    mm, fs: Move randomize_stack_top from fs to mm
>    arm64: Make use of is_compat_task instead of hardcoding this test
>    arm64: Consider stack randomization for mmap base only when necessary
>    arm64, mm: Move generic mmap layout functions to mm
>    arm64, mm: Make randomization selected by generic topdown mmap layout
>    arm: Properly account for stack randomization and stack guard gap
>    arm: Use STACK_TOP when computing mmap base address
>    arm: Use generic mmap top-down layout and brk randomization
>    mips: Properly account for stack randomization and stack guard gap
>    mips: Use STACK_TOP when computing mmap base address
>    mips: Adjust brk randomization offset to fit generic version
>    mips: Replace arch specific way to determine 32bit task with generic
>      version
>    mips: Use generic mmap top-down layout and brk randomization
>    riscv: Make mmap allocation top-down by default
>
>   arch/Kconfig                       |  11 +++
>   arch/arm/Kconfig                   |   2 +-
>   arch/arm/include/asm/processor.h   |   2 -
>   arch/arm/kernel/process.c          |   5 --
>   arch/arm/mm/mmap.c                 |  52 --------------
>   arch/arm64/Kconfig                 |   2 +-
>   arch/arm64/include/asm/processor.h |   2 -
>   arch/arm64/kernel/process.c        |   8 ---
>   arch/arm64/mm/mmap.c               |  72 -------------------
>   arch/mips/Kconfig                  |   2 +-
>   arch/mips/include/asm/processor.h  |   5 --
>   arch/mips/mm/mmap.c                |  84 ----------------------
>   arch/riscv/Kconfig                 |  11 +++
>   fs/binfmt_elf.c                    |  20 ------
>   include/linux/mm.h                 |   2 +
>   kernel/sysctl.c                    |   6 +-
>   mm/util.c                          | 107 ++++++++++++++++++++++++++++-
>   17 files changed, 137 insertions(+), 256 deletions(-)
>

