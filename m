Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 90A516B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 14:30:57 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so192653830wmf.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 11:30:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a4si42530904wmi.32.2016.01.20.11.30.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 11:30:56 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <20160120173504.59300BEC@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569FE069.6080205@suse.cz>
Date: Wed, 20 Jan 2016 20:30:49 +0100
MIME-Version: 1.0
In-Reply-To: <20160120173504.59300BEC@viggo.jf.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 01/20/2016 06:35 PM, Dave Hansen wrote:
> Here's another revision taking Vlastimil's suggestions about
> keeping __get_user_pages_unlocked() as-is in to account.
> This does, indeed, look nicer.  Now, all the "__" variants
> take a full tsk/mm and flags.
> 
> He also noted that the two sites where we called gup with
> tsk=NULL were probably incorrectly changing behavior with respect
> to fault accounting.  Long-term, I wonder if we should just add
> a "FOLL_" flag to make that more explicit, but for now, I've
> fixed up those sites.
> 
> ---
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
> 
> This patch introduces a new get_user_pages() variant:
> 
> 	get_user_pages_foreign()
> 
> The plain get_user_pages() can no longer be used on mm/tasks
> other than 'current/current->mm', which is by far the most common
> way it is called.  Using it makes a few of the call sites look a
> bit nicer.
> 
> In other words, get_user_pages_foreign() is a replacement for
> when get_user_pages() is called on non-current tsk/mm.
> 
> This also switches get_user_pages_(un)locked() over to be like
> get_user_pages() and not take a tsk/mm.  There is no
> get_user_pages_foreign_(un)locked().  If someone wants that
> behavior they just have to use "__" variant and pass in
> FOLL_FOREIGN explicitly.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: vbabka@suse.cz
> Cc: jack@suse.cz
> ---
> 

After you fix up the nommu version of __get_user_pages_unlocked() below to match
the mmu one,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff -puN mm/nommu.c~get_current_user_pages mm/nommu.c
> --- a/mm/nommu.c~get_current_user_pages	2016-01-19 15:48:31.794063748 -0800
> +++ b/mm/nommu.c	2016-01-19 15:48:31.835065603 -0800

[...]

> -long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -			       unsigned long start, unsigned long nr_pages,
> +long get_user_pages(unsigned long start, unsigned long nr_pages,
> +		    int write, int force, struct page **pages,
> +		    struct vm_area_struct **vmas)
> +{
> +	return get_user_pages_foreign(current, current->mm, start, nr_pages,
> +				      write, force, pages, vmas);
> +}
> +EXPORT_SYMBOL(get_user_pages);
> +
> +long __get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			       int write, int force, struct page **pages,
>  			       unsigned int gup_flags)
>  {
>  	long ret;
> -	down_read(&mm->mmap_sem);
> -	ret = get_user_pages(tsk, mm, start, nr_pages, write, force,
> -			     pages, NULL);
> -	up_read(&mm->mmap_sem);
> +	down_read(&current->mm->mmap_sem);
> +	ret = get_user_pages(start, nr_pages, write, force, pages, NULL);
> +	up_read(&current->mm->mmap_sem);
>  	return ret;
>  }
>  EXPORT_SYMBOL(__get_user_pages_unlocked);
>  
> -long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -			     unsigned long start, unsigned long nr_pages,
> +long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     int write, int force, struct page **pages)
>  {
> -	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
> +	return __get_user_pages_unlocked(start, nr_pages, write,
>  					 force, pages, 0);
>  }
>  EXPORT_SYMBOL(get_user_pages_unlocked);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
