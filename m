Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DF0B56B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:31:00 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so141166116wmr.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 03:31:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 68si10478780wmi.97.2016.01.27.03.30.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 03:30:59 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <20160122180219.164259F1@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8AA6E.2080705@suse.cz>
Date: Wed, 27 Jan 2016 12:30:54 +0100
MIME-Version: 1.0
In-Reply-To: <20160122180219.164259F1@viggo.jf.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, srikar@linux.vnet.ibm.com, jack@suse.cz

On 01/22/2016 07:02 PM, Dave Hansen wrote:
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
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Cc: vbabka@suse.cz

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But,

>  long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  			       unsigned long start, unsigned long nr_pages,
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

I understand your reply to lkp report also means that this no longer locks
current's mmap_sem? :)

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
