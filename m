Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC57DC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B7FC204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:06:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B7FC204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234176B0005; Thu, 18 Apr 2019 02:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3D36B0006; Thu, 18 Apr 2019 02:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2E86B0007; Thu, 18 Apr 2019 02:06:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B14146B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z29so678618edb.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=w98LP9hViyDTt7/5j6QACLrWfwJNv+xpk6mZx4faLks=;
        b=Op6mwu85fblTOdpVO8V6qDHXhxVIuZr9kWSRACid/XHuvwIZuS3afqEl3rVu7EKlzN
         KUeFLAMmYV8MT/2fkNM6BDrBEjkE7pDkhir+TcwA+AZGOK3kz+ymXttEzr5yyqvZpLhn
         6QlRiItI1fwzMLr/Q2hpXnHEOTULWVHwJR0P8wp4cIBHd3ib3XitGSUhG08yZzqvZm6k
         dFIkkNY4m06PSg1RLMQcbNUexFWHzni5/pLCB1bIgf94nVJp4mSXOGdjmri8hH9jK8xu
         6wE44e0y/f4wQW8TuSi6Sh28a2ugeghMUE2x6wC3aLoqGexu4QmBnrlfRpgINF5whjnr
         FPYg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV2d23emqN/DEmcNkiMOxWQxec/sD1KW0Ubx8gmSV9BrQADV0/b
	ci4blRq3vfJcnVMq3Vjgrls9Os+PC0AHPYO1LyQxneEyx/TkvzFX0F6ByQYSiuvNMIYZzYI2PoK
	qF1RsC7azch/AspxFNoQmMoZKz4tSCD1ofk+RHOyf4pzPQtwmhPMhL8ZeVwimnTo=
X-Received: by 2002:aa7:d899:: with SMTP id u25mr14740392edq.219.1555567575176;
        Wed, 17 Apr 2019 23:06:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNndL33QAz6oJqdw4Bvldoifj11al3CTe+0EDgotfaFAFr5fPdKyCNWKEeb3619sixZR04
X-Received: by 2002:aa7:d899:: with SMTP id u25mr14740345edq.219.1555567574341;
        Wed, 17 Apr 2019 23:06:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567574; cv=none;
        d=google.com; s=arc-20160816;
        b=NE3j/qjrLSJF1XEYhxuFL2J+MrOR5RpVc06l5NWPI8KrsuWXgAyjruGEvLG5UNlt0V
         hJHYI6b7PqQINy+j1EORnh2VaMF1cAPw54ZF0QXaK5V8WDXEi0cyFW0qXpD8cfRp7Ffu
         B6ErGeiaRr92LNdkYWux4R4sunMwvfUVbFQgwQhfrp3tSEe4P1NxgnNjVsYqJICMlIIt
         KSWvCsvc5nA9zMGmZ4mrVmbcistokjB5T0+eghKMx6DS9NycYlMGXN/3NsnJNJHwOcC+
         Uv/yOLbVN7tL1Kv37/8TL+eYX1Ho6EKi1vIqrB6R3KI+fBc+uB+bxPmKh1Vo1sibbFHM
         hCsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=w98LP9hViyDTt7/5j6QACLrWfwJNv+xpk6mZx4faLks=;
        b=enb0XLHOxxfpJRYF0kvzkU4RtvEn8cTWqVNtpwHeTpA1K5foYBcxXpPuWD4qv5mZ11
         NrG05S9johtI2Hzhn7+u2VQWycQThZL612wa2ZoT5wLBKUB7L9N11uOf8kbFSgQrRowi
         aUNSoPRzscZ7LSJ2bobbOMDT0it32pe+cv4z3PpQCViZt3UPpEvzT5HwOu2AfAEIMc15
         b9i0FdS18f9VkFTcqr+pJjKdVS9OKLipegW4/qxBtdmh+13+/VIs9f+EvObzX1t7wrX+
         ML36hPj1PDz46XA+eWb2MIIjpjOhVXJDINPZqHLTDygcPpKOWpCt04JhRoqWfVQdXCfV
         XmsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id n21si598564ejb.348.2019.04.17.23.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:06:14 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 6DE99100004;
	Thu, 18 Apr 2019 06:06:06 +0000 (UTC)
Subject: Re: [PATCH v3 07/11] arm: Use generic mmap top-down layout
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-8-alex@ghiti.fr>
 <CAGXu5jLhZS3+tiDCMsQQ=s9_f5ZBTLEYfcSfmtDRYv8Pp-KF2Q@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <5d0385b0-c03b-f4c7-45fa-4d97677cf816@ghiti.fr>
