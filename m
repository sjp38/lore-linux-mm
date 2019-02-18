Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 996D9C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6286F20838
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:12:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6286F20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F2E98E0004; Mon, 18 Feb 2019 10:12:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07C3C8E0002; Mon, 18 Feb 2019 10:12:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E85FD8E0004; Mon, 18 Feb 2019 10:12:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF408E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:12:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d8so7233729edi.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:12:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CxoAILgZ+0+CEjK9v6tbi4kdO9wm3ie7EjOelVfViGA=;
        b=QeMTnEaW/y0JpQTVtTp+4hjFT8HE7Y4icLDt4Lc3Hg4nJgzHew4f5Ww1Ra5c0T3yhk
         FNxOe9BWUdQ9FZSb/a19uiYXXOH4EezESTQ32IJ+3LQPglipvM3rzqdMTyfaNDLCeTOp
         oCd4k2nho0ZtvZoP5EqAeMTOdCVOKyyJ1IKCe1QHeeyZ1c1KhxP+HR1gIrInKoVRqd3i
         MMpeTWipFQfhUBAaV+jDJlG9Hp0d4GYjadptZce5OyVj6ofpsVBWXojI6diY9kskd+nv
         vK2kUFIBlKR9G6AKerNm5JR73oOLfB5webhQHKWeGE5AcSoc1Z/9S9vF9n6fK3+qM69Y
         4Pqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAubXQrQHm8l5lZRVW7Q7v4vvYPXE1eLUr+FMjfoAnJrcl8x5THWl
	JUr5ExBOqpt/TBjsqKuyhEwcSUc5rfFcmJZr/P533WU9uvAOjJiDDdBro1r44qPGTgTAhJbx72G
	6ByrpFp2Hd1Flg9tPm3ydc7AyU/wqhQClXKccnX1SCaLT3bCHTCQxl0uR0TCfPTUsmw==
X-Received: by 2002:a50:a5f6:: with SMTP id b51mr11108767edc.9.1550502756126;
        Mon, 18 Feb 2019 07:12:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFgLAMQalxtpgexJUCqZ8/8ZSyS3Pbnuk2LOObzkwTz1q2Q4qkFUOZ7Vk0UmByIlJ1jGF1
X-Received: by 2002:a50:a5f6:: with SMTP id b51mr11108697edc.9.1550502755202;
        Mon, 18 Feb 2019 07:12:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550502755; cv=none;
        d=google.com; s=arc-20160816;
        b=CRFOiUSmfcS80mjk21UiuZYsA2Pzre2aZn80IEQ2thrdisWVQdq6xPgrBp48EjV2Au
         Lx5HihvS9f3HdUghhFQPr06BnLNZALxPR5Pcf6EZwGE5uGSV3NhsB0VYHfy63t3q+sIQ
         Yh3RAMhRefPGwDzCZXpNrNu2IdTpCvqGOUmU0bUYtWnwNMN3ySXxIuI1+3odvGILggTC
         1XQ6RR8D9JNfahgSEgo6IJWe+2jjFbioL9gDPttpdv9yUo9MWqk5d5o59jFb5I98xgS7
         /TnQQQGX/ABwUBKQK1NpN9cZ2Q73TxCnliejb9+LBBCOJ79EfUIG3pev/ksO5vUFGEzw
         n+Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CxoAILgZ+0+CEjK9v6tbi4kdO9wm3ie7EjOelVfViGA=;
        b=I3dHVx/2Kj3Wp8SUFLk8I1yk9wBoELHEHm8hxqs4nUISX9DzjA49l3sb+KIvb7zsXF
         /z39OfyIl70pWqfupqmQPooTTTrNYjGgOxQHmlbRibwv0UNeLEwCJjXsa3YcVojnX6BT
         2QTCell6oSl+IaKRgI5e0a6VdxQqqwje7ARnQErWGB51Cv2lJRYeF2zzxYJB+z01sAVL
         /9tbqBc5r/tvFzHxad8z/Vq2ggyBrKLGjRlG6s1Y+0YkggE4vzsuuemYAVXup3trYGXe
         fOXG3aM/5Spp2j2KSlBFIXtlNX1SWYGpj7G2IWPOm7pJ80UsB36rkcuAvZKFfiU/rpOh
         l5eQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y54si1030284edc.436.2019.02.18.07.12.34
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 07:12:35 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 81ADA15AB;
	Mon, 18 Feb 2019 07:12:33 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 824503F675;
	Mon, 18 Feb 2019 07:12:25 -0800 (PST)
Date: Mon, 18 Feb 2019 15:12:23 +0000
From: Will Deacon <will.deacon@arm.com>
To: Yu Zhao <yuzhao@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: Re: [PATCH] arm64: mm: enable per pmd page table lock
Message-ID: <20190218151223.GB16091@fuggles.cambridge.arm.com>
References: <20190214211642.2200-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214211642.2200-1-yuzhao@google.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[+Mark]

On Thu, Feb 14, 2019 at 02:16:42PM -0700, Yu Zhao wrote:
> Switch from per mm_struct to per pmd page table lock by enabling
> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> large system.
> 
> I'm not sure if there is contention on mm->page_table_lock. Given
> the option comes at no cost (apart from initializing more spin
> locks), why not enable it now.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  arch/arm64/Kconfig               |  3 +++
>  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
>  arch/arm64/include/asm/tlb.h     |  5 ++++-
>  3 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a4168d366127..104325a1ffc3 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
>  config ARCH_HAS_CACHE_LINE_SIZE
>  	def_bool y
>  
> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> +	def_bool y
> +
>  config SECCOMP
>  	bool "Enable seccomp to safely compute untrusted bytecode"
>  	---help---
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index 52fa47c73bf0..dabba4b2c61f 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -33,12 +33,22 @@
>  
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
> +	struct page *page;
> +
> +	page = alloc_page(PGALLOC_GFP);
> +	if (!page)
> +		return NULL;
> +	if (!pgtable_pmd_page_ctor(page)) {
> +		__free_page(page);
> +		return NULL;
> +	}
> +	return page_address(page);

I'm a bit worried as to how this interacts with the page-table code in
arch/arm64/mm/mmu.c when pgd_pgtable_alloc is used as the allocator. It
looks like that currently always calls pgtable_page_ctor(), regardless of
level. Do we now need a separate allocator function for the PMD level?

Will

