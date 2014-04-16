Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 843FA6B003C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:19:46 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so11362355pad.35
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 13:19:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m8si13323200pbd.245.2014.04.16.13.19.45
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 13:19:45 -0700 (PDT)
Date: Wed, 16 Apr 2014 13:19:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: close race between split and zap huge pages
Message-Id: <20140416131942.aaf8e560e45062c9857a2648@linux-foundation.org>
In-Reply-To: <1397598515-25017-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1397598515-25017-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 16 Apr 2014 00:48:35 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Sasha Levin has reported two THP BUGs[1][2]. I believe both of them have
> the same root cause. Let's look to them one by one.
> 
> The first bug[1] is "kernel BUG at mm/huge_memory.c:1829!".
> It's BUG_ON(mapcount != page_mapcount(page)) in __split_huge_page().
> >From my testing I see that page_mapcount() is higher than mapcount here.
> 
> I think it happens due to race between zap_huge_pmd() and
> page_check_address_pmd(). page_check_address_pmd() misses PMD
> which is under zap:

Why did this bug happen?

In other words, what earlier mistakes had we made which led to you
getting this locking wrong?  

Based on that knowledge, what can we do to reduce the likelihood of
such mistakes being made in the future?  (Hint: the answer to this
will involve making changes to this patch).

> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1536,16 +1536,23 @@ pmd_t *page_check_address_pmd(struct page *page,
>  			      enum page_check_address_pmd_flag flag,
>  			      spinlock_t **ptl)
>  {
> +	pgd_t *pgd;
> +	pud_t *pud;
>  	pmd_t *pmd;
>  
>  	if (address & ~HPAGE_PMD_MASK)
>  		return NULL;
>  
> -	pmd = mm_find_pmd(mm, address);
> -	if (!pmd)
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
>  		return NULL;
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		return NULL;
> +	pmd = pmd_offset(pud, address);
> +
>  	*ptl = pmd_lock(mm, pmd);
> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		goto unlock;
>  	if (pmd_page(*pmd) != page)
>  		goto unlock;

So how do other callers of mm_find_pmd() manage to avoid this race, or
are they all buggy?

Is mm_find_pmd() really so simple and obvious that we can afford to
leave it undocumented?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