Date: Thu, 18 Apr 2019 02:06:06 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLhZS3+tiDCMsQQ=s9_f5ZBTLEYfcSfmtDRYv8Pp-KF2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 1:28 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:30 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> arm uses a top-down mmap layout by default that exactly fits the generic
>> functions, so get rid of arch specific code and use the generic version
>> by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !


>
> -Kees
>
>> ---
>>   arch/arm/Kconfig                 |  1 +
>>   arch/arm/include/asm/processor.h |  2 --
>>   arch/arm/mm/mmap.c               | 62 --------------------------------
>>   3 files changed, 1 insertion(+), 64 deletions(-)
>>
>> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
>> index 850b4805e2d1..f8f603da181f 100644
>> --- a/arch/arm/Kconfig
>> +++ b/arch/arm/Kconfig
>> @@ -28,6 +28,7 @@ config ARM
>>          select ARCH_SUPPORTS_ATOMIC_RMW
>>          select ARCH_USE_BUILTIN_BSWAP
>>          select ARCH_USE_CMPXCHG_LOCKREF
>> +       select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>>          select ARCH_WANT_IPC_PARSE_VERSION
>>          select BUILDTIME_EXTABLE_SORT if MMU
>>          select CLONE_BACKWARDS
>> diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
>> index 57fe73ea0f72..944ef1fb1237 100644
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
>> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
>> index 0b94b674aa91..b8d912ac9e61 100644
>> --- a/arch/arm/mm/mmap.c
>> +++ b/arch/arm/mm/mmap.c
>> @@ -17,43 +17,6 @@
>>          ((((addr)+SHMLBA-1)&~(SHMLBA-1)) +      \
>>           (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
>>
>> -/* gap between mmap and stack */
>> -#define MIN_GAP                (128*1024*1024UL)
>> -#define MAX_GAP                ((STACK_TOP)/6*5)
>> -#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>> -
>> -static int mmap_is_legacy(struct rlimit *rlim_stack)
>> -{
>> -       if (current->personality & ADDR_COMPAT_LAYOUT)
>> -               return 1;
>> -
>> -       if (rlim_stack->rlim_cur == RLIM_INFINITY)
>> -               return 1;
>> -
>> -       return sysctl_legacy_va_layout;
>> -}
>> -
>> -static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>> -{
>> -       unsigned long gap = rlim_stack->rlim_cur;
>> -       unsigned long pad = stack_guard_gap;
>> -
>> -       /* Account for stack randomization if necessary */
>> -       if (current->flags & PF_RANDOMIZE)
>> -               pad += (STACK_RND_MASK << PAGE_SHIFT);
>> -
>> -       /* Values close to RLIM_INFINITY can overflow. */
>> -       if (gap + pad > gap)
>> -               gap += pad;
>> -
>> -       if (gap < MIN_GAP)
>> -               gap = MIN_GAP;
>> -       else if (gap > MAX_GAP)
>> -               gap = MAX_GAP;
>> -
>> -       return PAGE_ALIGN(STACK_TOP - gap - rnd);
>> -}
>> -
>>   /*
>>    * We need to ensure that shared mappings are correctly aligned to
>>    * avoid aliasing issues with VIPT caches.  We need to ensure that
>> @@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>>          return addr;
>>   }
>>
>> -unsigned long arch_mmap_rnd(void)
>> -{
>> -       unsigned long rnd;
>> -
>> -       rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
>> -
>> -       return rnd << PAGE_SHIFT;
>> -}
>> -
>> -void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
>> -{
>> -       unsigned long random_factor = 0UL;
>> -
>> -       if (current->flags & PF_RANDOMIZE)
>> -               random_factor = arch_mmap_rnd();
>> -
>> -       if (mmap_is_legacy(rlim_stack)) {
>> -               mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
>> -               mm->get_unmapped_area = arch_get_unmapped_area;
>> -       } else {
>> -               mm->mmap_base = mmap_base(random_factor, rlim_stack);
>> -               mm->get_unmapped_area = arch_get_unmapped_area_topdown;
>> -       }
>> -}
>> -
>>   /*
>>    * You really shouldn't be using read() or write() on /dev/mem.  This
>>    * might go away in the future.
>> --
>> 2.20.1
>>
>

