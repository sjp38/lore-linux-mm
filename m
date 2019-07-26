Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BED22C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EAA721849
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:20:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="jToOEjgr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EAA721849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 180866B0003; Thu, 25 Jul 2019 20:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 132526B0005; Thu, 25 Jul 2019 20:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0495D8E0002; Thu, 25 Jul 2019 20:20:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9E036B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:20:53 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z19so56838488ioi.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=wVoyay7NO1Taf0v9T8BEjNVHV5CQV4op2+u8nOtjKhg=;
        b=N0blBtiDHdjaGMRbDlwvThfUweONSTsqXjwNsbwPRiG0ZCEx/35CucCLdeQ38NL/nb
         0w/lGfqPpvH2NMvRS4BVw6FwqkmpL98sGr0a/2hmCozO5nCOlZ+d1ZpEfzCn2gYFDtZO
         rsqZXaIsYeIYNoN/ty3rWuZND6HuUvKnqK8PFpeIR0pA6Lm/Fy62a2HiPZEZg3KH07R8
         V78Rm1V3gAp6QIiurjei7TPJRH8QBgbKotRvDUI2/D+15+Koins9AELKzIqZche3GxIP
         ZSlEzlBmZxa8hILiSWRqwq3DlNYlpZ2cOVRKvyODNvqr5vroeCc/2Zjl1rPqtCPX66X4
         mj7Q==
X-Gm-Message-State: APjAAAWu4ARgBi+UXvWxNvKhFtK7Gqkr4Y0Q0vkK5Gbyrme/T6SsPOSP
	n921OtWg0aysrSCPFIpps8v8k+GttBoBZT8ZHPf7LfpEJl5KFQY6m95YSUHaSujoE2p6TXyWii2
	SD7eRpzJauA7ItKTWOFsPXJ4XKQi4WcH+CBoK9tAK9RuucbvVavRjoGtGBf5mHj+/LA==
X-Received: by 2002:a02:b395:: with SMTP id p21mr95666367jan.31.1564100453657;
        Thu, 25 Jul 2019 17:20:53 -0700 (PDT)
X-Received: by 2002:a02:b395:: with SMTP id p21mr95666309jan.31.1564100452786;
        Thu, 25 Jul 2019 17:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564100452; cv=none;
        d=google.com; s=arc-20160816;
        b=CVhdKZr79FMI5ZdXoOMCMDN7ZRrczVBCiE0CXdulX+nmO3wwM9MgdtBHwrpK/PLq1Q
         fN/OxeQgkgZo9QTQnydezTmGAhGS7RzZNci/+HQ8SJD2aP2yzHa/W0swroMWaLIwAlr2
         Vtjj2pR6ohPBmKgN/EEEh4yZ1wn/Z55YEi+nF5/xCyzznpB7BKfSBusxcVaSpFikYZRO
         NrqEPh39SXeLmJeYkoU2ulfGc7uwClvZbgY0vTXkU41cT1klLxVKBu82z1cWr7p5ObWd
         WtVRRRgcINTOryZQKRMwxQMqmXSpG/eWhw0KfvLBOCz0YJ3yGp/QkXlYDNyd2yMNoxP7
         N/nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=wVoyay7NO1Taf0v9T8BEjNVHV5CQV4op2+u8nOtjKhg=;
        b=pWmG3mcRj1StLUgbkmsRNiuXB1esMq/biMhCx+pMUxABEZPWmStsMLjwJ/Tb9QbuRe
         I48ZjrjUMXiLuOQGQH0XnUQUt9ngBYwfA4V1B0ep5+vFXEhkOWwxf1++Sa3EZ8aSyZbF
         WYzTxK4rJQqO3ip05U+Yh2DSJgExa5b7GV2EzcxlA51FOyp8SoFKK1hDReEwtjW1fQhN
         h7HDIFNrjJiw+GNL/tSRwe/cO2kt3iQLenBE8p6ja5HPjyANQvP6LxQqu142FjOmBw86
         KGMJSLC37Hv7l9dsQ7DBNPQJLBQalRY1NxvdHFS4hqsjkfmKWz0xQJY6nGRfLWKLwlvL
         eD5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=jToOEjgr;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor34637007ios.17.2019.07.25.17.20.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 17:20:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=jToOEjgr;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=wVoyay7NO1Taf0v9T8BEjNVHV5CQV4op2+u8nOtjKhg=;
        b=jToOEjgrbrybRXQICjzzQLCzC6a+oGnvytylhhSA9uxtg6WnH51O9ifLdSV6bfGMfa
         q8niV4muBTTLsVTSbcEIiUpVX+Amr5OSrKkakw3SIsgJ8wNsZyQBOkBDr2dbL5g7FM01
         G/XkE2FByaeoL8V88ESwf2TAB2YZjUSsL0fYgL45Wj4T/V0LKEidele78SCI55EuL/J/
         sYl0p5itnLMSTOYg3+6E06sl9nRstqfUkqQp7Rox6hXNDgUyeGkR886lLScN+95mjm/T
         aOi3Bf5eztl/MGmlss1eZVgOtDl8Lkje5E83dmFr4AAMVpQxweZF/aXyNxTquIa66KkV
         3ymw==
