Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 96AD182F86
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 09:20:55 -0400 (EDT)
Received: by wikq8 with SMTP id q8so5616817wik.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 06:20:55 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id lk1si41091107wjb.153.2015.10.19.06.20.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 06:20:54 -0700 (PDT)
Received: by wicfv8 with SMTP id fv8so5546025wic.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 06:20:54 -0700 (PDT)
Date: Mon, 19 Oct 2015 15:20:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: do not inc NR_PAGETABLE if ptlock_init failed
Message-ID: <20151019132053.GI11998@dhcp22.suse.cz>
References: <1445256881-5205-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445256881-5205-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 19-10-15 15:14:41, Vladimir Davydov wrote:
> If ALLOC_SPLIT_PTLOCKS is defined, ptlock_init may fail, in which case
> we shouldn't increment NR_PAGETABLE.
> 
> Since small allocations, such as ptlock, normally do not fail (currently
> they can fail if kmemcg is used though), this patch does not really fix
> anything and should be considered as a code cleanup.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6adf4167d664..30ef3b535444 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1553,8 +1553,10 @@ static inline void pgtable_init(void)
>  
>  static inline bool pgtable_page_ctor(struct page *page)
>  {
> +	if (!ptlock_init(page))
> +		return false;
>  	inc_zone_page_state(page, NR_PAGETABLE);
> -	return ptlock_init(page);
> +	return true;
>  }
>  
>  static inline void pgtable_page_dtor(struct page *page)
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
