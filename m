Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC4C66B004A
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 10:06:59 -0500 (EST)
Date: Fri, 3 Dec 2010 16:00:21 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Flushing whole page instead of work for ptrace
Message-ID: <20101203150021.GA11114@redhat.com>
References: <4CEFA8AE.2090804@petalogix.com> <20101130233250.35603401C8@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130233250.35603401C8@magilla.sf.frob.com>
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: michal.simek@petalogix.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, John Williams <john.williams@petalogix.com>, "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
List-ID: <linux-mm.kvack.org>

On 11/30, Roland McGrath wrote:
>
> Documentation/cachetlb.txt says:
>
> 	Any time the kernel writes to a page cache page, _OR_
> 	the kernel is about to read from a page cache page and
> 	user space shared/writable mappings of this page potentially
> 	exist, this routine is called.
>
> In your case, the kernel is only reading (write=0 passed to
> access_process_vm and get_user_pages).  In normal situations,
> the page in question will have only a private and read-only
> mapping in user space.  So the call should not be required in
> these cases--if the code can tell that's so.
>
> Perhaps something like the following would be safe.
> But you really need some VM folks to tell you for sure.
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 02e48aa..2864ee7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1484,7 +1484,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  				pages[i] = page;
>
>  				flush_anon_page(vma, page, start);
> -				flush_dcache_page(page);
> +				if ((vm_flags & VM_WRITE) || (vma->vm_flags & VM_SHARED)
> +					flush_dcache_page(page);

First of all, I know absolutely nothing about D-cache aliasing.
My poor understanding of flush_dcache_page() is: synchronize the
kernel/user vision of this memory, in the case when either side
can change it.

If this is true, then this change doesn't look right in general.

Even if (vma->vm_flags & VM_SHARED) == 0, it is possible that
tsk can write to this memory, this mapping can be writable and
private.

Even if we ensure that this mapping is readonly/private, another
user-space process can write to this page via shared/writable
mapping.


I'd like to know if my understanding is correct, I am just curious.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
