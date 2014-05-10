Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C3F926B0035
	for <linux-mm@kvack.org>; Sat, 10 May 2014 16:17:47 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so5805192pad.9
        for <linux-mm@kvack.org>; Sat, 10 May 2014 13:17:47 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id wt1si4120001pbc.290.2014.05.10.13.17.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 13:17:46 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so5767953pab.12
        for <linux-mm@kvack.org>; Sat, 10 May 2014 13:17:46 -0700 (PDT)
Date: Sat, 10 May 2014 13:16:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm: use a light-weight __mod_zone_page_state in
 mlocked_vma_newpage()
In-Reply-To: <d756fd253f7f32da37f5320a8e6dc9207ea5ba86.1399705884.git.nasa4836@gmail.com>
Message-ID: <alpine.LSU.2.11.1405101251570.1680@eggly.anvils>
References: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com> <d756fd253f7f32da37f5320a8e6dc9207ea5ba86.1399705884.git.nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, fabf@skynet.be, cldu@marvell.com, sasha.levin@oracle.com, aarcange@redhat.com, zhangyanfei@cn.fujitsu.com, oleg@redhat.com, n-horiguchi@ah.jp.nec.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 May 2014, Jianyu Zhan wrote:

> mlocked_vma_newpage() is only called in fault path by
> page_add_new_anon_rmap(), which is called on a *new* page.
> And such page is initially only visible via the pagetables, and the
> pte is locked while calling page_add_new_anon_rmap(), so we need not
> use an irq-safe mod_zone_page_state() here, using a light-weight version
> __mod_zone_page_state() would be OK.
> 
> And as suggested by Andrew, to reduce the risks that new call sites
> incorrectly using mlocked_vma_newpage() without knowing they are adding
> racing, this patch also moves it from internal.h to right before its only
> call site page_add_new_anon_rmap() in rmap.c, with detailed document added.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

I completely agree with Andrew's suggestion that you move the code
from mm/internal.h to its sole callsite in mm/rmap.c; but I much
prefer his "probably better ... open-coding its logic into
page_add_new_anon_rmap()".

That saves you from having to dream up a satisfactory alternative name,
and a lengthy comment, and let's everybody see just what's going on.

The function-in-internal.h thing dates from an interim in which,
running short of page flags, we were not confident that we wanted
to dedicate one to PageMlocked: not all configs had it and internal.h
was somewhere to hide the #ifdefs.  Well, PageMlocked is there only
when CONFIG_MMU, but mm/rmap.c is only built for CONFIG_MMU anyway.

> ---
>  mm/internal.h | 22 ++--------------------
>  mm/rmap.c     | 24 ++++++++++++++++++++++++
>  2 files changed, 26 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 07b6736..20abafb 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -183,26 +183,8 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
>  	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
>  }
>  
> -/*
> - * Called only in fault path, to determine if a new page is being
> - * mapped into a LOCKED vma.  If it is, mark page as mlocked.
> - */
> -static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
> -				    struct page *page)
> -{
> -	VM_BUG_ON_PAGE(PageLRU(page), page);
> -
> -	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
> -		return 0;
> -
> -	if (!TestSetPageMlocked(page)) {
> -		mod_zone_page_state(page_zone(page), NR_MLOCK,

So there we see mod_zone_page_state...

> -				    hpage_nr_pages(page));
> -		count_vm_event(UNEVICTABLE_PGMLOCKED);
> -	}
> -	return 1;
> -}
> -
> +extern int mlocked_vma_newpage(struct vm_area_struct *vma,
> +				struct page *page);

Why are you adding an extern declaration for it, when it's only
used from the one source file to which you are moving it?

Why are you not removing the !CONFIG_MMU declaration?

>  /*
>   * must be called with vma's mmap_sem held for read or write, and page locked.
>   */
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6078a30..a9d02ef 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1005,6 +1005,30 @@ void do_page_add_anon_rmap(struct page *page,
>  		__page_check_anon_rmap(page, vma, address);
>  }
>  
> +/*
> + * Called only in fault path, to determine if a new page is being
> + * mapped into a LOCKED vma.  If it is, mark page as mlocked.
> + * This function is only called in fault path by
> + * page_add_new_anon_rmap(), which is called on a *new* page.
> + * And such page is initially only visible via the pagetables, and the
> + * pte is locked while calling page_add_new_anon_rmap(), so using a
> + * light-weight version __mod_zone_page_state() would be OK.

No.  See my remarks on 1/3, that's not it at all: it's that we do
not update the NR_MLOCK count from interrupt context (I hope: check).

> + */
> +int mlocked_vma_newpage(struct vm_area_struct *vma,

I would say static, except you should just be bringing the code
into its callsite.

> +					struct page *page)
> +{
> +	VM_BUG_ON_PAGE(PageLRU(page), page);
> +	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
> +		return 0;
> +
> +	if (!TestSetPageMlocked(page)) {
> +		__mod_zone_page_state(page_zone(page), NR_MLOCK,

And here appears __mod_zone_page_state: you have a patch for moving
a function from one place to another, and  buried within that movement
you hide a "signficant" change.  No, don't do that.

Hugh

> +					hpage_nr_pages(page));
> +		count_vm_event(UNEVICTABLE_PGMLOCKED);
> +	}
> +	return 1;
> +}
> +
>  /**
>   * page_add_new_anon_rmap - add pte mapping to a new anonymous page
>   * @page:	the page to add the mapping to
> -- 
> 2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
