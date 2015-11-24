Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C49666B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:22:28 -0500 (EST)
Received: by pacej9 with SMTP id ej9so16709954pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:22:28 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ud10si20971201pab.54.2015.11.24.01.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:22:28 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so17285361pab.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:22:28 -0800 (PST)
Date: Tue, 24 Nov 2015 18:23:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124092326.GC1254@swordfish>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124042941.GE705@swordfish>
 <20151124090930.GB15712@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124090930.GB15712@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/24/15 11:09), Kirill A. Shutemov wrote:
[..]
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index 374931f32ebc..4ea9c4ef5146 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -66,8 +66,12 @@ static int page_idle_clear_pte_refs_one(struct page *page,
>  	if (pte) {
>  		referenced = ptep_clear_young_notify(vma, addr, pte);
>  		pte_unmap(pte);
> -	} else
> +	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
>  		referenced = pmdp_clear_young_notify(vma, addr, pmd);
> +	} else {
> +		/* unexpected pmd-mapped page? */
> +		WARN_ON_ONCE(1);
> +	}
>  
>  	spin_unlock(ptl);
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 27916086ac50..499b24511b1f 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -929,9 +929,12 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  				referenced++;
>  		}
>  		pte_unmap(pte);
> -	} else {
> +	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
>  		if (pmdp_clear_flush_young_notify(vma, address, pmd))
>  			referenced++;
> +	} else {
> +		/* unexpected pmd-mapped page? */
> +		WARN_ON_ONCE(1);
>  	}
>  	spin_unlock(ptl);

yes, works for me.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
