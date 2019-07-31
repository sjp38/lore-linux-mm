Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A400C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37D11206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37D11206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9A6B8E0005; Wed, 31 Jul 2019 02:05:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B234C8E0001; Wed, 31 Jul 2019 02:05:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C3DA8E0005; Wed, 31 Jul 2019 02:05:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 489368E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:05:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so41728961ede.0
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:05:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=MqJgnMfqUabt7G5ra2x8qYxYqtvy4l0Kam0LO5xhytQ=;
        b=TKshnUPy4GA+xqBAI2WzzcxHe2zZCl0bJUsYZduK6CEflo3Fei/ivImbBfufMgsxrH
         S5N3WsolaOmb5nqQwAZyeojSOTeMhc6uvIACA8PYRtfhgEV6TzH54crUnnViYKwQT9F3
         8Bj2p5SA1LYS9C8byPAU6RjS/dtMS/G6x/BQWMfQOnfFlnwzT68YADSYzrmfjgPUj1SW
         ZsslB/EdFjR6YPmEwJow6pAE+K6s7sdZKH29Kc6gQYz9nBsXRiBqDbqXaEsc2IOdEbUv
         11S/WvZCtAeI9a2AKn5aaqsHde2QDr6X6IQ437zQSwTJdStcbtFozThdyjBcHv+uta9h
         /Fkw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWrj+iKcmGkDiifQRs4RTct13bAnYfKAak7Ni1pjL09AYH0jXZz
	2pnXr1iwG/CIvZxJbaAH8FBQUnl4edJD70Ah12EliEizfscGOtfn95ZNCpGpaOgAopsaUe8esJ9
	Ejcymv0nJJmQQmdrsgPIqFwf4jA3hyfRIcyhaeqqUw8mQnYkct8gize1hFFYJ4/o=
X-Received: by 2002:a50:a784:: with SMTP id i4mr103634466edc.3.1564553131766;
        Tue, 30 Jul 2019 23:05:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKxM487kL6yDjbgd0KuCRap7iaZUNvqqpNDvXS3wDb5ooE3gAjmmCPqGTSuEEnqMKO/PjC
X-Received: by 2002:a50:a784:: with SMTP id i4mr103634402edc.3.1564553130854;
        Tue, 30 Jul 2019 23:05:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564553130; cv=none;
        d=google.com; s=arc-20160816;
        b=C20jfTvPMhKjkvRL2TFsPhCYC+dhuN6ndY1L6yhKnCtDED//vnp58MXmi+98u+m2v1
         gAnxW7B2uWaOKkXwYCDWP0HspBRuUooEoj6h1AP/NES5WJSBaxDI9LuJyJq6H2b6s2WH
         YduZIL4baLW5NuCWHPempqW2pp2e1qVFjfDHR0gSTt7RJQBUOMMAWs3QtkrfkUEywoI0
         G8RZ8gNkoNS37hv4Srsft1YLBRA1Bexa3Lc2/cfUv7trjOsELp67zkD6o1thAtfGOXpo
         BMDuxKLaNlXznfmd2wuzBVjVKvFJAe7uTeKQMM8RrzKrYs9Wg317+zmL2g4xoYu77vJd
         ilZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MqJgnMfqUabt7G5ra2x8qYxYqtvy4l0Kam0LO5xhytQ=;
        b=0SrwC0le9ebiLIBbpizsn9362IFYZQ0ePyhOLJBBWUbRo8KX3WbyFbltWclvXBMPZQ
         djnXZlYYglJzfxWbmvaZRcsQBLX7049dKHMsybwK+9EZW6HXNVtVfcm4CKzKj+uBVLrN
         K3WHOsfSO+KTAH7D0+29oDAdKmMP23xTLN4gZHTfr0KrhUwtCLPzf59NxS4lmouWtEVa
         xJbw2DehKl5cYU/IBRNA+qpnGB3CMTpbZ/EwoJrgfaDyX+aXnn53L+hu/JGPgC8RDuth
         Sr4Yu8ZrbzvcVPP8vOny2cEa2s2Dg/JxszmvSnDJryWTen+iA8TPdVOTrtV/+WcxPdoD
         wUSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id a5si20648584edc.73.2019.07.30.23.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jul 2019 23:05:30 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 68D61100008;
	Wed, 31 Jul 2019 06:05:23 +0000 (UTC)
Subject: Re: [PATCH v5 14/14] riscv: Make mmap allocation top-down by default
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>, Christoph Hellwig <hch@lst.de>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190730055113.23635-1-alex@ghiti.fr>
 <20190730055113.23635-15-alex@ghiti.fr>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <88a9bbf8-872f-97cc-fc1a-83eb7694478f@ghiti.fr>
Date: Wed, 31 Jul 2019 02:05:23 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190730055113.23635-15-alex@ghiti.fr>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 1:51 AM, Alexandre Ghiti wrote:
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
> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
> ---
>   arch/riscv/Kconfig | 13 +++++++++++++
>   1 file changed, 13 insertions(+)
>
> diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> index 8ef64fe2c2b3..8d0d8af1a744 100644
> --- a/arch/riscv/Kconfig
> +++ b/arch/riscv/Kconfig
> @@ -54,6 +54,19 @@ config RISCV
>   	select EDAC_SUPPORT
>   	select ARCH_HAS_GIGANTIC_PAGE
>   	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
> +	select HAVE_ARCH_MMAP_RND_BITS
> +
> +config ARCH_MMAP_RND_BITS_MIN
> +	default 18 if 64BIT
> +	default 8
> +
> +# max bits determined by the following formula:
> +#  VA_BITS - PAGE_SHIFT - 3
> +config ARCH_MMAP_RND_BITS_MAX
> +	default 33 if RISCV_VM_SV48
> +	default 24 if RISCV_VM_SV39
> +	default 17 if RISCV_VM_SV32
>   
>   config MMU
>   	def_bool y


Hi Andrew,

I have just seen you took this series into mmotm but without Paul's 
patch ("riscv: kbuild: add virtual memory system selection") on which 
this commit relies, I'm not sure it could
compile without it as there is no default for ARCH_MMAP_RND_BITS_MAX.

Thanks,

Alex

