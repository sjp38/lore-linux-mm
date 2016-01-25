Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD096B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:17:51 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id cy9so80937249pac.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:17:51 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id fm8si33702147pad.29.2016.01.25.05.17.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 05:17:50 -0800 (PST)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 25 Jan 2016 18:47:47 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0PDHiXn1179916
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:47:45 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0PDHcg5013139
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:47:40 +0530
Date: Mon, 25 Jan 2016 18:47:24 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
Message-ID: <20160125131723.GB17206@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20160122180219.164259F1@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160122180219.164259F1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, vbabka@suse.cz, jack@suse.cz, Oleg Nesterov <oleg@redhat.com>

> 
> One of Vlastimil's comments made me go dig back in to the uprobes
> code's use of get_user_pages().  I decided to change both of them
> to be "foreign" accesses.
> 
> This also fixes the nommu breakage that Vlastimil noted last time.
> 
> Srikar, I'd appreciate if you can have a look at the uprobes.c
> modifications, especially the comment.  I don't think this will
> change any behavior, but I want to make sure the comment is
> accurate.
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
> We modify the vanilla get_user_pages() so it can no longer be
> used on mm/tasks other than 'current/current->mm', which is by
> far the most common way it is called.  Using it makes a few of
> the call sites look a bit nicer.
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
> The uprobes is_trap_at_addr() location holds mmap_sem and
> calls get_user_pages(current->mm) on an instruction address.  This
> makes it a pretty unique gup caller.  Being an instruction access
> and also really originating from the kernel (vs. the app), I opted
> to consider this a 'foreign' access where protection keys will not
> be enforced.
> 

Changes for uprobes.c looks good to me.
Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Cc: vbabka@suse.cz
> Cc: jack@suse.cz

> diff -puN kernel/events/uprobes.c~get_current_user_pages kernel/events/uprobes.c
> --- a/kernel/events/uprobes.c~get_current_user_pages	2016-01-22 08:43:42.602473969 -0800
> +++ b/kernel/events/uprobes.c	2016-01-22 09:36:14.203845894 -0800
> @@ -299,7 +299,7 @@ int uprobe_write_opcode(struct mm_struct
> 
>  retry:
>  	/* Read the page with vaddr into memory */
> -	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
> +	ret = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
>  	if (ret <= 0)
>  		return ret;
> 
> @@ -1700,7 +1700,13 @@ static int is_trap_at_addr(struct mm_str
>  	if (likely(result == 0))
>  		goto out;
> 
> -	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> +	/*
> +	 * The NULL 'tsk' here ensures that any faults that occur here
> +	 * will not be accounted to the task.  'mm' *is* current->mm,
> +	 * but we treat this as a 'foreign' access since it is
> +	 * essentially a kernel access to the memory.
> +	 */
> +	result = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
>  	if (result < 0)
>  		return result;
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
