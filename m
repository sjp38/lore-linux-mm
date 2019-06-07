Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 121A4C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABE10208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 15:31:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="eGVfNun4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABE10208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3145F6B000E; Fri,  7 Jun 2019 11:31:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EA736B0266; Fri,  7 Jun 2019 11:31:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D9576B0269; Fri,  7 Jun 2019 11:31:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C47C16B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 11:31:04 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i11so1013183wrm.21
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 08:31:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VmfDdFiLX51Z+4KXelOTCLHxqnwbZKmMb30NnGggSrg=;
        b=P7+EI3yLpjt0occCrQkyD4NybFlZ8xbTI98TSds73LVYZdObYyt+xoKy+DZ6L/MUeX
         1dBoj5ODnov5/y5JM0L8G2m2rckoIUpkLnIuK4/6AixvlCbKTIUQwy+odVEJ3HLLmXPP
         ybBmdVptKqT/JiWVaO09RAQBwz3OunBOfp26m4LHDB8SbGL3YJOv4Bcdz46NLrCUtznY
         3BGUUXMtzlECu+tgtv2YbPCqGET6E8z+5+WcDPcSexQOnBOMoCMthPq7/cU0ql1BtJeT
         XLnyQrQwvbyrxKKh4WKInUHx+3Ug04lXl4QWxsj8l31WD4+2ETmbZ0abIlaoH1ROye/V
         orRA==
X-Gm-Message-State: APjAAAXLq7tKz2gWcDn6EVglyAx6y7BAmPYfD7EvummgPRvtLDoJKtNe
	Lyc2G5md535XfdBLmv5LWD4400/fVKxbcJKOfidPPWHilKQFNmbnUJz6AF7Lj4KwP1CeHbUfSmS
	eQH4SUpDihkfqz55zd3YtHksioUEyl6kyDSFUlJt/whmg0UZ67wdbKcwr3w5TNJEKaA==
X-Received: by 2002:adf:de8e:: with SMTP id w14mr6650238wrl.130.1559921464331;
        Fri, 07 Jun 2019 08:31:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu2B3+5wV7tXieFkgqeg0bNOkZ8UGqXwyfjHAoH/Opq0N3yrIw4EAEAiUd735gZ50oLA2o
X-Received: by 2002:adf:de8e:: with SMTP id w14mr6650186wrl.130.1559921463473;
        Fri, 07 Jun 2019 08:31:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559921463; cv=none;
        d=google.com; s=arc-20160816;
        b=SO0ILidYca0hT5q4qY8mg4NaSN3FrG7OIc5upDZ+Xa1Fdyo+CWr8JNHlPqopx3sD8J
         FFcwW0vJPYNrtn00sc0wNIjo5rZqGy7fBLUeEM8Ko+gzj4l64U/1u97g3uxi0XtiXd1A
         s7EyplXFc8GYaLXGQrPJV7uGs6GEsaEKlljXr8rGpyQGQKjVXOakfe/uP8ozS5u8dNcU
         NO15/HkAXgh/X7xQaAa+OCF4+qwPxMKtqnvoZi2emH/DqNQX5el/itETJFvrFATfjSFr
         RordvbOVlsS9IjogWmTwCm0uknzS7RjYXhPaCLrS2726cL8b+sWEas7AHGR6zy4rWRmX
         bwiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=VmfDdFiLX51Z+4KXelOTCLHxqnwbZKmMb30NnGggSrg=;
        b=EnRzz0yjMuy0x4SAFbjy2SKKgYkxh2nmmKWFvG9cYQDrGG/W3XkB/78TCS0yXoB0H5
         Tnh8Cx6MRqlXoY7cXqhYEbJsecPo2Oiq/v1d1G4osnDpwA2ZbvmQhoZF1QGS2Q9wI48i
         Bv5sHTj3er4/rU8vHvKZE4QMCdVPkEahp6BgI9rKVwruSZUEBtTiyCCmCRcjLQVk/SxZ
         Q2i34TlfHDECX9YJO9CYVon0565lLzOF+klnd2h6ta/78XLCfiKqfYggIozGY9Ea4GUJ
         ZmKdiUYJkQaq2fgdPhoOJ3zI/6FG1BIWwBOaqHY7b4f+AFNLjBr0EnS3UDX6M0Eas11S
         7Iug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=eGVfNun4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q22si1513829wmc.123.2019.06.07.08.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 08:31:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=eGVfNun4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 45L61d14g1zB09ZC;
	Fri,  7 Jun 2019 17:31:01 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=eGVfNun4; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id x89FBxEH0k-2; Fri,  7 Jun 2019 17:31:01 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 45L61c6w95z9vDcN;
	Fri,  7 Jun 2019 17:31:00 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1559921461; bh=VmfDdFiLX51Z+4KXelOTCLHxqnwbZKmMb30NnGggSrg=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=eGVfNun43ICAVfa8ZTRLt9LZB+Sw+rVDTnJQrQQzRDQR1yqPQrK5CRYJQxf8p+Ipa
	 R1OpmRuRWrOPBIlhZSprzwJ/3NLXR8zDak3Nj1wnhzpk5JfCcrrPY7EoJV7dnEmkz3
	 YFKZL+PWpjANAl87vTbWY/TcYYwKl4VV2B3J7fwk=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 831ED8B8BE;
	Fri,  7 Jun 2019 17:31:02 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id s9MhfGu4umRg; Fri,  7 Jun 2019 17:31:02 +0200 (CEST)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.230.100])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0A6BD8B8BA;
	Fri,  7 Jun 2019 17:31:02 +0200 (CEST)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
