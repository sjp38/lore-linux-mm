Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id EDE0C6B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 11:42:00 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so102214858igb.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 08:42:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id nq5si922682igb.89.2015.09.23.08.41.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 08:41:59 -0700 (PDT)
Date: Wed, 23 Sep 2015 17:38:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150923153857.GA20233@redhat.com>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi> <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <20150923153416.GA18973@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923153416.GA18973@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>

On 09/23, Oleg Nesterov wrote:
>
> On 09/11, Kirill A. Shutemov wrote:
> >
> > This one is tricky. I *assume* the mm cannot be generally accessible after
> > mm_users drops to zero, but I'm not entirely sure about it.
> > procfs? ptrace?
>
> Well, all I can say is that proc/ptrace look fine afaics...
>
> This is off-topic, but how about the patch below? Different threads can
> expand different vma's at the same time under read_lock(mmap_sem), so
> vma_lock_anon_vma() can't help to serialize "locked_vm += grow".

perhaps vm_stat_account() should be moved too, but total_vm/etc is less
important.

Or I missed something?

Oleg.

> --- x/mm/mmap.c
> +++ x/mm/mmap.c
> @@ -2146,9 +2146,6 @@ static int acct_stack_growth(struct vm_a
>  	if (security_vm_enough_memory_mm(mm, grow))
>  		return -ENOMEM;
>  
> -	/* Ok, everything looks good - let it rip */
> -	if (vma->vm_flags & VM_LOCKED)
> -		mm->locked_vm += grow;
>  	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
>  	return 0;
>  }
> @@ -2210,6 +2207,8 @@ int expand_upwards(struct vm_area_struct
>  				 * against concurrent vma expansions.
>  				 */
>  				spin_lock(&vma->vm_mm->page_table_lock);
> +				if (vma->vm_flags & VM_LOCKED)
> +					mm->locked_vm += grow;
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_end = address;
>  				anon_vma_interval_tree_post_update_vma(vma);
> @@ -2281,6 +2280,8 @@ int expand_downwards(struct vm_area_stru
>  				 * against concurrent vma expansions.
>  				 */
>  				spin_lock(&vma->vm_mm->page_table_lock);
> +				if (vma->vm_flags & VM_LOCKED)
> +					mm->locked_vm += grow;
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_start = address;
>  				vma->vm_pgoff -= grow;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
