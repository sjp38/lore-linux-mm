Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8F74C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 05:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EC562063F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 05:15:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EC562063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 034846B0008; Tue, 11 Jun 2019 01:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00FA6B000A; Tue, 11 Jun 2019 01:15:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA2436B000C; Tue, 11 Jun 2019 01:15:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 877A46B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 01:15:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so18877574eda.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 22:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MVYdUVF8TMhqeKNkMhTi4YFI1Gq+UcXcBKyW/cyJe+A=;
        b=IB3JVfvB10hhh6YcVKaqGZKqHimB3sGu1/oPGMEMa0wd/Ck1SukcSkyJpziYdg7ZMq
         qJekP6cvlNKaLjQWrdHWWU/JGNAUupVs5SfsrHCbY9zEkvfFS4RWP/uEeVCg6qpuWmW3
         5EFLs8vem2bnliSl7KxDATRfRgHuC156ve4seoQ2EtKtxPXxE42/9C4qfQ5DHAQolv9M
         jAS4s/va1zUaCW4DQnJZeLuO5Ehbn9Dg7UB9jmTJYOi/Ms+BQYbsKfW1Fh9m9mXNdUUs
         ESIs+zEVpjrb9rUxxgHwATj3gKlFtAwj6afTOK+5sSx0b1D17P2fzo/swMuPE+Vqn4oK
         Wa6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU1hwKZ0A8s6hQiiB5S1tx6CwLRGWD2Qba5Jwg7R/i9v1+4g72L
	VIyBNjZozEEffogPMtqqAi3SZDoqx1+08cTVS3F99n7NGDQhAh6hGKAYPEqad3ArJ26eNlkRWSz
	YXDZLARGIAwCe8ba6IGtXpmb4UpHI+CI2lseiIbrPBBR9p6tpnISzNFe2GB7EvRp1mg==
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr20619990eje.150.1560230121090;
        Mon, 10 Jun 2019 22:15:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGPVy1IxKXWp4eiwxbE8mezkdMkIRLx/N9EzLW9RrSVt+/kPzLY16rs1TmyoC4XRjd1u59
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr20619953eje.150.1560230120293;
        Mon, 10 Jun 2019 22:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560230120; cv=none;
        d=google.com; s=arc-20160816;
        b=BxXw13IReNHA0eoBFgpCXXB0Zupach2F51gG58x2tP3ICpMAUE5Vpg/+8BdgFLgo/1
         br38wj6TcW4q1trLTb0x5bekP3DkWYvqKH6nA8WXCUEyF7icHK7AlOSZaiSvE5P8OO6w
         QoLGHBcEgXjZ3B2Lh5qAwxu39rMHtqKpTSTQGIVo5oWiuvrcspGAt3dxHCQqINhQdQ2k
         B2OOUKw4SEVilWzSK4s2uCQdRrQ1mnor8KQ0uqWOwwE86TcaOnjUqPvDEq6Rg4TBmupS
         10y0xhhVCCZzK9xb1YA2UGFcc8+9mS/Cf66OPWzQizc0q4ZaW6Tb6ULkkU/LHwOeeswN
         biUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MVYdUVF8TMhqeKNkMhTi4YFI1Gq+UcXcBKyW/cyJe+A=;
        b=vDYON9jNlbJvAFPgKuf43aNOGaGs9PNdl/viMiP8UElDTNXspe/hpm7FI6JsFBEFJd
         IPLBN9XYcL7ThVOO7NtLuHDkUG3JwzfIS8R3sZ8V/JttTMiYz45I/N7GnPyo+FQw0Lyw
         Zkgoy23HZ7P7IBmjpwApKVSHyR2mXrK+D7nXYexxqmAADtNYsEo7MbWTwEQVrz5iTbDO
         xLr5etoZSvA8FxYLv8fUYuOFVgniBlsxQO914TzMFIAVX9l+q6OM2BkR9V72d5rSSqx+
         IgpIRzIs7ZqZc6an4sxWzJfdq6DdNUemEOJ+Tv80CfoZMfxcag1q5zMnjDMZzbFPIbw4
         Vvmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g9si2566639eje.145.2019.06.10.22.15.19
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 22:15:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 55CCB344;
	Mon, 10 Jun 2019 22:15:19 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5A7FF3F73C;
	Mon, 10 Jun 2019 22:15:11 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
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
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
 <f6d295c8-574d-3e64-79ae-2f7d3ff4c9f0@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <1875ab7a-204e-4150-c7cc-d282f69da724@arm.com>
