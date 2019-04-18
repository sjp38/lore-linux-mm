Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09E3BC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:01:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5626204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:01:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5626204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FA1C6B0005; Thu, 18 Apr 2019 02:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A5A06B0006; Thu, 18 Apr 2019 02:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 348936B0007; Thu, 18 Apr 2019 02:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D79626B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:01:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e6so648487edi.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:01:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=9+T2xjmVrGrpSevKpwgo43tMGe/Hbvkpe/WA+iCv3Bw=;
        b=cZQPdknjVQ+oUWjkt6mouaUgXR9MR8qYXztaadh243iobjZ9iq+yNjbN6vHLzEYZGV
         85yXciTLYcEcX9Zi6e+eXNgF0ZzhTHgkhQoEiEmkOujmZmnlBA0GonzrWYV0RDQNYPQe
         diw3CtJ32+5tcSkDisUMJEoS1n7GpmikoR1EhYnKSTH2/1heq8PY7qcYnivB5/ZWhmEI
         uBkYu/iO3LhX/Nqq6zcR3YMnYpHACfRySXv8G2zrCBqKdGGqHTmsPhsL4DdboOs0PYMn
         D9jL9h5sXQGsolhyyD9Pl2SHi8J+9FXRfpRS5jgYG1HW3VVQvhD8KOP47YmawA40R41L
         rzOA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWQ90YETQWU+8FhoG4uUUuBNI19NuClHed2Dm3fLfgyzcdCWt/G
	5vWnIj0y+Brt1SeaEjOZKb9qcDx5EkDIcCFvEU+0j5D1vFMJMl5g8ITXNC7pjVMH/ur0W7itqvH
	Ao+9tZLJ6PvdSJev1j80ejass4aUp+qyq/T7lO86s/SmVapdghty1pjB2BuEBQOM=
X-Received: by 2002:a50:b18a:: with SMTP id m10mr22749508edd.228.1555567287376;
        Wed, 17 Apr 2019 23:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAwcHt2S4JpE+/yy432TXuHdQyDaavqnHMpRJ+0BfafD9AeY8WbZx+wljsMtENPschnmBQ
X-Received: by 2002:a50:b18a:: with SMTP id m10mr22749458edd.228.1555567286545;
        Wed, 17 Apr 2019 23:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567286; cv=none;
        d=google.com; s=arc-20160816;
        b=xG/fOobAHg6IWVSZ6WKDv+DltR+2emf1aliIlOwwlRtleUYBtgng1l9Su7oDwgu+uL
         C14Ji0Emv7ip7rm1IrJAn9cubgwJTkizsI6jA3tEzj5DvS6ntmWXhOFgWbUnnLU5sxRo
         swX/jP/FIi1XoHDu4WD30o1SDvkbdsum7yyhnaKs9HiMI/2BKjy26394x9NVyFTS6ZD6
         l8UBKJU5hHq1YTjwi5wv5R14aPIVuoS7/ekMnPpjpxr5u4IL8E0UVboFV8M1MiPxO/GE
         ovk0VJv+gXhyizfkq1t2HMEkDczYlr0kmmVN3LsMr8aH1i8FjWuylkzocNEV8U5+KNLS
         TPMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9+T2xjmVrGrpSevKpwgo43tMGe/Hbvkpe/WA+iCv3Bw=;
        b=HkHTMvG2pwhn9Tydt5B0BS1s6BgMDdgXStJyyS5N7GThK8C7sFG2ddGY9f9pJ3AkpO
         FdAr8UUdf1g/SA1c5TpDwmYVaY4/KFXvQB85A3vfnyiB6mtNHYkKCPGrOY/zUCM/cBRc
         mbj/1ld8O21UsAbA+shIWxmXDSpC7TLZ9jQeC1AgHUQ4cvXXMlG3Wwe6VQlNnp7dFgw4
         ZAGBk+6C9WyDV9mZAkWB5f3b2SVi7tPwvlsfuSCmChd04dAavLZZtvv5hzbCppcE895k
         9HYqY9RT5u9K7WpTS81C9hVD6Yxgxt5QLCPUTZiIqr/cqa1V1ye6eBM3k/lxstLNdb+T
         WLHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id w23si655982eji.29.2019.04.17.23.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:01:26 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id D2FD11C0008;
	Thu, 18 Apr 2019 06:01:20 +0000 (UTC)
Subject: Re: [PATCH v3 05/11] arm: Properly account for stack randomization
 and stack guard gap
To: Kees Cook <keescook@chromium.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Paul Burton <paul.burton@mips.com>, linux-riscv@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mips@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 Luis Chamberlain <mcgrof@kernel.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-6-alex@ghiti.fr>
 <CAGXu5j+V_kJk-Lu=u82CrA291EPpgJtX951EKigprozXt7=ORA@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <dabdc658-62b0-4854-f84f-9c4672fce842@ghiti.fr>
Date: Thu, 18 Apr 2019 02:01:20 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+V_kJk-Lu=u82CrA291EPpgJtX951EKigprozXt7=ORA@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 1:26 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:28 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> This commit takes care of stack randomization and stack guard gap when
>> computing mmap base address and checks if the task asked for randomization.
>> This fixes the problem uncovered and not fixed for arm here:
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
> Please use the official archive instead. This includes headers, linked
> patches, etc:
> https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com


Ok, sorry about that, and thanks for the info.


>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> ---
>>   arch/arm/mm/mmap.c | 14 ++++++++++++--
>>   1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
>> index f866870db749..bff3d00bda5b 100644
>> --- a/arch/arm/mm/mmap.c
>> +++ b/arch/arm/mm/mmap.c
>> @@ -18,8 +18,9 @@
>>           (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
>>
>>   /* gap between mmap and stack */
>> -#define MIN_GAP (128*1024*1024UL)
>> -#define MAX_GAP ((TASK_SIZE)/6*5)
>> +#define MIN_GAP                (128*1024*1024UL)
> Might as well fix this up as SIZE_128M


I left the code as is because it gets removed in the next commit, I did not
even correct the checkpatch warnings. But I can fix that in v4, since there
will be a v4 :)


>
>> +#define MAX_GAP                ((TASK_SIZE)/6*5)
>> +#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
> STACK_RND_MASK is already defined so you don't need to add it here, yes?


At this point, I don't think arm has STACK_RND_MASK defined anywhere since
the generic version is in mm/util.c.


>
>>   static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   {
>> @@ -35,6 +36,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>   {
>>          unsigned long gap = rlim_stack->rlim_cur;
>> +       unsigned long pad = stack_guard_gap;
>> +
>> +       /* Account for stack randomization if necessary */
>> +       if (current->flags & PF_RANDOMIZE)
>> +               pad += (STACK_RND_MASK << PAGE_SHIFT);
>> +
>> +       /* Values close to RLIM_INFINITY can overflow. */
>> +       if (gap + pad > gap)
>> +               gap += pad;
>>
>>          if (gap < MIN_GAP)
>>                  gap = MIN_GAP;
>> --
>> 2.20.1
>>
> But otherwise, yes:
>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !


>
> --
> Kees Cook
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

