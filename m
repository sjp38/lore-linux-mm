Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DC756B0089
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 12:13:55 -0500 (EST)
Date: Fri, 3 Dec 2010 18:07:12 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Flushing whole page instead of work for ptrace
Message-ID: <20101203170712.GA16642@redhat.com>
References: <4CEFA8AE.2090804@petalogix.com> <20101130233250.35603401C8@magilla.sf.frob.com> <20101203150021.GA11114@redhat.com> <20101203162817.GA21438@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101203162817.GA21438@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Roland McGrath <roland@redhat.com>, michal.simek@petalogix.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, John Williams <john.williams@petalogix.com>, "Edgar E. Iglesias" <edgar.iglesias@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On 12/04, Minchan Kim wrote:
>
> On Fri, Dec 03, 2010 at 04:00:21PM +0100, Oleg Nesterov wrote:
> > On 11/30, Roland McGrath wrote:
> > >
> > > Documentation/cachetlb.txt says:
> > >
> > > 	Any time the kernel writes to a page cache page, _OR_
> > > 	the kernel is about to read from a page cache page and
> > > 	user space shared/writable mappings of this page potentially
> > > 	exist, this routine is called.
> > >
> > > In your case, the kernel is only reading (write=0 passed to
> > > access_process_vm and get_user_pages).  In normal situations,
> > > the page in question will have only a private and read-only
> > > mapping in user space.  So the call should not be required in
> > > these cases--if the code can tell that's so.
> > >
> > > Perhaps something like the following would be safe.
> > > But you really need some VM folks to tell you for sure.
> > >
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 02e48aa..2864ee7 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -1484,7 +1484,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > >  				pages[i] = page;
> > >
> > >  				flush_anon_page(vma, page, start);
> > > -				flush_dcache_page(page);
> > > +				if ((vm_flags & VM_WRITE) || (vma->vm_flags & VM_SHARED)
> > > +					flush_dcache_page(page);
> >
> > First of all, I know absolutely nothing about D-cache aliasing.
> > My poor understanding of flush_dcache_page() is: synchronize the
> > kernel/user vision of this memory, in the case when either side
> > can change it.
> >
> > If this is true, then this change doesn't look right in general.
> >
> > Even if (vma->vm_flags & VM_SHARED) == 0, it is possible that
> > tsk can write to this memory, this mapping can be writable and
> > private.
> >
> > Even if we ensure that this mapping is readonly/private, another
> > user-space process can write to this page via shared/writable
> > mapping.
> >
>
> I think you're right. It has a portential that other processes have
> a such mapping.
>
> >
> > I'd like to know if my understanding is correct, I am just curious.
> >
> > Oleg.
>
> How about this?
> Maybe this patch would mitigate the overhead.
> But I am not sure this patch. Cced GUP experts.
>
> From 8fb3d84c7bb32c4ba9c4a0063198ce7cfcca6b37 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Sat, 4 Dec 2010 01:19:43 +0900
> Subject: [PATCH] Remove redundant flush_dcache_page in GUP
>
> If we get the page with handle_mm_fault, it already handled
> page flush. So GUP's flush_dcache_page call is redundant.

Oh, I am not sure. Say, do_wp_page() can only clear !pte_write(),
but let me remind I do not understand this magic.

However, evem if this change is correct, I am not sure it can solve
the original problem. Debugger issues a lot of short reads, I don't
think follow_page() fails that often.

But this is only my guess.

> Cc: Hugh Dickins <hughd@google.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> ---
>  mm/memory.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index ebfeedf..9166f4b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1430,6 +1430,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		do {
>  			struct page *page;
>  			unsigned int foll_flags = gup_flags;
> +			bool dcache_flushed = false;
>
>  			/*
>  			 * If we have a pending SIGKILL, don't keep faulting
> @@ -1464,6 +1465,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  					tsk->maj_flt++;
>  				else
>  					tsk->min_flt++;
> +				dcache_flushed = true;
>
>  				/*
>  				 * The VM_FAULT_WRITE bit tells us that
> @@ -1489,7 +1491,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  				pages[i] = page;
>
>  				flush_anon_page(vma, page, start);
> -				flush_dcache_page(page);
> +				if (!dcache_flushed)
> +					flush_dcache_page(page);
>  			}
>  			if (vmas)
>  				vmas[i] = vma;
> --
> 1.7.0.4
>
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
