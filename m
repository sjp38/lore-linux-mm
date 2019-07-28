Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD29BC7618B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 13:40:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 453812166E
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 13:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 453812166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204768E0003; Sun, 28 Jul 2019 09:40:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18E568E0002; Sun, 28 Jul 2019 09:40:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 057A38E0003; Sun, 28 Jul 2019 09:40:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A92368E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 09:40:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so36787082ede.5
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 06:40:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SLmZ459eobj2ljNRx1DC0sbZRK/G/uP5oQJaaWujXNY=;
        b=U1x6HgMoJcDMI3FRQ0uXcSwZvMZQvAiOn9+OfRfy8A3bKFHxVx0ktTCaW5HSm/O+j2
         J51YSp/3vpyLeeoCeXIEX1yScVDo2ZdLDGvU0YvWH/1RVbpDUyK/bcsK2I2KU5asni3H
         aELDPL2m+FHbO1zEcrEkZOKTmyawqAsTSPYSSIP1m1e+WJQ25H8X2onXQBpZFyuQAgbb
         PrmVuSOXWPDcZ+l2n8u2MGIgdY4gnHZCz6NS1+/Qm6Yj5M4m9h64iOXUUAcAkH0xb+0f
         tp/uU0cg2ttbDXwJQ7iAb59lXI/5GLTLRz/gP3J792gUHnWbYzyEzbc2PRcGldADS2CC
         1lhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXZB1I1x6DUoMauDUwJ6FN5dI0K8vuCzcbbbjKoHJHPOk0Qwf/u
	rc0YhspdvmesA4I7YI/PngnstWJcqFoMri3wOwUZQ02w3ImD06hxfGhXRauFSZXCyatlJV21CS+
	blrYSHbsSKAnfQ+/zVV0DsxVk9I1xQlKhLf4e4rcWVO/D9uY6fg7EFeQys6HDp0Q9bA==
X-Received: by 2002:a17:906:5806:: with SMTP id m6mr17673336ejq.80.1564321228238;
        Sun, 28 Jul 2019 06:40:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk7xSUOaJzgde/LmftMTa8LpSonUzo9FEHcQFuzSFmWWpKBRyiSDDWz1jrA6Ndz1mbsszw
X-Received: by 2002:a17:906:5806:: with SMTP id m6mr17673295ejq.80.1564321227355;
        Sun, 28 Jul 2019 06:40:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564321227; cv=none;
        d=google.com; s=arc-20160816;
        b=ETBhJMFT+TLVNOmCS6/ZvuoMAeo+S3qNTMs6T34/BLDJG77uSowQnFT+XwbN3TB+XX
         OL428LwaQhUlwNek3R0UWHaKcrssywz0/BNOi+Q4dGifyrCgwppm6YNtf+6HKjG01+qd
         ozT3XTu5KQAgXKN0CKRlLKjOOz6a9Ndf1SXJfR//v2SlnP/PKVbrVFfVk7Vt3I6ecBQL
         Y/dvrTGsE7PgbLEMKZrHVAFC0nOwsJX0t5hVFWeQNh7ytXFr8nZYXGCX0lGGLajVJYnl
         FglGZ8hw4Rz9QfGo+St1YkGtpdA4s5rtgoTagU8Mjq78nBiC+ETpSJ1D1CEuu3qb6swi
         mtvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SLmZ459eobj2ljNRx1DC0sbZRK/G/uP5oQJaaWujXNY=;
        b=h8o27RGNIMycSM7zMnfu40FhwifyJNHu9hB5VQmFBjPXFAlpW+22TgNWGqkrgPcHth
         EHiPdVcfeD9VQV7Lvy/8WMbnhrN5ztUf03I9SIOBhUBskRaSTaHrFvl4ybXirK96TLzZ
         UMGM/+tylqa2I5VOIh0kr35aerGcTIuKfLH5ow2DJQqjg9EmXKwpU/ecGebf1hR9yc7M
         7AP2ANh0bmeMU06HM0Aqspdujmr7uIPWbH7RISPnqYgZ0knnpofHN0GPQY4uqYcRJ3Oq
         bTAcpLMyZUB1ZC/sMqgXXOhEIwSdXrXFxZwLDlrb7KCbHDzvj+q4sfOdTc2ntDO03sfb
         Ssgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y9si14809797edc.211.2019.07.28.06.40.26
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 06:40:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2389C344;
	Sun, 28 Jul 2019 06:40:26 -0700 (PDT)
Received: from [10.163.1.126] (unknown [10.163.1.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DD10B3F71A;
	Sun, 28 Jul 2019 06:40:19 -0700 (PDT)
Subject: Re: [PATCH v9 13/21] mm: pagewalk: Add test_p?d callbacks
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
 <20190722154210.42799-14-steven.price@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b74e545f-cbe0-9dd0-004c-5919e5cabb6f@arm.com>
Date: Sun, 28 Jul 2019 19:11:00 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-14-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/22/2019 09:12 PM, Steven Price wrote:
> It is useful to be able to skip parts of the page table tree even when
> walking without VMAs. Add test_p?d callbacks similar to test_walk but
> which are called just before a table at that level is walked. If the
> callback returns non-zero then the entire table is skipped.
> 
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/linux/mm.h | 11 +++++++++++
>  mm/pagewalk.c      | 24 ++++++++++++++++++++++++
>  2 files changed, 35 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b22799129128..325a1ca6f820 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1447,6 +1447,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>   *             value means "do page table walk over the current vma,"
>   *             and a negative one means "abort current page table walk
>   *             right now." 1 means "skip the current vma."
> + * @test_pmd:  similar to test_walk(), but called for every pmd.
> + * @test_pud:  similar to test_walk(), but called for every pud.
> + * @test_p4d:  similar to test_walk(), but called for every p4d.
> + *             Returning 0 means walk this part of the page tables,
> + *             returning 1 means to skip this range.
>   * @mm:        mm_struct representing the target process of page table walk
>   * @vma:       vma currently walked (NULL if walking outside vmas)
>   * @private:   private data for callbacks' usage
> @@ -1471,6 +1476,12 @@ struct mm_walk {
>  			     struct mm_walk *walk);
>  	int (*test_walk)(unsigned long addr, unsigned long next,
>  			struct mm_walk *walk);
> +	int (*test_pmd)(unsigned long addr, unsigned long next,
> +			pmd_t *pmd_start, struct mm_walk *walk);
> +	int (*test_pud)(unsigned long addr, unsigned long next,
> +			pud_t *pud_start, struct mm_walk *walk);
> +	int (*test_p4d)(unsigned long addr, unsigned long next,
> +			p4d_t *p4d_start, struct mm_walk *walk);
>  	struct mm_struct *mm;
>  	struct vm_area_struct *vma;
>  	void *private;
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 1cbef99e9258..6bea79b95be3 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -32,6 +32,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  	unsigned long next;
>  	int err = 0;
>  
> +	if (walk->test_pmd) {
> +		err = walk->test_pmd(addr, end, pmd_offset(pud, 0UL), walk);
> +		if (err < 0)
> +			return err;
> +		if (err > 0)
> +			return 0;
> +	}

Though this attempts to match semantics with test_walk() and be comprehensive
just wondering what are the real world situations when page walking need to be
aborted based on error condition at a given page table level.

