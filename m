Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 257846B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:18:36 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so29074645wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:18:35 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id h2si21588880wiv.16.2015.03.25.02.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 02:18:34 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 25 Mar 2015 09:18:33 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 48A4C1B08070
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:18:57 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2P9IVGt64880882
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:18:31 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2P9IUKC012733
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:18:31 -0600
Message-ID: <55127D65.7060605@de.ibm.com>
Date: Wed, 25 Mar 2015 10:18:29 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] mm/gup: Replace ACCESS_ONCE with READ_ONCE for STRICT_MM_TYPECHECKS
References: <1427274719-25890-1-git-send-email-mpe@ellerman.id.au> <1427274719-25890-5-git-send-email-mpe@ellerman.id.au>
In-Reply-To: <1427274719-25890-5-git-send-email-mpe@ellerman.id.au>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@ozlabs.org
Cc: linux-kernel@vger.kernel.org, aneesh.kumar@in.ibm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, steve.capper@linaro.org, linux-mm@kvack.org, Jason Low <jason.low2@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>

Am 25.03.2015 um 10:11 schrieb Michael Ellerman:
> If STRICT_MM_TYPECHECKS is enabled the generic gup code fails to build
> because we are using ACCESS_ONCE on non-scalar types.
> 
> Convert all uses to READ_ONCE.

There is a similar patch from Jason Low in Andrews patch.
If that happens in 4.0-rc, we probably want to merge this before 4.0.


> 
> Cc: akpm@linux-foundation.org
> Cc: kirill.shutemov@linux.intel.com
> Cc: aarcange@redhat.com
> Cc: borntraeger@de.ibm.com
> Cc: steve.capper@linaro.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  mm/gup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index a6e24e246f86..120c3adc843c 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -901,7 +901,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  		 *
>  		 * for an example see gup_get_pte in arch/x86/mm/gup.c
>  		 */
> -		pte_t pte = ACCESS_ONCE(*ptep);
> +		pte_t pte = READ_ONCE(*ptep);
>  		struct page *page;
> 
>  		/*
> @@ -1191,7 +1191,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	local_irq_save(flags);
>  	pgdp = pgd_offset(mm, addr);
>  	do {
> -		pgd_t pgd = ACCESS_ONCE(*pgdp);
> +		pgd_t pgd = READ_ONCE(*pgdp);
> 
>  		next = pgd_addr_end(addr, end);
>  		if (pgd_none(pgd))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
