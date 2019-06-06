Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7825EC28D18
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7902070B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:34:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7902070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A426B0270; Wed,  5 Jun 2019 22:34:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C015A6B0271; Wed,  5 Jun 2019 22:34:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B167A6B0272; Wed,  5 Jun 2019 22:34:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62C4F6B0270
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 22:34:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so1413348eda.10
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 19:34:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cxEQuqd0yZ/gKZU0a0zO+YSTLFZDIiB9zjIbZc+8/+o=;
        b=eMVyJZ5z85p558lLhWUsCBfqR6pAfcnBrd77WxYsXdgDtMOuGgKihTt7EqApXfoOK6
         IuEnc5KdrQ/kWsOrK4uszRgoU+6khD6jIq2+PzZm7N57XLdefmbBm057a1BAESUfKgC6
         VFcjbIovD338HL8UIK//cHYkRpLoulSLCCJ/4LlyO8AH40cLJjxjAZngCD6CyPyZgQU4
         C+AISEFi4MabAZ17PPKp6idH/osrS7s8/SWYHlsL+I9cwWlY8ufBsrIZlof6rJL11PjQ
         tSSrhhcbqJ75o0Ja2YIvFlb1UoFYuz5kbQa3kWP4xOH80WTfKkuL9Us8+tAGKs/0NSlE
         6cgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUHKlvvkegv5Kxh4EMnSrEdGkKqoFwoTCFTX828j6FLhaIAWcLC
	lmYJtMuYVG5hM40j/uqe1JGPxA0/rNWSXO0N4OnMujhiSFEW2JIPL4qB/hYsRsFTVFFiX96qxWV
	odqpq5rlgmnQYmypEFDxyVZTTNUF4D+oTKcyNmCLBu2sUjZbcZmz6uoj9aT+6gGG7Ug==
X-Received: by 2002:a17:906:55d4:: with SMTP id z20mr31070946ejp.205.1559788457946;
        Wed, 05 Jun 2019 19:34:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0t5xLUT6/qQJ9oW7l+MGIpSuZqP9bsXBIsbJ7bF8nblVnw0/LHRpTNtweOLTxBBLqUueh
X-Received: by 2002:a17:906:55d4:: with SMTP id z20mr31070888ejp.205.1559788457148;
        Wed, 05 Jun 2019 19:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559788457; cv=none;
        d=google.com; s=arc-20160816;
        b=EybUlOTotXqda1kAdK5mC9lJT4tnyluWEOi7jKmpjrCcYBPVEIlPKgo25sxrAV3ROx
         PzNQhNL4fktpHUB2UyGGBWUqIVNZW3Qm2TIOMe4lG8KXkBleorMU0mFXCnNRPD5mtZh4
         zhG7ExnfIXU/93wwLqutfjIup1nhruZ7SbOAb34vt1UaRtqYkywpiYO6Q85SQwgQq0zw
         +Rd57qXFNn1p7vHkZLPCmCkq6WV8+v3vTq6rPjicGNJgq3DcMeZnrDE2OPLx98C4N/sW
         p1A6pCb78VaBid2MdewgS+tHR0bgaU5KJdAX7+yAnG36TmcVkpbkL5WF1MWF3TmzyzDf
         Zvgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cxEQuqd0yZ/gKZU0a0zO+YSTLFZDIiB9zjIbZc+8/+o=;
        b=F9IHerlqp71X7bhchaSsYz+N2mGvr3fvAuiT4erSdsV13atSKjUATVBohyi57Z4o2T
         6tVulBY06ZmS2d0ZSqUBhnJPmBX8GjoSYqI0VqLpCXmlXXZk609S2GYIQvSMLN40Q8kC
         fHSmmESwdQjrtl3AHF+CwxdsdPypYqPCs6NtcFZj4ZHnYXZN/LbQKo5xa+eJFgFxrNLF
         1If0k0n2VcNoIBLN8A6l6FukCS+Ij5nv3ezC3DsrcOlpQeIrE2ZJZeWg4BDUhf6BRYS7
         CdTaMCUBGV2y9E6rw2ZtNJ0EFGrRTkdiMVVPWCp5AjE6sCfYuUTiwBBZFXqK0aPBTWV+
         QpTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f25si345155ede.206.2019.06.05.19.34.16
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 19:34:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C4CC980D;
	Wed,  5 Jun 2019 19:34:15 -0700 (PDT)
Received: from [10.162.43.122] (p8cg001049571a15.blr.arm.com [10.162.43.122])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B0AA13F690;
	Wed,  5 Jun 2019 19:34:05 -0700 (PDT)
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>, Paul Mackerras <paulus@samba.org>,
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
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <87sgsomg91.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6fdf7c1f-822b-22ec-f48c-cc0efc850644@arm.com>
Date: Thu, 6 Jun 2019 08:04:21 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <87sgsomg91.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/05/2019 04:49 PM, Michael Ellerman wrote:
> Anshuman Khandual <anshuman.khandual@arm.com> writes:
>> Similar notify_page_fault() definitions are being used by architectures
>> duplicating much of the same code. This attempts to unify them into a
>> single implementation, generalize it and then move it to a common place.
>> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
>> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
>> now contain upto an 'unsigned int' accommodating all possible platforms.
> ...
>> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
>> index 58f69fa..1bc3b18 100644
>> --- a/arch/arm/mm/fault.c
>> +++ b/arch/arm/mm/fault.c
>> @@ -30,28 +30,6 @@
>>  
>>  #ifdef CONFIG_MMU
>>  
>> -#ifdef CONFIG_KPROBES
>> -static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)
>> -{
>> -	int ret = 0;
>> -
>> -	if (!user_mode(regs)) {
>> -		/* kprobe_running() needs smp_processor_id() */
>> -		preempt_disable();
>> -		if (kprobe_running() && kprobe_fault_handler(regs, fsr))
>> -			ret = 1;
>> -		preempt_enable();
>> -	}
>> -
>> -	return ret;
>> -}
>> -#else
> 
> You've changed several of the architectures from something like above,
> where it disables preemption around the call into the below:
> 
>> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * To be potentially processing a kprobe fault and to be allowed
>> +	 * to call kprobe_running(), we have to be non-preemptible.
>> +	 */
>> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +	}
>> +	return ret;
>> +}
> 
> Which skips everything if we're preemptible. Is that an equivalent

Right.

> change? If so can you please explain why in more detail.

It is probably not an equivalent change. The following explanation is extracted from
RFC V1 discussions (https://patchwork.kernel.org/patch/10968273/). Will explain the
rational for this behavior change in the commit message next time around.

----------------------------
a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
b506a9d08bae ("x86: code clarification patch to Kprobes arch code")

In particular the later one (b506a9d08bae). It explains how the invoking context
in itself should be non-preemptible for the kprobes processing context irrespective
of whether kprobe_running() or perhaps smp_processor_id() is safe or not. Hence it
does not make much sense to continue when original invoking context is preemptible.
Instead just bail out earlier. This seems to be making more sense than preempt
disable-enable pair. If there are no concerns about this change from other platforms,
I will change the preemption behavior in proposed generic function next time around.
----------------------------

Do you see any concern changing preempt behavior in the x86 way ?

> 
> Also why not have it return bool?

Just that all architectures (except powerpc) had 'int' as return type. But we can
change that to 'bool'.

