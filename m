Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EFF0C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C4A223BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:14:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C4A223BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 910386B0003; Tue, 23 Jul 2019 06:14:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C0468E0003; Tue, 23 Jul 2019 06:14:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 760D98E0002; Tue, 23 Jul 2019 06:14:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 252F26B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:14:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so27963700edc.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:14:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bFZUW7at3XchBM++8EzElWKOf8040gvpN3+BLd1l9UA=;
        b=T/CRGUnCwUcQlNfKxksukTxxavkzqcU+vAKyfbL6HzkhnAuojddhF4lEjBO/+tDTQA
         +HxNGQjWJ28b6UYyoqDS+B1jmNb6Q032c6T9bGSECOSSkgCrcatHT4HJA0hcgvHaiqLA
         QcdmlBLk2UNVmK6w2dg8vrtwSJLfG5obj/8aULsvs61PIYckITEoNjdulNLd5H+iuX3j
         Q/QOzXy3Mr2xL8ZlokjfK4WHAcOxP5gbEpoRDyd+/lGx80x5OAxdiPpugjLO2jpbGTpW
         qPSAeyWaLhklgMJlN9y3X0YNBekMI5wVeuURzYaRgKhlJMkDW6Vmyz6aAgl2XHLNLXe6
         f7Ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAV5euw6n4refcCo5bgXkLculWsp0GwYtv7zOFxZlAW8vns0EObK
	qDe9/D2rih9j+O9Icj+7DnD+dZnHgIch+YPAkDx8pF8sGYanFsLUAS/PGfYU16D7zUcZcTGMHuP
	HrjT5n5IyG/5on5q8+OAKkLF8KiL5g2EawPIPNdj3jTOLQrvCuqN/4xNWvg9yqD8caw==
X-Received: by 2002:a17:906:a3cb:: with SMTP id ca11mr58425974ejb.79.1563876879706;
        Tue, 23 Jul 2019 03:14:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzucSWJMcY5ZQDIqVoskmMzpNtx0pwwlHAPkc1ADR5+GCedvh3tUJhoEScoZ6r4zrdXpq22
X-Received: by 2002:a17:906:a3cb:: with SMTP id ca11mr58425888ejb.79.1563876878595;
        Tue, 23 Jul 2019 03:14:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563876878; cv=none;
        d=google.com; s=arc-20160816;
        b=AADi5LK60dfe7wGWjacJCw6RNNpR5mB5g4xnsAe+cjZ3EANE0By+E0ko8h7cHKrQqJ
         yVQPTdQKf6Ni3ilGboel8E8+PybfJj4VGoBIwGGROk/zeTXS7GKTWJAUb2fmMs8cfrE9
         825Itwn67KocIMCX8ec0vTTKG7J9eDT3u84FcYCdAIJhTk3Sul4043Pi+dQfOznaXqHq
         mysyAH0QJ7WWfPyLCkUnV0MLmHSGCPMT9L6w+eMngWPVx4US7cfVSotAx9wzz60yrc+W
         tmjhQ0VdxWzGxBRaWJqi6RFk46qiLk7lDtWlpOYLvwQ+f2caH3bUFKJr74wWrTRkAOmb
         FVhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bFZUW7at3XchBM++8EzElWKOf8040gvpN3+BLd1l9UA=;
        b=zJJKxMCFPTa2TcXKY3065xL5XXZnceHX6gw8llfcYX4Hbe8sQuhY+3dLOAeDbSN1bi
         b0OivXdKdL9JQHGhy+S9ZUCCVuhopSs/cmLOdNHvEtMmXU+4gaT4h2TykO3FUE1A3z7C
         BqrzqDojN9xccQvvPOmwBXzRYm+8jZvgBNI22aHvqfD3xOz5yPniN1kzd+Q+psyF87xb
         IDzblJp0ZAF6qJ+aJd9O4SQeuJdq88b4JkpF2wJqjnMJma6mrvAb1yAnHxpHErtELVzO
         2txuo8wUUonynnk8ese6jF694DmFS5G08+OetG5C92IXvJecsNXkWUvNELVtAcsRK/Rb
         0wgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i12si6477728edq.333.2019.07.23.03.14.38
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 03:14:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9A171337;
	Tue, 23 Jul 2019 03:14:37 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 29D043F71A;
	Tue, 23 Jul 2019 03:14:35 -0700 (PDT)
Date: Tue, 23 Jul 2019 11:14:33 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
Message-ID: <20190723101432.GC8085@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-12-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722154210.42799-12-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:42:00PM +0100, Steven Price wrote:
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

How are these expected to work with folding?

For example, on arm64 with 64K pages and 42-bit VA, you can have 2-level
tables where the PGD is P4D, PUD, and PMD. IIUC we'd invoke the
callbacks for each of those levels where we found an entry in the pgd.

Either the callee handle that, or we should inhibit the callbacks when
levels are folded, and I think that needs to be explcitly stated either
way.

IIRC on x86 the p4d folding is dynamic depending on whether the HW
supports 5-level page tables. Maybe that implies the callee has to
handle that.

Thanks,
Mark.


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
>  		}
>  
>  		split_huge_pud(walk->vma, pud, addr);
> @@ -131,7 +125,12 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (walk->p4d_entry) {
> +			err = walk->p4d_entry(p4d, addr, next, walk);
> +			if (err)
> +				break;
> +		}
> +		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry)
>  			err = walk_pud_range(p4d, addr, next, walk);
>  		if (err)
>  			break;
> @@ -157,7 +156,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (walk->pgd_entry) {
> +			err = walk->pgd_entry(pgd, addr, next, walk);
> +			if (err)
> +				break;
> +		}
> +		if (walk->p4d_entry || walk->pud_entry || walk->pmd_entry ||
> +				walk->pte_entry)
>  			err = walk_p4d_range(pgd, addr, next, walk);
>  		if (err)
>  			break;
> -- 
> 2.20.1
> 

