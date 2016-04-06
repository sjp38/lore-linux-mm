Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EFFDB6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:56:26 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l6so57403615wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:56:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 3si24006508wmk.45.2016.04.06.02.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 02:56:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a140so11639952wma.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:56:25 -0700 (PDT)
Date: Wed, 6 Apr 2016 11:56:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
Message-ID: <20160406095623.GA24283@dhcp22.suse.cz>
References: <20160405190547.GA12673@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160405190547.GA12673@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, James Dykman <jdykman@us.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue 05-04-16 12:05:47, Sukadev Bhattiprolu wrote:
[...]
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index d991b9e..081f679 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -81,6 +81,13 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  	if (! new)
>  		return -ENOMEM;
>  
> +	/*
> +	 * Make sure other cpus find the hugepd set only after a
> +	 * properly initialized page table is visible to them.
> +	 * For more details look for comment in __pte_alloc().
> +	 */
> +	smp_wmb();
> +

what is the pairing memory barrier?

>  	spin_lock(&mm->page_table_lock);
>  #ifdef CONFIG_PPC_FSL_BOOK3E
>  	/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
