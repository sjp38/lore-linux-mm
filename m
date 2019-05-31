Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 699EFC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 04:50:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CBC7263D5
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 04:50:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CBC7263D5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B49C56B0278; Fri, 31 May 2019 00:50:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E926B027A; Fri, 31 May 2019 00:50:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FFE36B027C; Fri, 31 May 2019 00:50:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 322986B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 00:50:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so10266784ede.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 21:50:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=j8havF8nJOLY4+xtYvEfUdtUJ8PfAb/3DHlS8feWLHc=;
        b=I1zbuvQ4mYETSN7hyj1Gra73Bq4pgbz1ZmE7dQrrTxU0xcafRaWddh51WO/PNbSGDR
         VffnnxeFX5hAmi8MrGjiYtsLQ+ZkOzH1Wc0A8MqVyBRfg8miLBfFujpMQpgw4ojCWQQi
         jshXbJw7/ZSc0QNWs5gTRXQN2JCYfLf3JU0+x07AiS+6n80QIu6f6hlJGozKboKFWywi
         If+XOEx3DxCaOhQjGwLJsh6mCgcztTEfsPRqafhYZkuSlBw2BtKZB9CghDe8vJXaLIIj
         KCu0SiTcpUblE7XdD8yNb8q6pKNu1J4CkjpcpZaYPqqtBYB6ehzFota9tycXZldZX+ps
         vtcg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUt8OP2NQhs74IzRqKp1sArI0HQDlhK0foh+SY0kKHKbZ1dv0uc
	57H6Y/ZugIsDSRbUeoqX7lEzjUV5wu/AfpblQzN4M1WwWJI9Oue4fMT/AKf/WppFCata/lvscHM
	WqQTGxPsM0Ddlm3TQK0O5DPVKRy4BqlqzGnbyfS1UTQlME4UcV2FuZPl5G8wytTs=
X-Received: by 2002:a17:906:12ca:: with SMTP id l10mr7325623ejb.2.1559278200579;
        Thu, 30 May 2019 21:50:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV5acSxA8JmyAwlJ6pqXlBAfBpyo59eXwGiyWyLNvY2Sv1+r9DnZJQfgVuQ5HTSRay/C1B
X-Received: by 2002:a17:906:12ca:: with SMTP id l10mr7325437ejb.2.1559278196351;
        Thu, 30 May 2019 21:49:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559278196; cv=none;
        d=google.com; s=arc-20160816;
        b=nKIGqJR8/HB47Ct5mAPkbSg3T/B17OsPeA5IfxxErrIDGp1/jsf3lDso7YIQRi5pje
         7xeEFMPC7HoGMBKjQxIfg/PNkhuSJdd7bFBZnaX4xDZAhbS13hDdv9mvcnSvAzbPajFr
         B595RtXH7/+oXbapdn9Zie75vei5opPcFCU9uYLsU1MF4py905W/ZaHpMFJEjFePkZLI
         M+jOdH/OXJFSWzU47zwYwGqpSSFPBO6Qz5qlud2Ugm7j52ZXioB1dU3ogNkzLr1Igwe+
         ltXk2RCpdW1rnF8tftcu91B4Ssl+zx9W/rdUvbTn/QeQGPblVV4htOxNH6XNfQdf6EZX
         08bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=j8havF8nJOLY4+xtYvEfUdtUJ8PfAb/3DHlS8feWLHc=;
        b=p14bP4pkxfF/32BAOLw0aPJpMS7HjkhoqMXOFbgI/Wh0sAeXM+kcf7aCguElf/pljO
         VrptWEI0jZY2WOXFgmrm1itmMSzED7sTEWcqyGU++jd6ImZ9xcY1+wgm3IMnv1IZZD96
         CCNvsZjs0y7Zx+vgrEcXpKyOQnuIlQ0Oka/G/3OZQt/ZPcO/vnD71I9IJh0isvTW6Hjs
         5hbiAOkadxCwIw1u481pq5VNlvUX+W/BwV2qs5E26BxZaEZIpaNTpBZTJV95ZLuXZMQY
         mZs1SPHXQSRyMFP4gv+8T8Q5fjTZGRoQPaeaX/KbeZ1TmKC375hd/Tx+ux5EBW8XcwRQ
         8mgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id m18si3140560ejq.1.2019.05.30.21.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 21:49:56 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 18921100004;
	Fri, 31 May 2019 04:49:29 +0000 (UTC)
Subject: Re: [PATCH v4 08/14] arm: Use generic mmap top-down layout and brk
 randomization
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-9-alex@ghiti.fr> <201905291222.595685C3F0@keescook>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <b8c0c2e4-4d58-1d6e-5458-f0af3eb86d7c@ghiti.fr>
Date: Fri, 31 May 2019 00:49:29 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <201905291222.595685C3F0@keescook>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 3:26 PM, Kees Cook wrote:
> On Sun, May 26, 2019 at 09:47:40AM -0400, Alexandre Ghiti wrote:
>> arm uses a top-down mmap layout by default that exactly fits the generic
>> functions, so get rid of arch specific code and use the generic version
>> by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
>> As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
>> use the generic version of arch_randomize_brk since it also fits.
>> Note that this commit also removes the possibility for arm to have elf
>> randomization and no MMU: without MMU, the security added by randomization
>> is worth nothing.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>
>
> It may be worth noting that STACK_RND_MASK is safe to remove here
> because it matches the default that now exists in mm/util.c.


