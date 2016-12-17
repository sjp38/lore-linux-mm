Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3022C6B0253
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 02:53:30 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id y21so13251208lfa.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 23:53:30 -0800 (PST)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id 9si5836298lff.251.2016.12.16.23.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 23:53:28 -0800 (PST)
Date: Sat, 17 Dec 2016 08:53:25 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 06/14] sparc64: general shared context tsb creation
 and support
Message-ID: <20161217075325.GD23567@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-7-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481913337-9331-7-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike

> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -162,8 +162,14 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  {
>  	pte_t orig;
>  
> -	if (!pte_present(*ptep) && pte_present(entry))
> -		mm->context.hugetlb_pte_count++;
> +	if (!pte_present(*ptep) && pte_present(entry)) {
> +#if defined(CONFIG_SHARED_MMU_CTX)
> +		if (pte_val(entry) | _PAGE_SHR_CTX_4V)
> +			mm->context.shared_hugetlb_pte_count++;
> +		else
> +#endif
> +			mm->context.hugetlb_pte_count++;
> +	}

This kind of conditional code it just too ugly to survive...
Could a static inline be used to help you here?
The compiler will inline it so there should not be any run-time cost

>  
>  	mm_rss -= saved_thp_pte_count * (HPAGE_SIZE / PAGE_SIZE);
>  #endif
> @@ -544,8 +576,10 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
>  	 * us, so we need to zero out the TSB pointer or else tsb_grow()
>  	 * will be confused and think there is an older TSB to free up.
>  	 */
> -	for (i = 0; i < MM_NUM_TSBS; i++)
> +	for (i = 0; i < MM_NUM_TSBS; i++) {
>  		mm->context.tsb_block[i].tsb = NULL;
> +		mm->context.tsb_descr[i].tsb_base = 0UL;
> +	}
This change seems un-related to the rest?

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
