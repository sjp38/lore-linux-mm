Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5968BC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:36:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 215AA216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:36:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 215AA216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C33B26B0278; Wed, 21 Aug 2019 14:36:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4686B0282; Wed, 21 Aug 2019 14:36:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFA926B0288; Wed, 21 Aug 2019 14:36:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0032.hostedemail.com [216.40.44.32])
	by kanga.kvack.org (Postfix) with ESMTP id 912F56B0278
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:36:24 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 49A01181AC9C4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:36:24 +0000 (UTC)
X-FDA: 75847290288.03.fifth19_54fb0a7c5775d
X-HE-Tag: fifth19_54fb0a7c5775d
X-Filterd-Recvd-Size: 3085
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:36:23 +0000 (UTC)
Received: from p5de0b6c5.dip0.t-ipconnect.de ([93.224.182.197] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1i0VSx-0003HL-QR; Wed, 21 Aug 2019 20:36:15 +0200
Date: Wed, 21 Aug 2019 20:36:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Mike Rapoport <rppt@linux.ibm.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: consolidate pgtable_cache_init() and
 pgd_cache_init()
In-Reply-To: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
Message-ID: <alpine.DEB.2.21.1908212035200.1983@nanos.tec.linutronix.de>
References: <1566400018-15607-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Aug 2019, Mike Rapoport wrote:
> diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
> index b9b9f8a..0dca7f7 100644
> --- a/arch/x86/include/asm/pgtable_32.h
> +++ b/arch/x86/include/asm/pgtable_32.h
> @@ -29,7 +29,6 @@ extern pgd_t swapper_pg_dir[1024];
>  extern pgd_t initial_page_table[1024];
>  extern pmd_t initial_pg_pmd[];
>  
> -static inline void pgtable_cache_init(void) { }
>  void paging_init(void);
>  void sync_initial_page_table(void);
>  
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index a26d2d5..0b6c4042 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -241,8 +241,6 @@ extern void cleanup_highmap(void);
>  #define HAVE_ARCH_UNMAPPED_AREA
>  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
>  
> -#define pgtable_cache_init()   do { } while (0)
> -
>  #define PAGE_AGP    PAGE_KERNEL_NOCACHE
>  #define HAVE_PAGE_AGP 1
>  
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 73757bc..3e4b903 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -357,7 +357,7 @@ static void pgd_prepopulate_user_pmd(struct mm_struct *mm,
>  
>  static struct kmem_cache *pgd_cache;
>  
> -void __init pgd_cache_init(void)
> +void __init pgtable_cache_init(void)
>  {
>  	/*
>  	 * When PAE kernel is running as a Xen domain, it does not use
> @@ -402,10 +402,6 @@ static inline void _pgd_free(pgd_t *pgd)
>  }
>  #else
>  
> -void __init pgd_cache_init(void)
> -{
> -}

Acked-by: Thomas Gleixner <tglx@linutronix.de>

