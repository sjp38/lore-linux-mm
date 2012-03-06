Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 3E5236B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:43:12 -0500 (EST)
Received: by iajr24 with SMTP id r24so10091879iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 15:43:11 -0800 (PST)
Date: Tue, 6 Mar 2012 15:42:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] ksm: cleanup: introduce ksm_check_mm()
In-Reply-To: <1330594374-13497-2-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.LSU.2.00.1203061529030.1292@eggly.anvils>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com> <1330594374-13497-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

On Thu, 1 Mar 2012, Bob Liu wrote:

> There are multi place do the same check.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Combining two sets of alike changes into one function, fair enough.

But am I imagining it, or is vma going to be NULL in the callers forever
after, and KSM badly broken?  And for what is vma passed to the function?

I think you want to redo this with

static struct vm_area_struct *find_mergeable_vma(struct mm_struct *mm,
                                                 unsigned long addr);

The anon_vma aspect that Andrew latched on to: that's rather a red
herring.  It's not so much looking for an anon_vma, it just knows that
if an anon_vma has not (yet) been instantiated there, then it's a
waste of time to look for an Anon or KSM page in that area.

Hugh

> ---
>  mm/ksm.c |   35 ++++++++++++++++++-----------------
>  1 files changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 8e10786..33175af 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -375,11 +375,24 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
>  	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
>  }
>  
> +static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vma,
> +		unsigned long addr)
> +{
> +	if (ksm_test_exit(mm))
> +		return 0;
> +	vma = find_vma(mm, addr);
> +	if (!vma || vma->vm_start > addr)
> +		return 0;
> +	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> +		return 0;
> +	return 1;
> +}
> +
>  static void break_cow(struct rmap_item *rmap_item)
>  {
>  	struct mm_struct *mm = rmap_item->mm;
>  	unsigned long addr = rmap_item->address;
> -	struct vm_area_struct *vma;
> +	struct vm_area_struct *vma = NULL;
>  
>  	/*
>  	 * It is not an accident that whenever we want to break COW
> @@ -388,15 +401,8 @@ static void break_cow(struct rmap_item *rmap_item)
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
> +	if (ksm_check_mm(mm, vma, addr))
> +		break_ksm(vma, addr);
>  	up_read(&mm->mmap_sem);
>  }
>  
> @@ -418,16 +424,11 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>  {
>  	struct mm_struct *mm = rmap_item->mm;
>  	unsigned long addr = rmap_item->address;
> -	struct vm_area_struct *vma;
> +	struct vm_area_struct *vma = NULL;
>  	struct page *page;
>  
>  	down_read(&mm->mmap_sem);
> -	if (ksm_test_exit(mm))
> -		goto out;
> -	vma = find_vma(mm, addr);
> -	if (!vma || vma->vm_start > addr)
> -		goto out;
> -	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> +	if (!ksm_check_mm(mm, vma, addr))
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
