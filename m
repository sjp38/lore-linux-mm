Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6856B025F
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:37:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so12663756wrf.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:37:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si1585163wmd.187.2017.09.26.06.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:37:09 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:37:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
Message-ID: <20170926133707.wquyw3ic5nbmfjuo@dhcp22.suse.cz>
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 22-09-17 15:13:56, Reza Arbab wrote:
> The move_pages() syscall can be used to find the numa node where a page
> currently resides. This is not working for device public memory pages,
> which erroneously report -EFAULT (unmapped or zero page).
> 
> Enable by adding a FOLL_DEVICE flag for follow_page(), which
> move_pages() will use. This could be done unconditionally, but adding a
> flag seems like a safer change.

I do not understand purpose of this patch. What is the numa node of a
device memory?

> Cc: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h | 1 +
>  mm/gup.c           | 2 +-
>  mm/migrate.c       | 2 +-
>  3 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f8c10d3..783cb57 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2368,6 +2368,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
>  #define FOLL_MLOCK	0x1000	/* lock present pages */
>  #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
>  #define FOLL_COW	0x4000	/* internal GUP flag */
> +#define FOLL_DEVICE	0x8000	/* return device pages */
>  
>  static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
>  {
> diff --git a/mm/gup.c b/mm/gup.c
> index b2b4d42..6fbad70 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -110,7 +110,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
>  		return NULL;
>  	}
>  
> -	page = vm_normal_page(vma, address, pte);
> +	page = _vm_normal_page(vma, address, pte, flags & FOLL_DEVICE);
>  	if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
>  		/*
>  		 * Only return device mapping pages in the FOLL_GET case since
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6954c14..dea0ceb 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1690,7 +1690,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
>  			goto set_status;
>  
>  		/* FOLL_DUMP to ignore special (like zero) pages */
> -		page = follow_page(vma, addr, FOLL_DUMP);
> +		page = follow_page(vma, addr, FOLL_DUMP | FOLL_DEVICE);
>  
>  		err = PTR_ERR(page);
>  		if (IS_ERR(page))
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
