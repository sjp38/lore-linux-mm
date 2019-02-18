Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 849E5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:19:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B60821901
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:19:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B60821901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7C218E0004; Mon, 18 Feb 2019 09:19:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04168E0002; Mon, 18 Feb 2019 09:19:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3C78E0004; Mon, 18 Feb 2019 09:19:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41D4B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:19:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so7237428edi.5
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:19:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yB9n1opB3S3ygm4JCYimoHmvGjjBUdNy6nLYT9ppeRQ=;
        b=jvN5H/OfYAXde5RjFAE0ZW2ZQyRyddae320YCRu05vUkqU/jROP0bUkS9zOARb6f1G
         AMDBP2iWFZi3IeGDm8ZFk5v7L9bbSuSV5BaXH1d3PFMOVd924sx+LmVo75ZPnDtZ77LR
         oq7GBasRlPit8bJvcLb1q4P3k56xoXmyVDx6zNgZb5itI5Qe38LNo7SX9p0Jbi3tumZF
         9V/wRHszjwLGJx6aIpDRwpedpJ2qWHwARHYywMezPAzIEGYo7dgjKzEHZnRuqp7cALbf
         R4v9ZBqWaGtIFVd7wcOUw8KCP2lmKG9znqZc/3TGKF1BO6dWW4+Y1dgsz66QGO4lumuF
         draA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZtvNoXx5IMYV6oT7jGyQA7fik/Q2K3M+cHckx0cR3D+/tDs012
	7Uf8LBHQI8IiMsdIGGHTt2J15mz5pHGCSx/vB0gstCXsmF4m2PQ6nAckDYMyIbQ4GrEemlqozBp
	JO0Xlo3g8A5heC3gXqfr/XPmjS8E5lrTu/9O8kFxaPIOsE3T5syuq6Ys9urEKlsvoKQ==
X-Received: by 2002:a50:a666:: with SMTP id d93mr18472160edc.227.1550499575752;
        Mon, 18 Feb 2019 06:19:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iag8YrwsLU3V9YswgouRENyOYNZ9Q1meTvYQmuGkczn+NHl9kwbhRFYo99iuVgl2aWyMk5I
X-Received: by 2002:a50:a666:: with SMTP id d93mr18472105edc.227.1550499574886;
        Mon, 18 Feb 2019 06:19:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550499574; cv=none;
        d=google.com; s=arc-20160816;
        b=gHGK+Qj4wwaootiEIIRcTG16Xdgc/eQ+brWbMY6NSWLpxJQu4ZC+za0nJmLRQyq99M
         9Fj7ZMbtVDRa0v5F01GcvdDvzd/0VIXGGd/wcWlDNAzbXSqMdpzPBalemcZuJIC31s+B
         oMdFSVLIlOP7ywl2T+5zIKmelUCrOpLF5+mg7x75vS4aJj66WY1m9Jm03rQZr9A2bBhf
         ppzaI1J0V9+iMZ1kFAN73wPbi8rvcnX5sRcIradJNSiTDv6HdjaHagvcYNqTXQnW1Uk7
         xVXiXwjXYbWeEm2gNRS+4BCVVNKIe4EV8W14vBEcAowVZZahg/DM73uBB2KNoz2TJYah
         xVWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yB9n1opB3S3ygm4JCYimoHmvGjjBUdNy6nLYT9ppeRQ=;
        b=uRBhD3DIgVObd2zycKyZaLEHqvbfR6PSq0FgHw7gEEB1YoOQV4wC1pMNUGtKH9+bY0
         CjODj+/lCDkRRvp6WaoKXfIb9XwMrjgZOrGF783dn9y6mQT45+dQ4aECmCZXuX8RySql
         WIk6SAj3fdM8sowB+ew+Qv1Vqg6dphU+WJaNgR16Os+FHrDYD/D2fFWCsrrz+4Vcq7i1
         zSeImq5YEqG2hFBaM2sgHjJ1b3pQAKt5uBmVAzWKC9l+DQ7FvR34u9kIYyEvoVxZxEpf
         CbecuW8WqE7VBKVz2mGmj3b5dvyK7IG3JFtwUah49M5zCY5vtkwxHckDBbtl58Ec/s74
         Ctvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k52si1623970edd.233.2019.02.18.06.19.34
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 06:19:34 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B64AF15AB;
	Mon, 18 Feb 2019 06:19:33 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 770F73F589;
	Mon, 18 Feb 2019 06:19:15 -0800 (PST)
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Catalin Marinas <catalin.marinas@arm.com>, kirill@shutemov.name,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, kan.liang@linux.intel.com
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
 <20190218113134.GU32477@hirez.programming.kicks-ass.net>
From: Steven Price <steven.price@arm.com>
Message-ID: <aad21496-a86b-ca91-70b7-0c23ea6fefd3@arm.com>
Date: Mon, 18 Feb 2019 14:19:14 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218113134.GU32477@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 11:31, Peter Zijlstra wrote:
> On Fri, Feb 15, 2019 at 05:02:24PM +0000, Steven Price wrote:
>> From: James Morse <james.morse@arm.com>
>>
>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>> we may come across the exotic large mappings that come with large areas
>> of contiguous memory (such as the kernel's linear map).
>>
>> For architectures that don't provide p?d_large() macros, provided a
>> does nothing default.
> 
> Kan was going to fix that for all archs I think..

The latest series I can find from Kan is still x86 specific. I'm happy
to rebase onto something else if Kan has an implementation already
(please point me in the right direction). Otherwise Kan is obviously
free to base on these changes.

Steve

> See:
> 
>   http://lkml.kernel.org/r/20190204105409.GA17550@hirez.programming.kicks-ass.net
> 
>> Signed-off-by: James Morse <james.morse@arm.com>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  include/asm-generic/pgtable.h | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> index 05e61e6c843f..7630d663cd51 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -1186,4 +1186,14 @@ static inline bool arch_has_pfn_modify_check(void)
>>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>>  #endif
>>  
>> +#ifndef pgd_large
>> +#define pgd_large(x)	0
>> +#endif
>> +#ifndef pud_large
>> +#define pud_large(x)	0
>> +#endif
>> +#ifndef pmd_large
>> +#define pmd_large(x)	0
>> +#endif
>> +
>>  #endif /* _ASM_GENERIC_PGTABLE_H */
>> -- 
>> 2.20.1
>>
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

