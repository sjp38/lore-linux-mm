Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9712B6B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 19:35:25 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so4233520pad.21
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 16:35:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fb8si10637343pab.254.2014.04.21.16.35.24
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 16:35:24 -0700 (PDT)
Date: Mon, 21 Apr 2014 16:35:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm: extract code to fault in a page from
 __get_user_pages()
Message-Id: <20140421163522.41bba07f9e6ea11549383ad4@linux-foundation.org>
In-Reply-To: <1396535722-31108-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1396535722-31108-5-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Thu,  3 Apr 2014 17:35:21 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Nesting level in __get_user_pages() is just insane. Let's try to fix it
> a bit.
> 
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -388,69 +443,22 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			while (!(page = follow_page_mask(vma, start,
>  						foll_flags, &page_mask))) {
>  				int ret;
> -				unsigned int fault_flags = 0;
> -
> -				/* For mlock, just skip the stack guard page. */
> -				if (foll_flags & FOLL_MLOCK) {
> -					if (stack_guard_page(vma, start))
> -						goto next_page;
> -				}
> -				if (foll_flags & FOLL_WRITE)
> -					fault_flags |= FAULT_FLAG_WRITE;
> -				if (nonblocking)
> -					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
> -				if (foll_flags & FOLL_NOWAIT)
> -					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
> -
> -				ret = handle_mm_fault(mm, vma, start,
> -							fault_flags);
> -
> -				if (ret & VM_FAULT_ERROR) {
> -					if (ret & VM_FAULT_OOM)
> -						return i ? i : -ENOMEM;
> -					if (ret & (VM_FAULT_HWPOISON |
> -						   VM_FAULT_HWPOISON_LARGE)) {
> -						if (i)
> -							return i;
> -						else if (gup_flags & FOLL_HWPOISON)
> -							return -EHWPOISON;
> -						else
> -							return -EFAULT;
> -					}
> -					if (ret & VM_FAULT_SIGBUS)
> -						return i ? i : -EFAULT;
> -					BUG();
> -				}
> -
> -				if (tsk) {
> -					if (ret & VM_FAULT_MAJOR)
> -						tsk->maj_flt++;
> -					else
> -						tsk->min_flt++;
> -				}
> -
> -				if (ret & VM_FAULT_RETRY) {
> -					if (nonblocking)
> -						*nonblocking = 0;
> +				ret = faultin_page(tsk, vma, start, &foll_flags,
> +						nonblocking);
> +				switch (ret) {
> +				case 0:
> +					break;
> +				case -EFAULT:
> +				case -ENOMEM:
> +				case -EHWPOISON:
> +					return i ? i : ret;
> +				case -EBUSY:
>  					return i;
> +				case -ENOENT:
> +					goto next_page;
> +				default:
> +					BUILD_BUG();

hm, why the BUILD_BUG?  It triggers all the time.  I'll switch it to
BUG but I worry about how this passed your testing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
