Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACAD2C7618B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 14:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E70E214C6
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 14:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E70E214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44BD8E0003; Sun, 28 Jul 2019 10:19:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF5248E0002; Sun, 28 Jul 2019 10:19:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC5C8E0003; Sun, 28 Jul 2019 10:19:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC0A8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 10:19:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so36794765edt.4
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 07:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=acm2cGhk0jV4Lf07BQLRvnqMory4r6GfSM+DFcLMrIw=;
        b=h1/cv/aatFuT8Jb3GsVKirQ8cuxHQVdcvx/hLS4PDdiTNpSbLy9FH3H8MyXkiFYa/Y
         ozjXmh66Q4jw3mwjd4+wQonCxjOzGj0i4fg6gb5PK5yyUplEn5soZIQXc3eIiQDQCjJq
         lOLqovvNT5Y2NeFOMtqZsuz8ikpfvY7ikO8JIedlxCtUuHGiWE6yotgbhwd8b/D31MXy
         d9ncZDFY3KYboToN0rwQI3aPJvnw/O0Qj+mRc4hBqC26tnGclFjsPP8ErKHbXuO/WJPy
         JCKfXkOcNKc9D3ss0IzVB4PUdZPz3imjN7CDLUlBnkZ28HLQgeSnSsHAoUbJ80yyGJco
         OgGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW87IIiz/z2TpoWLKzjIQgoA7gCRh9HX57Kr9cc6LI3S7X/EKR2
	bcAri7RnJ9e6Bn9hVGjP12YPnxbL8I+BRTFdlnqmb3YqBAu10VIxiNhmEPtdEqCTSdxKIeQEWAy
	tgaxVh7YyzresRwOOyD/qBsbeUqFs1aeA50+ii4/x21h073H+/NXuMr/CGuARtuljTQ==
X-Received: by 2002:a50:996e:: with SMTP id l43mr92945160edb.187.1564323572101;
        Sun, 28 Jul 2019 07:19:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFunsdpg2BJVCln4Bpjj+sX+DDwA+qtgUrm6ZGklfLPnMlD0L9gRBpKweTQ8bh8zfHcOYc
X-Received: by 2002:a50:996e:: with SMTP id l43mr92945101edb.187.1564323571332;
        Sun, 28 Jul 2019 07:19:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564323571; cv=none;
        d=google.com; s=arc-20160816;
        b=lR8pgI1FEYGxsUg+YjN68Tg+a8Deke2Ibx/BXg0n7GdtgZsnPrPyigQI4t74las92a
         ZvZmgF9gT/euuqsi88soKcrlr9ceab13v77VMhUxUWP5E3oGfqMwuhsmsOh6iC5Z+W3o
         XCJfIza6RT6qSKdNHakOtvIWLjkr43/U6NWuv+Q/n/s5nyD9nerV5G2AKPwSwvBp2kMC
         Yftam+BEG/YnCCQsUsGdxvdYC3rd5ERUeM8L0Kc4j6cUoug88DvyIfhcovW0FZDfL5wN
         VsJERh/E0ihg39Zv42OaD618Xv+xtTpcvBnzds73wQP43Km05wVqzg4VdxZf7BlLxZEN
         hgQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=acm2cGhk0jV4Lf07BQLRvnqMory4r6GfSM+DFcLMrIw=;
        b=wqWssOXUXAehdseVT3NqsZG2vds/MN0QwaiRuSQAqVncU3/A1k16k/MzQvbIjiT4o2
         xBvUleY81i9njVSMhxmXZp9DW9qZOPEqFNuyvEtWUkQ6dwUY4U0nyuS53d4q1EOtX4jb
         MAqHDBAqnFelaOWlHYUMLqKAcNK9gHLkp0VDhRNeP/Vccr/CW15CX/GR1uiJIKLjQdTD
         Sv5nKzT5JzelSCxTnQ7rIbkBZuAiF2iqLJK0f7AEaLmjTzdf2oDXl+ul9gi3F1F83t3V
         vA47IHNwtmhpDrJtiITN8hkDqRA2PkNynKfBKpzewPgjKPqJWtNffb0CWoxZrB1VWwri
         zYSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 11si13501527ejy.102.2019.07.28.07.19.29
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 07:19:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3517E344;
	Sun, 28 Jul 2019 07:19:29 -0700 (PDT)
Received: from [10.163.1.126] (unknown [10.163.1.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 698B53F575;
	Sun, 28 Jul 2019 07:19:22 -0700 (PDT)
Subject: Re: [PATCH v9 12/21] mm: pagewalk: Allow walking without vma
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan"
 <kan.liang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-13-steven.price@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7fc50563-7d5d-7270-5a6a-63769e9c335a@arm.com>
Date: Sun, 28 Jul 2019 19:50:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-13-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/22/2019 09:12 PM, Steven Price wrote:
> Since 48684a65b4e3: "mm: pagewalk: fix misbehavior of walk_page_range
> for vma(VM_PFNMAP)", page_table_walk() will report any kernel area as
> a hole, because it lacks a vma.
> 
> This means each arch has re-implemented page table walking when needed,
> for example in the per-arch ptdump walker.
> 
> Remove the requirement to have a vma except when trying to split huge
> pages.
> 
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  mm/pagewalk.c | 25 +++++++++++++++++--------
>  1 file changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 98373a9f88b8..1cbef99e9258 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -36,7 +36,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  	do {
>  again:
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(*pmd) || !walk->vma) {
> +		if (pmd_none(*pmd)) {
>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
>  			if (err)
> @@ -59,9 +59,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  		if (!walk->pte_entry)
>  			continue;
>  
> -		split_huge_pmd(walk->vma, pmd, addr);
> -		if (pmd_trans_unstable(pmd))
> -			goto again;
> +		if (walk->vma) {
> +			split_huge_pmd(walk->vma, pmd, addr);

Check for a PMD THP entry before attempting to split it ?

> +			if (pmd_trans_unstable(pmd))
> +				goto again;
> +		} else if (pmd_leaf(*pmd)) {
> +			continue;
> +		}
> +
>  		err = walk_pte_range(pmd, addr, next, walk);
>  		if (err)
>  			break;
> @@ -81,7 +86,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  	do {
>   again:
>  		next = pud_addr_end(addr, end);
> -		if (pud_none(*pud) || !walk->vma) {
> +		if (pud_none(*pud)) {
>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
>  			if (err)
> @@ -95,9 +100,13 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  				break;
>  		}
>  
> -		split_huge_pud(walk->vma, pud, addr);
> -		if (pud_none(*pud))
> -			goto again;
> +		if (walk->vma) {
> +			split_huge_pud(walk->vma, pud, addr);

Check for a PUD THP entry before attempting to split it ?

> +			if (pud_none(*pud))
> +				goto again;
> +		} else if (pud_leaf(*pud)) {
> +			continue;
> +		}

This is bit cryptic. walk->vma check should be inside a helper is_user_page_table()
or similar to make things clear. p4d_leaf() check missing in walk_p4d_range() for
kernel page table walk ? Wondering if p?d_leaf() test should be moved earlier while
calling p?d_entry() for kernel page table walk.