Date: Fri, 7 Jun 2019 17:31:01 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 07/06/2019 à 12:34, Anshuman Khandual a écrit :
> Very similar definitions for notify_page_fault() are being used by multiple
> architectures duplicating much of the same code. This attempts to unify all
> of them into a generic implementation, rename it as kprobe_page_fault() and
> then move it to a common header.
> 
> kprobes_built_in() can detect CONFIG_KPROBES, hence new kprobe_page_fault()
> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
> now contain upto an 'unsigned int' accommodating all possible platforms.
> 
> kprobe_page_fault() goes the x86 way while dealing with preemption context.
> As explained in these following commits the invoking context in itself must
> be non-preemptible for kprobes processing context irrespective of whether
> kprobe_running() or perhaps smp_processor_id() is safe or not. It does not
> make much sense to continue when original context is preemptible. Instead
> just bail out earlier.
> 
> commit a980c0ef9f6d
> ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
> 
> commit b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
> 
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: x86@kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Testing:
> 
> - Build and boot tested on arm64 and x86
> - Build tested on some other archs (arm, sparc64, alpha, powerpc etc)
> 
> Changes in RFC V3:
> 
> - Updated the commit message with an explaination for new preemption behaviour
> - Moved notify_page_fault() to kprobes.h with 'static nokprobe_inline' per Matthew
> - Changed notify_page_fault() return type from int to bool per Michael Ellerman
> - Renamed notify_page_fault() as kprobe_page_fault() per Peterz
> 
> Changes in RFC V2: (https://patchwork.kernel.org/patch/10974221/)
> 
> - Changed generic notify_page_fault() per Mathew Wilcox
> - Changed x86 to use new generic notify_page_fault()
> - s/must not/need not/ in commit message per Matthew Wilcox
> 
> Changes in RFC V1: (https://patchwork.kernel.org/patch/10968273/)
> 
>   arch/arm/mm/fault.c      | 24 +-----------------------
>   arch/arm64/mm/fault.c    | 24 +-----------------------
>   arch/ia64/mm/fault.c     | 24 +-----------------------
>   arch/powerpc/mm/fault.c  | 23 ++---------------------
>   arch/s390/mm/fault.c     | 16 +---------------
>   arch/sh/mm/fault.c       | 18 ++----------------
>   arch/sparc/mm/fault_64.c | 16 +---------------
>   arch/x86/mm/fault.c      | 21 ++-------------------
>   include/linux/kprobes.h  | 16 ++++++++++++++++
>   9 files changed, 27 insertions(+), 155 deletions(-)
> 

[...]

> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
> index 443d980..064dd15 100644
> --- a/include/linux/kprobes.h
> +++ b/include/linux/kprobes.h
> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>   }
>   #endif
>   
> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
> +					      unsigned int trap)
> +{
> +	int ret = 0;

ret is pointless.

> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))

don't need an 'if A if B', can do 'if A && B'

> +			ret = 1;

can do 'return true;' directly here

> +	}
> +	return ret;

And 'return false' here.

Christophe

> +}
> +
>   #endif /* _LINUX_KPROBES_H */
> 

