Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9335EC5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 15:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2809B206E0
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 15:34:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2809B206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7323D6B0003; Sun, 30 Jun 2019 11:34:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E1388E0003; Sun, 30 Jun 2019 11:34:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AAB78E0002; Sun, 30 Jun 2019 11:34:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0686B0003
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 11:34:55 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id b21so14877078edt.18
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 08:34:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=+eIE4UMWuvn+dB/KcPGcqchizSxk6gGQMuIYFXIBUG8=;
        b=ju/ZiM5A17wF9tD+m+3tr/6mO74fq9uwzeV4ss1DRQ84zhIGIIm3zRZ1FWgNrOcSSP
         9TnxLL/PaNC5m0qtVGduGWhJuh1Xcf6iV2Oe5PHHHSs/NKmgRIlFjdsk3ueGTMC+4hE4
         KtAalsBgYhk2ckVdDKjCPOhjjq/MQKG4yjNOTeTxvpG84LdnmquVFYYHuD9M+cIszL+7
         vbBjBIVYVWvkgYozDOYSOmjG4or2v4QZXPnzZ6B8oDnIWI4w1i2DUA5i9u8iUQeEJLpd
         aZDF20b/BpTBWAsofzEIwDvVeLYY06O4eJoSWs9chlcPlUWfdRbrmRvXCzf7PmBc3mQo
         90jg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV2hEfKabw3u/RBaf/AmsYfPcuNNXWvot7Ty4OawtvMiO83u7y6
	7M8ghjGIWlJKOieg2WCVLAAHRMQ+r5z7VeE1qOl0GH7fhBXYBFu1Of9/Ao+mW9weu1/ygj7riP2
	0j1j7epk3ej8m1YuAMpA9dIL5oRWxeei8kahsI4wVgzHB9iBfnPxNzkvwaDoLPsw=
X-Received: by 2002:a50:b0e3:: with SMTP id j90mr23599225edd.26.1561908894478;
        Sun, 30 Jun 2019 08:34:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxotuDqbpAvCfOty4/tfSRKAp3Lv/yrGBOrsVbPbqGVIeYVEYqUO45GoYHkaZWOEn+0iXQn
X-Received: by 2002:a50:b0e3:: with SMTP id j90mr23599151edd.26.1561908893451;
        Sun, 30 Jun 2019 08:34:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561908893; cv=none;
        d=google.com; s=arc-20160816;
        b=nnvjCUDNQPmionTpqhIzFZdbqz2JUwzEzIgup8/8+qn28D5899npGY/2WrwYxDS1yp
         Kdge/PlS3+WM+v+B4honLJpSHfqUrwa4ucN0U+qRwjZjc2U8HvJWh0mu9ToEUvstwLYh
         e5bWogSqpoWI9jAXfuq3fRsCy1bbXN+LeaXEiiwSJQ20jm+FENbIPUYN1m/FGQ5kCr7K
         /Wt0f7geh+2o1NJ2osft3FVFWgq6uBXh0eQTkifTM8Vagvmmv2Do2WXBXh6XfnK01VqC
         155bgPFNTrhGPgoPB9fshYauKw027/2yBaApQNJrlrvjTU8gE3IMqb32+osfwzI2KaUu
         7rjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=+eIE4UMWuvn+dB/KcPGcqchizSxk6gGQMuIYFXIBUG8=;
        b=0dWtz/gDSu6vBtUC26CRK9uJKFWS+rRtDYAZ6YVju8oCUl1OOIMVBqOt9vIxPExczn
         sClLgLA3EI4ApYUDBKMAXSdtEgiKBKEdMfPMLPV11aLhQYaF/SCQzmh5QbIIownOH+Fa
         OI0gLtOWfSPvfNyOiq0Ds9+DlboUcMZv4aFJUwA6ALodgz7LJUY+sT4pheC3+679+RbJ
         W9Im2o2ELgjQECtQEBWzT3s8xuU51qzi0Vp9kgiKPNrvdTTBqmzFs9V4b76r1h43ytVg
         ElGgTxzgCCKonOFbdz+RqiqTHvoQ1baCEmTFRauV3awaZ2cWoAZnN16/z6J9vYWD3Mbd
         WCEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id b22si7011918edd.227.2019.06.30.08.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 30 Jun 2019 08:34:53 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 9122DE0004;
	Sun, 30 Jun 2019 15:34:41 +0000 (UTC)
Subject: Re: [PATCH v4 00/14] Provide generic top-down mmap layout functions
From: Alex Ghiti <alex@ghiti.fr>
To: Paul Burton <paul.burton@mips.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Luis Chamberlain <mcgrof@kernel.org>, linux-riscv@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190526134746.9315-1-alex@ghiti.fr>
 <bfb1565d-0468-8ea8-19f9-b862faa4f1d4@ghiti.fr>
