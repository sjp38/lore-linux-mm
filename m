Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65E4D6B0291
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 08:15:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so47645785wjb.7
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:15:59 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id b81si14745299wmc.110.2016.12.19.05.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 05:15:58 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id j10so23564385wjb.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:15:57 -0800 (PST)
Date: Mon, 19 Dec 2016 14:15:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm: clarify mm_struct.mm_{users,count} documentation
Message-ID: <20161219131556.GA5164@dhcp22.suse.cz>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
 <20161218123229.22952-4-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161218123229.22952-4-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Sun 18-12-16 13:32:29, Vegard Nossum wrote:
> Clarify documentation relating to mm_users and mm_count, and switch to
> kernel-doc syntax.

Looks good to me.
 
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 23 +++++++++++++++++++++--
>  1 file changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 08d947fc4c59..316c3e1fc226 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -407,8 +407,27 @@ struct mm_struct {
>  	unsigned long task_size;		/* size of task vm space */
>  	unsigned long highest_vm_end;		/* highest vma end address */
>  	pgd_t * pgd;
> -	atomic_t mm_users;			/* How many users with user space? */
> -	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> +
> +	/**
> +	 * @mm_users: The number of users including userspace.
> +	 *
> +	 * Use mmget()/mmget_not_zero()/mmput() to modify. When this drops
> +	 * to 0 (i.e. when the task exits and there are no other temporary
> +	 * reference holders), we also release a reference on @mm_count
> +	 * (which may then free the &struct mm_struct if @mm_count also
> +	 * drops to 0).
> +	 */
> +	atomic_t mm_users;
> +
> +	/**
> +	 * @mm_count: The number of references to &struct mm_struct
> +	 * (@mm_users count as 1).
> +	 *
> +	 * Use mmgrab()/mmdrop() to modify. When this drops to 0, the
> +	 * &struct mm_struct is freed.
> +	 */
> +	atomic_t mm_count;
> +
>  	atomic_long_t nr_ptes;			/* PTE page table pages */
>  #if CONFIG_PGTABLE_LEVELS > 2
>  	atomic_long_t nr_pmds;			/* PMD page table pages */
> -- 
> 2.11.0.1.gaa10c3f
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
