Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09121C433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 12:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3D102070B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 12:33:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3D102070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 717948E0003; Sun, 28 Jul 2019 08:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C7938E0002; Sun, 28 Jul 2019 08:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF1F8E0003; Sun, 28 Jul 2019 08:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC928E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 08:33:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so36727555edr.15
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 05:33:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LeXrXNCJtYsasE0umdNfMj++oRQjgf4EdP5D01wmdFE=;
        b=i9SC5R5Xsjb1uk1J0A8auBrSkfMq14rFyvYVtCqCf9E9FPICnds8iKsPCAcKHBsjCH
         uEAlKBLAa8wAVWxDMZ251EtJutT9dCoLLX1MJZWtfN46/IK6d+P4ulLDaUT9uh2GXXYX
         U/EzUUwnlFNnV5MZw73YLGOYwWTTwGiGd9Axvra+GUcNASBP5h2K28sRTwuYM0fnnXn6
         6b57tTUsakUIGits0UkODSCTONRnttfPl5DOSUxj11/VN05v4vqxU84DiCS0995S5JOZ
         Nnud6vDIG/jzguu+CQyPlVEshP3KZ4oXcInSJKugjAXEdfkpckS1q2sbXFQIikWh80Qy
         Hyjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUwLqE9tsvvd7St16R5/8l+18ywb+x8ifCm3U2snMKwrR32Onp6
	00Do7LtlcSahsz3E2HRTLecWpcfbUXlcvr1pjEHru3JWkdD/Gurl0IBRg9mERPFmVL4jyeQW5kT
	/vc/5TXcF7KI6L377SRZmpYVXj5+Kg3khrxDJ9gq65+EjV2KDKGgavzaOSOGWPQyt6g==
X-Received: by 2002:a17:906:f0cd:: with SMTP id dk13mr80762921ejb.84.1564317184614;
        Sun, 28 Jul 2019 05:33:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDPxiHMI+7zBu51fjSSmYNgXXYQnCsoVzoURv+oX8TmU089P+LiUIDCjmiK3BE4h6GHsHP
X-Received: by 2002:a17:906:f0cd:: with SMTP id dk13mr80762882ejb.84.1564317183776;
        Sun, 28 Jul 2019 05:33:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564317183; cv=none;
        d=google.com; s=arc-20160816;
        b=ZDlanzaUZX1oefnZsOqUcsVTVGhYxE0/UZ1PSgGS9fE0paND+21LB3uhO35fxn8Zmz
         kZ+1WfG0Wca6AT//5o4S1OZYSO5vusCsuVnu0lSNK5FqB6RahKg0mqe+N1DTA26ZI/CF
         uc7ljtM7ig0FNaFAxb5eU2YEy5BEUHKxqGZckBpO9V2nG57RjAdO0szTh5i243Z0CEVQ
         aqIGNuFh98jd/MvB9/1sSxu/F0aKe8Oj6Z4M1I+A4nRPo0eVx68cC3ulDazXNMpT7u/O
         0C2F+gbMg452kFQbEPjyu7mR9XTMFMtfmMySi9YabaLbFKwqFzyRiJhfaN2xb0dogDpC
         wx4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LeXrXNCJtYsasE0umdNfMj++oRQjgf4EdP5D01wmdFE=;
        b=tMTqjufU+9TDoRxGJJmqi0Gtg60sXFnJitXut4a1+Q15+ywA45ZMH8MfBUFxDs0rF7
         PTpnHEQ2vwZKgmksY7/LpFSjGTTlXTS1L3oKs5Gqjc0EjxzP/CjIIVZkUB+P5WF1jANb
         PdoPztGM/s05XiE9+YfbivsSLMt05T95G/qBn2wEyWh81xrBH5zbFIo10Fnu4M35fktW
         1TC48j+0nU7yftRNTFnx8tnflPxmFZpBmH6K//gpMMXtwSFCzeC4OhGi7ReDXr6nj7T/
         wJWcFkizI9Y0tmENPPgHuBIgFWVuXcnDPC5JDPrvAaW7EarM2J9h5u/0L8WJsiZM3ciK
         PcTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p43si15075457edc.201.2019.07.28.05.33.03
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 05:33:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7D541337;
	Sun, 28 Jul 2019 05:33:02 -0700 (PDT)
Received: from [10.163.1.126] (unknown [10.163.1.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B3BF13F71A;
	Sun, 28 Jul 2019 05:32:56 -0700 (PDT)
Subject: Re: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
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
 <20190722154210.42799-12-steven.price@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b61435a3-0da0-de57-0993-b1fffeca3ca9@arm.com>
Date: Sun, 28 Jul 2019 18:03:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-12-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/22/2019 09:12 PM, Steven Price wrote:
> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
> no users. We're about to add users so reintroduce them, along with
> p4d_entry() as we now have 5 levels of tables.
> 
> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
> PUD-sized transparent hugepages") already re-added pud_entry() but with
> different semantics to the other callbacks. Since there have never
> been upstream users of this, revert the semantics back to match the
> other callbacks. This means pud_entry() is called for all entries, not
> just transparent huge pages.
> 
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/linux/mm.h | 15 +++++++++------
>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
>  2 files changed, 25 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..b22799129128 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1432,15 +1432,14 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>  
>  /**
>   * mm_walk - callbacks for walk_page_range
> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> - *	       this handler should only handle pud_trans_huge() puds.
> - *	       the pmd_entry or pte_entry callbacks will be used for
> - *	       regular PUDs.
> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> + * @p4d_entry: if set, called for each non-empty P4D entry
> + * @pud_entry: if set, called for each non-empty PUD entry
> + * @pmd_entry: if set, called for each non-empty PMD entry
>   *	       this handler is required to be able to handle
>   *	       pmd_trans_huge() pmds.  They may simply choose to
>   *	       split_huge_page() instead of handling it explicitly.
> - * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> + * @pte_entry: if set, called for each non-empty PTE (lowest-level) entry
>   * @pte_hole: if set, called for each hole at all levels
>   * @hugetlb_entry: if set, called for each hugetlb entry
>   * @test_walk: caller specific callback function to determine whether
> @@ -1455,6 +1454,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>   * (see the comment on walk_page_range() for more details)
>   */
>  struct mm_walk {
> +	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
>  	int (*pud_entry)(pud_t *pud, unsigned long addr,
>  			 unsigned long next, struct mm_walk *walk);
>  	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index c3084ff2569d..98373a9f88b8 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  		}
>  
>  		if (walk->pud_entry) {
> -			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
> -
> -			if (ptl) {
> -				err = walk->pud_entry(pud, addr, next, walk);
> -				spin_unlock(ptl);
> -				if (err)
> -					break;
> -				continue;
> -			}
> +			err = walk->pud_entry(pud, addr, next, walk);
> +			if (err)
> +				break;

But will not this still encounter possible THP entries when walking user
page tables (valid walk->vma) in which case still needs to get a lock.
OR will the callback take care of it ?

