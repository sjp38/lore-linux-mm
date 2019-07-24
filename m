Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3793FC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2F3621911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:36:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2F3621911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42F656B0008; Wed, 24 Jul 2019 12:36:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B8E38E0005; Wed, 24 Jul 2019 12:36:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A7D18E0002; Wed, 24 Jul 2019 12:36:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF0EF6B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:36:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so30548624eda.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:36:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gIx+ceJLLqzYzF7GtNXtIq07rvlh51FQYTqoEO8IsJ0=;
        b=KKqJEXfJBHxXoCcGam3CkAD4DZ86uDHNR5gNj/WM32GjiMd6hHAZE+H367deoDZZiz
         yqXly5s87Eg/mnYkoMzvwNBRQFZn+zAnUQyjL4GneL9z+4nn9r24E4m90o65qpi45vgR
         8YRyxL4xFFd2vudyGrk08jx9BvhesEyZcuSwOnwaRFj8GWZzwzZT+m3FjCuWjrPFTKQH
         eR4u9IHIz8WeAOZ5gJFB+RhJy5YdkDcwwqz5k087JtiwMnE7vJe6chghg+ZmlI1q+P4m
         EUV4MGDk1yA+b9v4vQG0jahvSZKoBTHdKxjUDPZqXrpHEzvs86hwc6l8aG5d6is/WNyq
         ZvhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWmZKory5xkckQ62tVA45ueUC5MiEgXhKbJ9vQMvIim4cIzGkd5
	GA7KYwQ8A0J/T5/Uzjs6VL4UpelMn0AY/NYYslUGuUz8y/CvDdzXwS03oue/wbVx2pK8Si02onk
	oTMU8PdJtk5TK75Dqy4rAy1hDC8OFz/Z65uv+FYYUhGrEiQHEhcucW75QPGe8U6zbOg==
X-Received: by 2002:a50:e703:: with SMTP id a3mr73320688edn.291.1563986211304;
        Wed, 24 Jul 2019 09:36:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTOUPBx5UKjWA7Hiyt8fPCYfn/UD+o3mT37xXEuiNriS/E6FSyK+2idQ38ALd2tbhDjrvf
X-Received: by 2002:a50:e703:: with SMTP id a3mr73320624edn.291.1563986210485;
        Wed, 24 Jul 2019 09:36:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563986210; cv=none;
        d=google.com; s=arc-20160816;
        b=Y5VLEY4ZEVw7JIr5YcjAsMiQCIUCMuVpPUmD8VohQM70j3UO6ftZr82wGOHw05gsWp
         Ay1iT+H7tL9oQmLXlOrwkcJcw/fAvet+ES1vunmnTXctKxqQwCiLpsZEZQU5JzwVr8VN
         2NMA0m7bOVNR0Wm/DkLjuwwPuuukmqPJs8Po5SODbQ8DcwDkLCdHrvysc+2MGi0Eb5D9
         ovkgxO8NHz/VNul7ElfNVF8EkgG3BkgvubCg/cNrrMmq+xV8xkGSepoQrLV2jOn3B2WE
         4sYFr4KIrWUwyBCBNg0FxgOzGxdsTx7rx3oNl6pWloEtTRTlHnFHGqn0rSomv7vxpJfA
         d7zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gIx+ceJLLqzYzF7GtNXtIq07rvlh51FQYTqoEO8IsJ0=;
        b=iVV8ybknwBM2ckSk5t3nB2Hxfks6fgVX5KrCzTyCRiGYkLOMtmsjtu490WIGPQx5Dd
         42Bi6AiyUfegExCdH8R0ey3l3K3SjHE1Hio1aH21mB+yo+0Wqle9dJ3GK0VldpmUJwar
         gcojTFxXLZW7TVDxt9vDNJ/NM3ChMZ3vBdeUxRbZz4LchPEoODQ9qacyhtA9x87FfC4N
         9Amm7axzjlzQqbI7qGbWoYtoHux6cFXklEC9VXwYR5uGo//ddCkzURnyow645j1IN7Jr
         4CGNJ2k6Hl1Drv7fIq17R4JLYUqenRE0o+IIT1b6xyJY76HVIRcqTT0SjnC4w0ouqJvs
         YFUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g27si8800045ejc.229.2019.07.24.09.36.49
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 09:36:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3690E28;
	Wed, 24 Jul 2019 09:36:49 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C337C3F71F;
	Wed, 24 Jul 2019 09:36:46 -0700 (PDT)
Subject: Re: [PATCH v9 19/21] mm: Add generic ptdump
To: Mark Rutland <mark.rutland@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-20-steven.price@arm.com>
 <20190723095747.GB8085@lakrids.cambridge.arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <ee707646-0196-63bb-45cc-6b949ae9530e@arm.com>
Date: Wed, 24 Jul 2019 17:36:45 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723095747.GB8085@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/07/2019 10:57, Mark Rutland wrote:
> On Mon, Jul 22, 2019 at 04:42:08PM +0100, Steven Price wrote:
>> Add a generic version of page table dumping that architectures can
>> opt-in to
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
> 
> [...]
> 
>> +#ifdef CONFIG_KASAN
>> +/*
>> + * This is an optimization for KASAN=y case. Since all kasan page tables
>> + * eventually point to the kasan_early_shadow_page we could call note_page()
>> + * right away without walking through lower level page tables. This saves
>> + * us dozens of seconds (minutes for 5-level config) while checking for
>> + * W+X mapping or reading kernel_page_tables debugfs file.
>> + */
>> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
>> +				    unsigned long addr)
>> +{
>> +	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
>> +#ifdef CONFIG_X86
>> +	    (pgtable_l5_enabled() &&
>> +			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
>> +#endif
>> +	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
>> +		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
>> +		return true;
>> +	}
>> +	return false;
> 
> Having you tried this with CONFIG_DEBUG_VIRTUAL?
> 
> The kasan_early_shadow_pmd is a kernel object rather than a linear map
> object, so you should use __pa_symbol for that.

Thanks for pointing that out - it is indeed broken on arm64. This was
moved from x86 where CONFIG_DEBUG_VIRTUAL doesn't seem to pick this up.
There is actually a problem here that 'pt' might not be in the linear
map (so __pa(pt) barfs on arm64 as well as kasan_early_shadow_p?d).

It looks like having the comparisons of the form "pt ==
lm_alias(kasan_early_shadow_p?d)" is probably best.

> It's a bit horrid to have to test multiple levels in one function; can't
> we check the relevant level inline in each of the test_p?d funcs?
> 
> They're optional anyway, so they only need to be defined for
> CONFIG_KASAN.

Good point - removing the test_p?d callbacks when !CONFIG_KASAN
simplifies the code.

Thanks,

Steve