Date: Tue, 11 Jun 2019 10:45:30 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <f6d295c8-574d-3e64-79ae-2f7d3ff4c9f0@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/11/2019 10:16 AM, Christophe Leroy wrote:
> 
> 
> Le 10/06/2019 à 04:39, Anshuman Khandual a écrit :
>>
>>
>> On 06/07/2019 09:01 PM, Christophe Leroy wrote:
>>>
>>>
>>> Le 07/06/2019 à 12:34, Anshuman Khandual a écrit :
>>>> Very similar definitions for notify_page_fault() are being used by multiple
>>>> architectures duplicating much of the same code. This attempts to unify all
>>>> of them into a generic implementation, rename it as kprobe_page_fault() and
>>>> then move it to a common header.
>>>>
>>>> kprobes_built_in() can detect CONFIG_KPROBES, hence new kprobe_page_fault()
>>>> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
>>>> now contain upto an 'unsigned int' accommodating all possible platforms.
>>>>
>>>> kprobe_page_fault() goes the x86 way while dealing with preemption context.
>>>> As explained in these following commits the invoking context in itself must
>>>> be non-preemptible for kprobes processing context irrespective of whether
>>>> kprobe_running() or perhaps smp_processor_id() is safe or not. It does not
>>>> make much sense to continue when original context is preemptible. Instead
>>>> just bail out earlier.
>>>>
>>>> commit a980c0ef9f6d
>>>> ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
>>>>
>>>> commit b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
>>>>
>>>> Cc: linux-arm-kernel@lists.infradead.org
>>>> Cc: linux-ia64@vger.kernel.org
>>>> Cc: linuxppc-dev@lists.ozlabs.org
>>>> Cc: linux-s390@vger.kernel.org
>>>> Cc: linux-sh@vger.kernel.org
>>>> Cc: sparclinux@vger.kernel.org
>>>> Cc: x86@kernel.org
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Matthew Wilcox <willy@infradead.org>
>>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>>> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
>>>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>>>> Cc: Andrey Konovalov <andreyknvl@google.com>
>>>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>>>> Cc: Paul Mackerras <paulus@samba.org>
>>>> Cc: Russell King <linux@armlinux.org.uk>
>>>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>>>> Cc: Will Deacon <will.deacon@arm.com>
>>>> Cc: Tony Luck <tony.luck@intel.com>
>>>> Cc: Fenghua Yu <fenghua.yu@intel.com>
>>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>>>> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>>>> Cc: "David S. Miller" <davem@davemloft.net>
>>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>>> Cc: Peter Zijlstra <peterz@infradead.org>
>>>> Cc: Ingo Molnar <mingo@redhat.com>
>>>> Cc: Andy Lutomirski <luto@kernel.org>
>>>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>>>>
>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>> ---
>>>> Testing:
>>>>
>>>> - Build and boot tested on arm64 and x86
>>>> - Build tested on some other archs (arm, sparc64, alpha, powerpc etc)
>>>>
>>>> Changes in RFC V3:
>>>>
>>>> - Updated the commit message with an explaination for new preemption behaviour
>>>> - Moved notify_page_fault() to kprobes.h with 'static nokprobe_inline' per Matthew
>>>> - Changed notify_page_fault() return type from int to bool per Michael Ellerman
>>>> - Renamed notify_page_fault() as kprobe_page_fault() per Peterz
>>>>
>>>> Changes in RFC V2: (https://patchwork.kernel.org/patch/10974221/)
>>>>
>>>> - Changed generic notify_page_fault() per Mathew Wilcox
>>>> - Changed x86 to use new generic notify_page_fault()
>>>> - s/must not/need not/ in commit message per Matthew Wilcox
>>>>
>>>> Changes in RFC V1: (https://patchwork.kernel.org/patch/10968273/)
>>>>
>>>>    arch/arm/mm/fault.c      | 24 +-----------------------
>>>>    arch/arm64/mm/fault.c    | 24 +-----------------------
>>>>    arch/ia64/mm/fault.c     | 24 +-----------------------
>>>>    arch/powerpc/mm/fault.c  | 23 ++---------------------
>>>>    arch/s390/mm/fault.c     | 16 +---------------
>>>>    arch/sh/mm/fault.c       | 18 ++----------------
>>>>    arch/sparc/mm/fault_64.c | 16 +---------------
>>>>    arch/x86/mm/fault.c      | 21 ++-------------------
>>>>    include/linux/kprobes.h  | 16 ++++++++++++++++
>>>>    9 files changed, 27 insertions(+), 155 deletions(-)
>>>>
>>>
>>> [...]
>>>
>>>> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
>>>> index 443d980..064dd15 100644
>>>> --- a/include/linux/kprobes.h
>>>> +++ b/include/linux/kprobes.h
>>>> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>>>>    }
>>>>    #endif
>>>>    +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>>>> +                          unsigned int trap)
>>>> +{
>>>> +    int ret = 0;
>>>
>>> ret is pointless.
>>>
>>>> +
>>>> +    /*
>>>> +     * To be potentially processing a kprobe fault and to be allowed
>>>> +     * to call kprobe_running(), we have to be non-preemptible.
>>>> +     */
>>>> +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>>>> +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
>>>
>>> don't need an 'if A if B', can do 'if A && B'
>>
>> Which will make it a very lengthy condition check.
> 
> Yes. But is that a problem at all ?

Probably not.

> 
> For me the following would be easier to read.
> 
> if (kprobes_built_in() && !preemptible() && !user_mode(regs) &&
>     kprobe_running() && kprobe_fault_handler(regs, trap))
>     ret = 1;

As mentioned before will stick with current x86 implementation. 

