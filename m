Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6D1876B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:39:14 -0500 (EST)
Received: by iajr24 with SMTP id r24so1518470iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 11:39:13 -0800 (PST)
Date: Thu, 8 Mar 2012 11:38:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] ksm: cleanup: introduce find_mergeable_vma()
In-Reply-To: <1331118588-1391-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.LSU.2.00.1203081137480.8460@eggly.anvils>
References: <1331118588-1391-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, aarcange@redhat.com

On Wed, 7 Mar 2012, Bob Liu wrote:

> There are multi place do the same check, using find_mergeable_vma() to
> replace.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/ksm.c |   34 +++++++++++++++++++---------------
>  1 files changed, 19 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 1925ffb..3a00767 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -375,6 +375,20 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
>  	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
>  }
>  
> +static struct vm_area_struct *find_mergeable_vma(struct mm_struct *mm,
> +		unsigned long addr)
> +{
> +	struct vm_area_struct *vma;
> +	if (ksm_test_exit(mm))
> +		return NULL;
> +	vma = find_vma(mm, addr);
> +	if (!vma || vma->vm_start > addr)
> +		return NULL;
> +	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> +		return NULL;
> +	return vma;
> +}
> +
>  static void break_cow(struct rmap_item *rmap_item)
>  {
>  	struct mm_struct *mm = rmap_item->mm;
> @@ -388,15 +402,9 @@ static void break_cow(struct rmap_item *rmap_item)
>  	put_anon_vma(rmap_item->anon_vma);
>  
>  	down_read(&mm->mmap_sem);
> -	if (ksm_test_exit(mm))
> -		goto out;
> -	vma = find_vma(mm, addr);
> -	if (!vma || vma->vm_start > addr)
> -		goto out;
> -	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> -		goto out;
> -	break_ksm(vma, addr);
> -out:
> +	vma = find_mergeable_vma(mm, addr);
> +	if (vma)
> +		break_ksm(vma, addr);
>  	up_read(&mm->mmap_sem);
>  }
>  
> @@ -422,12 +430,8 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>  	struct page *page;
>  
>  	down_read(&mm->mmap_sem);
> -	if (ksm_test_exit(mm))
> -		goto out;
> -	vma = find_vma(mm, addr);
> -	if (!vma || vma->vm_start > addr)
> -		goto out;
> -	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> +	vma = find_mergeable_vma(mm, addr);
> +	if (!vma)
>  		goto out;
>  
>  	page = follow_page(vma, addr, FOLL_GET);
> -- 
> 1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
