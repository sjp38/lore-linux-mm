Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1875EC28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE88A2083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 02:03:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE88A2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 673656B026A; Wed,  5 Jun 2019 22:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FCF26B026C; Wed,  5 Jun 2019 22:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49E976B026E; Wed,  5 Jun 2019 22:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF6816B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 22:03:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so1309370eda.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 19:03:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gMYf1BADO0azQfvDWuzTpComdizhTslV+toCWOdGezI=;
        b=mJdBRkCCTJl4iLvGPYRBShn7QmkRpE2ykgwxQio/QiH11SbGH9lts+35h16D6mOfvP
         UZcG2i8Hpvy+OwgBo56wzdNvhU6L8CuuGFIZWy9BKCnGq36l4h9pmt1Yi0luQfChfLxZ
         rN2/yK/sq66NTPOKqJ9UWuUwie3HI1nkfqEJIBxq/FCPkUxgxPzibRnjdGdd2XToPRwB
         /vUB+ycQZr0PCrLO0uHMUer6Vrq/1B9zwp6wvoaSxPHYMBrKE8VJl4b0Le8OeCpUCdCZ
         9nGY6x42YvFRyaMkGG7rlqDokZ0McqU3jrEHzevILy1NMHw5iliP1XWMravyXdemLz8f
         wAkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVvXRxpQ2D6tjx5DDWyKNxCMlDjNASzXAahZR2fnLcFbePyHEHG
	GpkRix01re7XIeiuPYAV7mc0VQqK5K4IUEj5yb+rMvn9cJ/phs0BeFnYWRWGNi7Gkg8Do3LY8P+
	bmCokDIVmrw+DlXlKU9axwD4JnpZyj2GRGpmlry0uGOQVZ9hylEHWv0itCtfHw1f3Yw==
X-Received: by 2002:a17:906:2650:: with SMTP id i16mr11682393ejc.40.1559786628533;
        Wed, 05 Jun 2019 19:03:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztX9jJnGayZkpQc6SFUMRE2cRmjNlAHS9FcNzAAWRC9XLu78hk9K1dS+9mmssiic7Vay4K
X-Received: by 2002:a17:906:2650:: with SMTP id i16mr11682340ejc.40.1559786627716;
        Wed, 05 Jun 2019 19:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559786627; cv=none;
        d=google.com; s=arc-20160816;
        b=G2GgREqfjR0y3CQEotoN0OwdkJcjg+igxkxHrVdirwm4E1d89BfKXibt0lJw1PiQgl
         v9LXlHFglhDw4lx6Il6bnYyNuBgU0sJ+XvdFZe89AOJH0CSYqa3BBB7DP/1ZaHLadfWc
         ys2wvvFQHpSQFcvKQjGyHta9kYq/+lbR4SLKjJEa2L1L2s3xDp+dFsbj85bPSDoLkigc
         8+ZdCeg/VLHZDl/al2leTh0EBAy5vutDpHlwgJctGdJ5ykZm6q+JjuDuRlDuT7GJY/w1
         eWC1dSzOZEO4+w2CZOxqLVd6+teVNcY6cJsZjrKSsKzRLk7g/ZBgNQ/+rD6m4/9xKaTX
         ZK+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gMYf1BADO0azQfvDWuzTpComdizhTslV+toCWOdGezI=;
        b=fVDLCo26Qe372UplT9vodLf+FKTHCubcwoVAi1oqUC2x37XU4sDILFpkxKx23PzGve
         9aQW55ONMgs/KJQrt+t5ADsF2aRrBaJUhwQV1nWoJz/HclTKXha2VNpOnY6lfwFoGgNc
         2hxBtlcrXo4VbB6rlnpzt6Kew5h969F7d3khgs+mUmp85hKVO677tBqISrpC/6wjIv71
         pVRE63BKy4Oj66qUO3fJuDoDkE8C7HHyefPcqd0jM6VsxTUkI7y+PBHpkiUIM16bD/nf
         wbRWc0dv12zlB4uO1tesG4EAnN5IZ7s7vK7Di7+hWAgQiwn7hZjSwzZEr/3SLGUCD4hs
         WZ5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y9si280234edb.262.2019.06.05.19.03.47
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 19:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F1A9D80D;
	Wed,  5 Jun 2019 19:03:45 -0700 (PDT)
Received: from [10.162.43.122] (p8cg001049571a15.blr.arm.com [10.162.43.122])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 519F83F246;
	Wed,  5 Jun 2019 19:03:37 -0700 (PDT)
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
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
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <20190604215325.GA2025@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <016a4808-527d-7164-b8a0-3173a4ecfa25@arm.com>
Date: Thu, 6 Jun 2019 07:33:52 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190604215325.GA2025@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/05/2019 03:23 AM, Matthew Wilcox wrote:
> On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
>> +++ b/arch/x86/mm/fault.c
>> @@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
>>  	return 0;
>>  }
>>  
>> -static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
>> -{
> ...
>> -}
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0e8834a..c5a8dcf 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1778,6 +1778,7 @@ static inline int pte_devmap(pte_t pte)
>>  }
>>  #endif
>>  
>> +int notify_page_fault(struct pt_regs *regs, unsigned int trap);
> 
> Why is it now out-of-line?  

Did not get it. AFAICS it is the same from last version and does not cross
80 characters limit on that line.

> 
>> +++ b/mm/memory.c
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
>> +
> 
> I would argue this should be in kprobes.h as a static nokprobe_inline.

We can do that. Though it will be a stand alone (not inside #ifdef) as it
already takes care of CONFIG_KPROBES via kprobes_built_in(). Will change
it and in which case the above declaration in mm.h would not be required.