X-Google-Smtp-Source: APXvYqwip5nwThbcgJqNtgafvdfTP5pQ2Oo0kmQagV/oOYV3+6lQkCabaIgCA6ODx3NeYEb64i78TA==
X-Received: by 2002:a6b:f80e:: with SMTP id o14mr15217081ioh.1.1564100452408;
        Thu, 25 Jul 2019 17:20:52 -0700 (PDT)
Received: from localhost (67-0-24-96.albq.qwest.net. [67.0.24.96])
        by smtp.gmail.com with ESMTPSA id 20sm54026778iog.62.2019.07.25.17.20.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 17:20:51 -0700 (PDT)
Date: Thu, 25 Jul 2019 17:20:50 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Alexandre Ghiti <alex@ghiti.fr>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Albert Ou <aou@eecs.berkeley.edu>, Daniel Cashman <dcashman@google.com>, 
    Kees Cook <keescook@chromium.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>, 
    Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    Paul Burton <paul.burton@mips.com>, 
    Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>, 
    linux-fsdevel@vger.kernel.org, linux-riscv@lists.infradead.org, 
    linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
    linux-arm-kernel@lists.infradead.org, Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH REBASE v4 14/14] riscv: Make mmap allocation top-down by
 default
In-Reply-To: <20190724055850.6232-15-alex@ghiti.fr>
Message-ID: <alpine.DEB.2.21.9999.1907251655310.32766@viisi.sifive.com>
References: <20190724055850.6232-1-alex@ghiti.fr> <20190724055850.6232-15-alex@ghiti.fr>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alexandre,

I have a few questions about this patch.  Sorry to be dense here ...

On Wed, 24 Jul 2019, Alexandre Ghiti wrote:

> In order to avoid wasting user address space by using bottom-up mmap
> allocation scheme, prefer top-down scheme when possible.
> 
> Before:
> root@qemuriscv64:~# cat /proc/self/maps
> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> 00018000-00039000 rw-p 00000000 00:00 0          [heap]
> 1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> 155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> 155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> 155556f000-1555570000 rw-p 00000000 00:00 0
> 1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
> 1555574000-1555576000 rw-p 00000000 00:00 0
> 1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> 1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> 1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> 155567a000-15556a0000 rw-p 00000000 00:00 0
> 3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]
> 
> After:
> root@qemuriscv64:~# cat /proc/self/maps
> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> 2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
> 3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
> 3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
> 3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
> 3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> 3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> 3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> 3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
> 3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/riscv/Kconfig | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> index 59a4727ecd6c..6a63973873fd 100644
> --- a/arch/riscv/Kconfig
> +++ b/arch/riscv/Kconfig
> @@ -54,6 +54,17 @@ config RISCV
>  	select EDAC_SUPPORT
>  	select ARCH_HAS_GIGANTIC_PAGE
>  	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
> +	select HAVE_ARCH_MMAP_RND_BITS
> +
> +config ARCH_MMAP_RND_BITS_MIN
> +	default 18

Could you help me understand the rationale behind this constant?

> +
> +# max bits determined by the following formula:
> +#  VA_BITS - PAGE_SHIFT - 3

I realize that these lines are probably copied from arch/arm64/Kconfig.  
But the rationale behind the "- 3" is not immediately obvious.  This 
apparently originates from commit 8f0d3aa9de57 ("arm64: mm: support 
ARCH_MMAP_RND_BITS"). Can you provide any additional context here?

> +config ARCH_MMAP_RND_BITS_MAX
> +	default 33 if 64BIT # SV48 based

The rationale here is clear for Sv48, per the above formula:

   (48 - 12 - 3) = 33

> +	default 18

However, here it is less clear to me.  For Sv39, shouldn't this be

   (39 - 12 - 3) = 24

?  And what about Sv32?
 

- Paul