Message-ID: <c4049021-50fd-32e5-7052-24d58b31e072@ghiti.fr>
Date: Sun, 30 Jun 2019 11:34:40 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <bfb1565d-0468-8ea8-19f9-b862faa4f1d4@ghiti.fr>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 1:29 AM, Alex Ghiti wrote:
> On 5/26/19 9:47 AM, Alexandre Ghiti wrote:
>> This series introduces generic functions to make top-down mmap layout
>> easily accessible to architectures, in particular riscv which was
>> the initial goal of this series.
>> The generic implementation was taken from arm64 and used successively
>> by arm, mips and finally riscv.
>>
>> Note that in addition the series fixes 2 issues:
>> - stack randomization was taken into account even if not necessary.
>> - [1] fixed an issue with mmap base which did not take into account
>>    randomization but did not report it to arm and mips, so by moving
>>    arm64 into a generic library, this problem is now fixed for both
>>    architectures.
>>
>> This work is an effort to factorize architecture functions to avoid
>> code duplication and oversights as in [1].
>>
>> [1]: 
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
>>
>> Changes in v4:
>>    - Make ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT select 
>> ARCH_HAS_ELF_RANDOMIZE
>>      by default as suggested by Kees,
>>    - ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT depends on MMU and defines 
>> the
>>      functions needed by ARCH_HAS_ELF_RANDOMIZE => architectures that 
>> use
>>      the generic mmap topdown functions cannot have 
>> ARCH_HAS_ELF_RANDOMIZE
>>      selected without MMU, but I think it's ok since randomization 
>> without
>>      MMU does not add much security anyway.
>>    - There is no common API to determine if a process is 32b, so I 
>> came up with
>>      !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].
>>    - Mention in the change log that x86 already takes care of not 
>> offseting mmap
>>      base address if the task does not want randomization.
>>    - Re-introduce a comment that should not have been removed.
>>    - Add Reviewed/Acked-By from Paul, Christoph and Kees, thank you 
>> for that.
>>    - I tried to minimize the changes from the commits in v3 in order 
>> to make
>>      easier the review of the v4, the commits changed or added are:
>>      - [PATCH v4 5/14]
>>      - [PATCH v4 8/14]
>>      - [PATCH v4 11/14]
>>      - [PATCH v4 12/14]
>>      - [PATCH v4 13/14]
>
> Hi Paul,
>
> Compared to the previous version you already acked, patches 11, 12 and 13
> would need your feedback, do you have time to take a look at them ?
>
> Hope I don't bother you,
>
> Thanks,
>
> Alex
>

Hi Paul,

Would you have time to give your feedback on patches 11, 12 and 13 ?

Thanks,

Alex


>
>>
>> Changes in v3:
>>    - Split into small patches to ease review as suggested by Christoph
>>      Hellwig and Kees Cook
>>    - Move help text of new config as a comment, as suggested by 
>> Christoph
>>    - Make new config depend on MMU, as suggested by Christoph
>>
>> Changes in v2 as suggested by Christoph Hellwig:
>>    - Preparatory patch that moves randomize_stack_top
>>    - Fix duplicate config in riscv
>>    - Align #if defined on next line => this gives rise to a checkpatch
>>      warning. I found this pattern all around the tree, in the same 
>> proportion
>>      as the previous pattern which was less pretty:
>>      git grep -C 1 -n -P "^#if defined.+\|\|.*\\\\$"
>>
>> Alexandre Ghiti (14):
>>    mm, fs: Move randomize_stack_top from fs to mm
>>    arm64: Make use of is_compat_task instead of hardcoding this test
>>    arm64: Consider stack randomization for mmap base only when necessary
>>    arm64, mm: Move generic mmap layout functions to mm
>>    arm64, mm: Make randomization selected by generic topdown mmap layout
>>    arm: Properly account for stack randomization and stack guard gap
>>    arm: Use STACK_TOP when computing mmap base address
>>    arm: Use generic mmap top-down layout and brk randomization
>>    mips: Properly account for stack randomization and stack guard gap
>>    mips: Use STACK_TOP when computing mmap base address
>>    mips: Adjust brk randomization offset to fit generic version
>>    mips: Replace arch specific way to determine 32bit task with generic
>>      version
>>    mips: Use generic mmap top-down layout and brk randomization
>>    riscv: Make mmap allocation top-down by default
>>
>>   arch/Kconfig                       |  11 +++
>>   arch/arm/Kconfig                   |   2 +-
>>   arch/arm/include/asm/processor.h   |   2 -
>>   arch/arm/kernel/process.c          |   5 --
>>   arch/arm/mm/mmap.c                 |  52 --------------
>>   arch/arm64/Kconfig                 |   2 +-
>>   arch/arm64/include/asm/processor.h |   2 -
>>   arch/arm64/kernel/process.c        |   8 ---
>>   arch/arm64/mm/mmap.c               |  72 -------------------
>>   arch/mips/Kconfig                  |   2 +-
>>   arch/mips/include/asm/processor.h  |   5 --
>>   arch/mips/mm/mmap.c                |  84 ----------------------
>>   arch/riscv/Kconfig                 |  11 +++
>>   fs/binfmt_elf.c                    |  20 ------
>>   include/linux/mm.h                 |   2 +
>>   kernel/sysctl.c                    |   6 +-
>>   mm/util.c                          | 107 ++++++++++++++++++++++++++++-
>>   17 files changed, 137 insertions(+), 256 deletions(-)
>>
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

