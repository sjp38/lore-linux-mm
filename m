Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6F117828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:00:53 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so387242179wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:00:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si3943544wjr.53.2016.01.13.11.00.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 11:00:52 -0800 (PST)
Subject: Re: [PATCH 01/31] mm, gup: introduce concept of "foreign"
 get_user_pages()
References: <20160107000104.1A105322@viggo.jf.intel.com>
 <20160107000106.D9135553@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56969EE1.5060904@suse.cz>
Date: Wed, 13 Jan 2016 20:00:49 +0100
MIME-Version: 1.0
In-Reply-To: <20160107000106.D9135553@viggo.jf.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com

On 01/07/2016 01:01 AM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
> 
> This introduces two new get_user_pages() variants:
> 
> 	get_current_user_pages()
> 	get_foreign_user_pages()
> 
> get_current_user_pages() is a drop-in replacement for when
> get_user_pages() was called with (current, current->mm, ...) as
> arguments.  Using it makes a few of the call sites look a bit
> nicer.
> 
> get_foreign_user_pages() is a replacement for when
> get_user_pages() is called on non-current tsk/mm.
> 
> We leave a stub get_user_pages() around with a __deprecated
> warning.

Hm when replying to previous version I assumed this is because there are many
get_user_pages() callers remaining. But now I see there are just 3 drivers not
converted by this patch? In that case I would favor to convert get_user_pages()
to become what is now get_current_user_pages(). This would be much more
consistent IMHO. We don't need to cater to out-of-tree modules?

Sorry, I should have looked thoroughly on the previous reply, not just assume.

> This also effectively turns get_user_pages_unlocked() in to
> get_user_pages_unlocked_current() since it no longer gets a
> tsk/mm passed in.  I thought that would be too long of a name if
> we added "_current" on there.  BTW, if someone wants the
> get_user_pages_unlocked() behavior with a non-current tsk/mm,
> they just have to use __get_user_pages_unlocked() directly.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: vbabka@suse.cz
> ---

Also (but moot if you accept my suggestion):

> diff -puN mm/nommu.c~get_current_user_pages mm/nommu.c
> --- a/mm/nommu.c~get_current_user_pages	2016-01-06 15:50:02.230003599 -0800
> +++ b/mm/nommu.c	2016-01-06 15:50:02.259004906 -0800
> @@ -182,7 +182,7 @@ finish_or_fault:
>   *   slab page or a secondary page from a compound page
>   * - don't permit access to VMAs that don't support it, such as I/O mappings
>   */
> -long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> +long get_foreign_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		    unsigned long start, unsigned long nr_pages,
>  		    int write, int force, struct page **pages,
>  		    struct vm_area_struct **vmas)
> @@ -199,35 +199,41 @@ long get_user_pages(struct task_struct *
>  }
>  EXPORT_SYMBOL(get_user_pages);

I think you need to change the export here as you did in gup.c

>  
> -long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
> -			   unsigned long start, unsigned long nr_pages,
> +long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  			   int write, int force, struct page **pages,
>  			   int *locked)
>  {
> -	return get_user_pages(tsk, mm, start, nr_pages, write, force,
> -			      pages, NULL);
> +	return get_user_pages(current, current->mm, start, nr_pages, write,
> +			      force, pages, NULL);

Why not use the _current variant here?

>  }
>  EXPORT_SYMBOL(get_user_pages_locked);
>  
> -long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -			       unsigned long start, unsigned long nr_pages,
> +long get_current_user_pages(unsigned long start, unsigned long nr_pages,
> +		    int write, int force, struct page **pages,
> +		    struct vm_area_struct **vmas)
> +{
> +	return get_foreign_user_pages(current, current->mm, start, nr_pages,
> +				      write, force, pages, vmas);
> +}
> +EXPORT_SYMBOL(get_current_user_pages);
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
> +	ret = get_current_user_pages(start, nr_pages, write, force,
> +				     pages, NULL);
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
> diff -puN mm/process_vm_access.c~get_current_user_pages mm/process_vm_access.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
