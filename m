Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41E57C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:12:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0C2B24D92
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:12:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0C2B24D92
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40BDD6B0269; Tue,  4 Jun 2019 04:12:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397E66B026B; Tue,  4 Jun 2019 04:12:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25D366B026E; Tue,  4 Jun 2019 04:12:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9AE66B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 04:12:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g20so13618931edm.22
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 01:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1Tp2X+/2c/kNX/R10W4vqzWN3wemjAwqYi2N88qBeqU=;
        b=IMBCj+KLlzAvMRmKS12TK+6Lwo5yyOBHy0RfVxRWK2B77fbgV3PpbjosyvPKfTeV+F
         ZsZ9MclO8ImPSinfLYXkbw06Dl2uRkeZIJqrNaTkL1ZyMZ01ldpBVpU1V5aLiie0Vg7Z
         hGTFJIpioA4h4L73KRrxZrFmh2r6TOeoMGmHgPsi0Az7CtPD40L0Oyq1bfi0lWG825F3
         hYpU1VP6wsxGTNlGm+s/vhbEpY+QxXM4qA+uSw0miU2v29CFuUXZl0zgg0r4YjCdCfbs
         U+2K20NL88QNBkBJqfiq/SianpORWeq90Su+2AIlmsjbdYQJk8uOr53MABa60STS1sEk
         wDcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUGa7wpLeT1z0t6mr502tZM1jf+aFIo/XZGBD6jpxnvCV0P4ZOy
	rUpJ99Yp1oS8xuLHxNR2eoEudy99HwwDfrAJL2pnwDOdEyhO5sNttZhO6WPN+pqnlKeo+ylid0Y
	nhDm/KmqxWkcwMJjhP3+DbJKY5iIYJgsT4Wu/8M8zxYHmQkUSVXSnr6mOEyOtcz9HPg==
X-Received: by 2002:a17:906:e11a:: with SMTP id gj26mr12968977ejb.95.1559635928401;
        Tue, 04 Jun 2019 01:12:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaamBzSQ02lW0x+H+M86MP4E82Rurv9w3CizoatS42ec6qMTChQBT85VIICpu+3yHqBv/R
X-Received: by 2002:a17:906:e11a:: with SMTP id gj26mr12968922ejb.95.1559635927622;
        Tue, 04 Jun 2019 01:12:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559635927; cv=none;
        d=google.com; s=arc-20160816;
        b=m7a3u4LDUDrOteFz7mgGvanbNivHU1hhTG/dGfcEfmxh02gMmYNK0pqPSWhj4UVbvB
         cSseuspRVjmnHVanBQoalPZgtdUiPmK6RHVuRx6TEzLjkFXRL6VxI2w51ngYA4v1WB4s
         fJhm9DzWf/peIyyj8MwcY7kd5ydu4a4A5SSMQDX9h4QUI4mSowCVLtToRtESl9Ft1lVW
         xliCp7HRrVvRG9FWd58u+NR2nFX3vHttJW4QouA8T23Mz+rrthE8g6pbtMB84t1BOQ7i
         yYBPVHJbhuZ01uSvTeVdvIfTNp3QDqak5OW84Stu0jahBdJFM2+4SLxkiUSZQlByE/Nl
         A1lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1Tp2X+/2c/kNX/R10W4vqzWN3wemjAwqYi2N88qBeqU=;
        b=ntkWmvuaJdktjGfysozJ3wbjumHkxhVkkgL2igLDrqF05GLiqDJAlJWYduiYIaE9Yi
         nWbtDMzA3oU0uK6EfDrx66mRa/Tcl73MX6lL6TkakLLVvORDZd+Z0gBTDlXXgN+aisYr
         yKaDUNAFB7NKs8VEjhDS5C1JSHtDfs6bFqKXQnGh/b8QLWovHhKp61quxFL+AwHVv8/p
         Wd3XmVLQo4BvC2DFxbUZZZZ9GbFwc6OBWtyye+1QQZNA4z04BOl6uWNFDMpw4DWiVpL3
         38lFfHm1qsObteTzLrj55Lo2bxUF1TSUhqzUC5L1pDMu+8QhBn3gtrNcLpyuaBfoV7k9
         m5yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f25si3465542ede.206.2019.06.04.01.12.07
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 01:12:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 22F87A78;
	Tue,  4 Jun 2019 01:12:06 -0700 (PDT)
Received: from [10.162.40.144] (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 82BA43F246;
	Tue,  4 Jun 2019 01:11:55 -0700 (PDT)
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
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
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <20190604065401.GE3402@hirez.programming.kicks-ass.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <afe886e5-8420-0c33-ed2f-159cd3d55882@arm.com>
Date: Tue, 4 Jun 2019 13:42:10 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190604065401.GE3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/04/2019 12:24 PM, Peter Zijlstra wrote:
> On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
>> diff --git a/mm/memory.c b/mm/memory.c
>> index ddf20bd..b6bae8f 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -52,6 +52,7 @@
>>  #include <linux/pagemap.h>
>>  #include <linux/memremap.h>
>>  #include <linux/ksm.h>
>> +#include <linux/kprobes.h>
>>  #include <linux/rmap.h>
>>  #include <linux/export.h>
>>  #include <linux/delayacct.h>
>> @@ -141,6 +142,21 @@ static int __init init_zero_pfn(void)
>>  core_initcall(init_zero_pfn);
>>  
>>  
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
> That thing should be called kprobe_page_fault() or something,
> notify_page_fault() is a horribly crap name for this function.

Agreed. kprobe_page_fault() sounds good.

