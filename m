Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8278CC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:15:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438A9216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QBA+dCN6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438A9216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE18F6B02E7; Wed, 21 Aug 2019 11:15:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B92456B02E8; Wed, 21 Aug 2019 11:15:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA8696B02E9; Wed, 21 Aug 2019 11:15:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 8907C6B02E7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:15:55 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EF4DC2C98
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:15:54 +0000 (UTC)
X-FDA: 75846785028.10.alarm33_507f1c32e5700
X-HE-Tag: alarm33_507f1c32e5700
X-Filterd-Recvd-Size: 3197
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:15:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=iVHDhSA41pY3KOKvtbWLUEDzU5HZlZ5F6SW53D0z32I=; b=QBA+dCN6KNJgiRleSHdwLzok/
	yU6238OA3P2HZLowgurEMrfBgCOoTpgz1w475l8tO9zEPLAS5F65blzedJvKy1f9t7WQImHmdo3y2
	HKrohpsKZOW/5rQA8vf3t+UkXMEUKyK/2FWv0Y4dXQgTiv308iPEd3FdcJ5o5SsiBlggGHdnU2Y2n
	UMfaBDCbVcicSx4EQLk74L7imSOZ5sZtVOHJWAlFDULCTdhOq0fcJvwC4ZIYpxk7v+Krk9kgTQCSW
	jZlokkVEKcdsgnNcqxVs9n1HjjF7S1FH0Ya1YnWDSUXA2TJMSPboxjyVxpzxVQ55+uKVF3gCXwz+/
	ULG7smB+w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0SKu-0006hk-DY; Wed, 21 Aug 2019 15:15:44 +0000
Date: Wed, 21 Aug 2019 08:15:44 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: consolidate pgtable_cache_init() and pgd_cache_init()
Message-ID: <20190821151544.GC28819@bombadil.infradead.org>
References: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 06:06:58PM +0300, Mike Rapoport wrote:
> +++ b/arch/alpha/include/asm/pgtable.h
> @@ -362,7 +362,6 @@ extern void paging_init(void);
>  /*
>   * No page table caches to initialise
>   */
> -#define pgtable_cache_init()	do { } while (0)

Delete the comment too?

> +++ b/arch/arc/include/asm/pgtable.h
> @@ -398,7 +398,6 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
>  /*
>   * No page table caches to initialise
>   */
> -#define pgtable_cache_init()   do { } while (0)

ditto

> +++ b/arch/arm/include/asm/pgtable.h
> @@ -368,7 +368,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>  #define HAVE_ARCH_UNMAPPED_AREA
>  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
>  
> -#define pgtable_cache_init() do { } while (0)
>  
>  #endif /* !__ASSEMBLY__ */

delete one of the two blank lines?

> +++ b/arch/c6x/include/asm/pgtable.h
> @@ -62,7 +62,6 @@ extern unsigned long empty_zero_page;
>  /*
>   * No page table caches to initialise
>   */
> -#define pgtable_cache_init()   do { } while (0)

delete comment ... more of these.


