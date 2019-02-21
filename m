Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F362CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D90920700
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D90920700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BAF18E0088; Thu, 21 Feb 2019 09:46:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 044298E0002; Thu, 21 Feb 2019 09:46:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E278A8E0088; Thu, 21 Feb 2019 09:46:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 867278E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:46:26 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d16so5279477edv.22
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:46:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ccyA43whd4rLLZbIbLAZt5fc3XdqqqCa9r6nyyPA2Co=;
        b=I/hpcikQ/TwIg/Sn+YQbsWy8dn85SKSDXlwEFtEeGcCbad1KbKc0R/lyKJAJ85Nz0D
         PgMwYD8NzqO4GCKFHBLZhO7fSIgNM3HbCVDSkzeyIftpfgfhYQ/tL3b5KHR/Mavr8h7S
         i93CQ8gPoP1KScYZbPfhynkBKC2jZE7vPYOKkXhyEVxyNFz/0UyFRta0/6vNBS6v2jne
         2yGLse+Xr2ll0jrFIg23W/pLFUkE1/VMkDBYj5/4lhghrZxj9zXdFQd4y+4ygFfCHMZA
         ECzq/Kn4FgHXjm5SNUQ24IJBJbX3k0jURYPc5PxvsbazOOVEcNwzgcxFoWXDHMDUVF2x
         hujQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub0xrBCj3GNYLU/aHUU9WtUmRuCV8coUv7cNZILonH+0hyrs/4F
	h2jEVAm8oxPcWz1+AB5phF2oXpFrB4+Av+FMI11CMJB8YOmaQ4kONfh/jMJxf2J3RMuBn1aZy//
	pS4nN+wcYGNjCYNZcsEs3QGX/8QOrxjIK93u59ZnAi0h8LkGb+SH3aTfmrMqrgYNmyg==
X-Received: by 2002:a17:906:1fc8:: with SMTP id e8mr27167068ejt.248.1550760385987;
        Thu, 21 Feb 2019 06:46:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYj3TxfgzyUWEyyzZWKU/uo2O6eL5sYh5to3b1wQBBMxQaDHRNuCNgqXC4ZS5FviKJizRgr
X-Received: by 2002:a17:906:1fc8:: with SMTP id e8mr27167025ejt.248.1550760385128;
        Thu, 21 Feb 2019 06:46:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550760385; cv=none;
        d=google.com; s=arc-20160816;
        b=CUZZrnEjiVfeJsc2RXbs8DFbh897kNGMa4JYd4X6VL+WERMFPuwZlJ9MqAlRi9v2Dr
         lHRX/pBkm9P6VSNtSLVmYJZMMFBO4eu/MPO59zJmHUBqRy2Mh0nmp03BjvlVDh9fq7Eg
         v2oTrEXuOQ7Ye7wTRuu53/iQNNa8HDddP7g3OOnC8Y0onxu+nqB9vQHbDXXJbRFsRFP9
         ImDf2m/aRlPHs6O6SCXCJfWHiqvP00G6AIO2FIGdOohuaxNDtzKFPWV/lMiDj1ZDSROM
         9f0cvTQYX3FcwEr6oIhV8rzoGlwNAe/ZX7/Qes7IZse4LmMi2Md89LKUxxKUPQFR63kF
         2/ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ccyA43whd4rLLZbIbLAZt5fc3XdqqqCa9r6nyyPA2Co=;
        b=ashwiEbfUsNvQFWURbIPkFdOyKvgMdJIjliHbIbtiZWi8m54p9cm+weF5AdQrhxTHR
         OvYJqumlA0sq5DoMQYjDgzrIsAEYhuPrtLDAQRQUqw6XdSbyeCCilFNEPKwExhaDcMdb
         sgxatwNLDP7NwCBfonuuoO1gYKr1iZpEFmD2zUQojY4++pdQvGMM+5EdQVGtUxi63KIB
         WwLdV6r5+/EGsK/sza1sCig+LGuw9lP+yT0ohR/am3fuKMS7CugqRM8FBAMSGqmCCou8
         Kyys5Abl+50QbSSwStSev7uff3bErGr3PXvTYzG6omfn6Ugq1CoBJHePJIKcRM7Q9o80
         s8JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o9si1952219ejg.177.2019.02.21.06.46.24
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 06:46:25 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A52F3A78;
	Thu, 21 Feb 2019 06:46:23 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 305673F690;
	Thu, 21 Feb 2019 06:46:20 -0800 (PST)
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
Date: Thu, 21 Feb 2019 14:46:18 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21/02/2019 14:28, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
>> From: James Morse <james.morse@arm.com>
>>
>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>> we may come across the exotic large mappings that come with large areas
>> of contiguous memory (such as the kernel's linear map).
>>
>> For architectures that don't provide p?d_large() macros, provided a
>> does nothing default.
> 
> Nak, sorry.
> 
> Power will get broken by the patch. It has pmd_large() inline function,
> that will be overwritten by the define from this patch.
> 
> I believe it requires more ground work on arch side in general.
> All architectures that has huge page support has to provide these helpers
> (and matching defines) before you can use it in a generic code.

Sorry about that, I had compile tested on power, but obviously not the
right config to actually see the breakage.

I'll do some grepping - hopefully this is just a case of exposing the
functions/defines that already exist for those architectures.

Note that in terms of the new page walking code, these new defines are
only used when walking a page table without a VMA (which isn't currently
done), so architectures which don't use p?d_large currently will work
fine with the generic versions. They only need to provide meaningful
definitions when switching to use the walk-without-a-VMA functionality.

Thanks for reporting the breakage.

Steve