Yes, thanks for pointing that.


Thanks,


Alex


>
> -Kees
>
>> ---
>>   arch/arm/Kconfig                 |  2 +-
>>   arch/arm/include/asm/processor.h |  2 --
>>   arch/arm/kernel/process.c        |  5 ---
>>   arch/arm/mm/mmap.c               | 62 --------------------------------
>>   4 files changed, 1 insertion(+), 70 deletions(-)
>>
>> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
>> index 8869742a85df..27687a8c9fb5 100644
>> --- a/arch/arm/Kconfig
>> +++ b/arch/arm/Kconfig
>> @@ -6,7 +6,6 @@ config ARM
>>   	select ARCH_CLOCKSOURCE_DATA
>>   	select ARCH_HAS_DEBUG_VIRTUAL if MMU
>>   	select ARCH_HAS_DEVMEM_IS_ALLOWED
>> -	select ARCH_HAS_ELF_RANDOMIZE
>>   	select ARCH_HAS_FORTIFY_SOURCE
>>   	select ARCH_HAS_KEEPINITRD
>>   	select ARCH_HAS_KCOV
>> @@ -29,6 +28,7 @@ config ARM
>>   	select ARCH_SUPPORTS_ATOMIC_RMW
>>   	select ARCH_USE_BUILTIN_BSWAP
>>   	select ARCH_USE_CMPXCHG_LOCKREF
>> +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>>   	select ARCH_WANT_IPC_PARSE_VERSION
>>   	select BUILDTIME_EXTABLE_SORT if MMU
>>   	select CLONE_BACKWARDS
>> diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
>> index 5d06f75ffad4..95b7688341c5 100644
>> --- a/arch/arm/include/asm/processor.h
>> +++ b/arch/arm/include/asm/processor.h
>> @@ -143,8 +143,6 @@ static inline void prefetchw(const void *ptr)
>>   #endif
>>   #endif
>>   
>> -#define HAVE_ARCH_PICK_MMAP_LAYOUT
>> -
>>   #endif
>>   
>>   #endif /* __ASM_ARM_PROCESSOR_H */
>> diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
>> index 72cc0862a30e..19a765db5f7f 100644
>> --- a/arch/arm/kernel/process.c
>> +++ b/arch/arm/kernel/process.c
>> @@ -322,11 +322,6 @@ unsigned long get_wchan(struct task_struct *p)
>>   	return 0;
>>   }
>>   
>> -unsigned long arch_randomize_brk(struct mm_struct *mm)
>> -{
>> -	return randomize_page(mm->brk, 0x02000000);
>> -}
>> -
>>   #ifdef CONFIG_MMU
>>   #ifdef CONFIG_KUSER_HELPERS
>>   /*
>> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
>> index 0b94b674aa91..b8d912ac9e61 100644
>> --- a/arch/arm/mm/mmap.c
>> +++ b/arch/arm/mm/mmap.c
>> @@ -17,43 +17,6 @@
>>   	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
>>   	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
>>   
>> -/* gap between mmap and stack */
>> -#define MIN_GAP		(128*1024*1024UL)
>> -#define MAX_GAP		((STACK_TOP)/6*5)
>> -#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
>> -
>> -static int mmap_is_legacy(struct rlimit *rlim_stack)
>> -{
>> -	if (current->personality & ADDR_COMPAT_LAYOUT)
>> -		return 1;
>> -
>> -	if (rlim_stack->rlim_cur == RLIM_INFINITY)
>> -		return 1;
>> -
>> -	return sysctl_legacy_va_layout;
>> -}
>> -
>> -static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>> -{
>> -	unsigned long gap = rlim_stack->rlim_cur;
>> -	unsigned long pad = stack_guard_gap;
>> -
>> -	/* Account for stack randomization if necessary */
>> -	if (current->flags & PF_RANDOMIZE)
>> -		pad += (STACK_RND_MASK << PAGE_SHIFT);
>> -
>> -	/* Values close to RLIM_INFINITY can overflow. */
>> -	if (gap + pad > gap)
>> -		gap += pad;
>> -
>> -	if (gap < MIN_GAP)
>> -		gap = MIN_GAP;
>> -	else if (gap > MAX_GAP)
>> -		gap = MAX_GAP;
>> -
>> -	return PAGE_ALIGN(STACK_TOP - gap - rnd);
>> -}
>> -
>>   /*
>>    * We need to ensure that shared mappings are correctly aligned to
>>    * avoid aliasing issues with VIPT caches.  We need to ensure that
>> @@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>>   	return addr;
>>   }
>>   
>> -unsigned long arch_mmap_rnd(void)
>> -{
>> -	unsigned long rnd;
>> -
>> -	rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
>> -
>> -	return rnd << PAGE_SHIFT;
>> -}
>> -
>> -void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
>> -{
>> -	unsigned long random_factor = 0UL;
>> -
>> -	if (current->flags & PF_RANDOMIZE)
>> -		random_factor = arch_mmap_rnd();
>> -
>> -	if (mmap_is_legacy(rlim_stack)) {
>> -		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
>> -		mm->get_unmapped_area = arch_get_unmapped_area;
>> -	} else {
>> -		mm->mmap_base = mmap_base(random_factor, rlim_stack);
>> -		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
>> -	}
>> -}
>> -
>>   /*
>>    * You really shouldn't be using read() or write() on /dev/mem.  This
>>    * might go away in the future.
>> -- 
>> 2.20.1
>>

