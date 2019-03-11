Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4B91C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:28:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF7C2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:28:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF7C2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F698E0009; Mon, 11 Mar 2019 04:28:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EEF98E0002; Mon, 11 Mar 2019 04:28:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FA38E0009; Mon, 11 Mar 2019 04:28:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50F968E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:28:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e46so1714675ede.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 01:28:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IWK6oJPSwHbmnVMnpVtZyyq+fzYGSg+hhlsdV2Fjuyk=;
        b=gh4tG+3PDNhg2MRtjKrsj9ti3Lp8cTlHYndCmFX0bQeDiVKtKs1tD4kyHFMzJoBKRc
         /cnbtaHgPdK7D/TZFkKlo1svAHS2MnicqPXdE8oHRDftXyevfPSmPX5VO2ZdT1jkNQnR
         nOkMNkWTe5SeQUzGfnDdq9umw8xrWtO2d7tIajuNBoY4v1L6xPfyh/B4g5+n1hHWU9sb
         yIzwtRx7JHqqJpni0mIwn4b4jkCIsGHcRBlr73NrD5NlSpRWfEb2FiAxEIzf30lcS6Bk
         amyWUkTNbXaeMbcyC+mF0bY7VJ2cVohprZ6uLpbTru274YQ0W2PT2bo8yoNWnzed/pSj
         w5jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX7U93fW6oIlLwzsoCd7xmdGuVo/FAG+h6CZVbnpVHWGS2gBUxt
	/b5y2QynXHT8BJGNxg8MvVR9JrvjoiPhR2yXDsnzQkLfcRkNY8AlDvVl9IG1pZvCKRliB0VRYPr
	jeI5/WSah0iq8m7ImzWRjyqpYfSeJZMwKczgQ+HWSuvNnJKgP7zzJlfPaihsE1ynZbQ==
X-Received: by 2002:a50:a7e5:: with SMTP id i92mr44322953edc.181.1552292921846;
        Mon, 11 Mar 2019 01:28:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZoQ7aKURvDeJBjjTjcfqkpHDA32z+q8Bqt1AdibAbRYUZj0R3fG7geeZpS4g50HPalEvn
X-Received: by 2002:a50:a7e5:: with SMTP id i92mr44322904edc.181.1552292920917;
        Mon, 11 Mar 2019 01:28:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552292920; cv=none;
        d=google.com; s=arc-20160816;
        b=yuixe4wVsnAPfWXJioO76yLNhwUvF2nadCOJCirp/mFY5TrmY+C/5XSVab2BzzgZTd
         bdM4JSCj9txD1Pux1IOtEdWcknR3CgJar/JAZ+KlQKqquw9qJgZiyvBUb1lLSKDxviAj
         RfMoBtPex2hGEoQv9eTS50X1FNFfSYNFrxCtURpwQKWcDfzAyWwGYKg49GngZh9TxYFe
         lATvHZuUCEUMnUhGvcQYSLWBIbFVbAQp2OCKAxrC1YY+82e8NnrJPI4jhoewmggoHJjk
         HWll59DeP02fIz3wUBpDDUUwtlhxd1K9Ib0reVcR0tTxTMt2udMncQXKls38BqNBzYq4
         dmDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IWK6oJPSwHbmnVMnpVtZyyq+fzYGSg+hhlsdV2Fjuyk=;
        b=oo9cmL5EA94A0riR3ZVGah1SQU0zxMIfCVsIGSpGXrvhfb9jt2iQnZh4CsIpbJGAgZ
         X9BXIi8AZt7jn1W5NG/or7ZURQVZ/d8lOh3IEMSD5+reio/w7ckm0MtiHRlQ7vzJzpqz
         7gSDPB5Je8RTmnzOZLTOSjudk9W0q7QokMRViVJlbrS7QT+b67k8+KB//4Bh8P7QnqHG
         ALTM1ubhQhhvKoYPPKZYQ8zyJMdDLP9niL71V5X8+vthrjkApuDaoOVQgn7GMdfbqsAn
         L8x6w8Dq7wE9rBqrv6CP5zl3WG5PqDQpMd8Zebuhg+AI6QOca1A/9cOs2gnyCEOXUDzE
         nIbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m26si200120ejr.19.2019.03.11.01.28.40
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 01:28:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9D338A78;
	Mon, 11 Mar 2019 01:28:39 -0700 (PDT)
Received: from [10.163.1.86] (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C16FD3F59C;
	Mon, 11 Mar 2019 01:28:30 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] arm64: mm: enable per pmd page table lock
To: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <20190310011906.254635-3-yuzhao@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <dfc727b4-0806-4867-2f9c-0bb8fdd459ad@arm.com>
Date: Mon, 11 Mar 2019 13:58:27 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190310011906.254635-3-yuzhao@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/10/2019 06:49 AM, Yu Zhao wrote:
> Switch from per mm_struct to per pmd page table lock by enabling
> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> large system.
> 
> I'm not sure if there is contention on mm->page_table_lock. Given
> the option comes at no cost (apart from initializing more spin
> locks), why not enable it now.
> 
> We only do so when pmd is not folded, so we don't mistakenly call
> pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc(). (We
> check shift against PMD_SHIFT, which is same as PUD_SHIFT when pmd
> is folded).
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  arch/arm64/Kconfig               |  3 +++
>  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
>  arch/arm64/include/asm/tlb.h     |  5 ++++-
>  3 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index cfbf307d6dc4..a3b1b789f766 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
>  config ARCH_HAS_CACHE_LINE_SIZE
>  	def_bool y
>  
> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> +	def_bool y if PGTABLE_LEVELS > 2
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
>  }
>  
>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
>  {
>  	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
> +	pgtable_pmd_page_dtor(virt_to_page(pmdp));
>  	free_page((unsigned long)pmdp);
>  }

There is just one problem here. ARM KVM's stage2_pmd_free() calls into pmd_free() on a page
originally allocated with __get_free_page() and never went through pgtable_pmd_page_ctor().
So when ARCH_ENABLE_SPLIT_PMD_PTLOCK is enabled

stage2_pmd_free()
	pgtable_pmd_page_dtor()
		ptlock_free()
			kmem_cache_free(page_ptl_cachep, page->ptl)

Though SLUB implementation for kmem_cache_free() seems to be handling NULL page->ptl (as the
page never got it's lock allocated or initialized) correctly I am not sure if it is a right
thing to do.

