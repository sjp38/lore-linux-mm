Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 968616B006C
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 12:25:02 -0500 (EST)
Date: Fri, 11 Nov 2011 18:24:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mmap: fix loop when adjusting vma
Message-ID: <20111111172458.GC4479@redhat.com>
References: <CAJd=RBAhHS4txg-2tnJyER=GeT4X95z6COMzJvRhcwFgXu6oOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAhHS4txg-2tnJyER=GeT4X95z6COMzJvRhcwFgXu6oOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 08:53:23PM +0800, Hillf Danton wrote:
> --- a/mm/mmap.c	Fri Nov 11 20:35:46 2011
> +++ b/mm/mmap.c	Fri Nov 11 20:41:32 2011
> @@ -490,6 +490,7 @@ __vma_unlink(struct mm_struct *mm, struc
>  int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
>  {
> +	unsigned long saved_end = end;
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct vm_area_struct *next = vma->vm_next;
>  	struct vm_area_struct *importer = NULL;
> @@ -634,7 +635,14 @@ again:			remove_next = 1 + (end > next->
>  		 */
>  		if (remove_next == 2) {
>  			next = vma->vm_next;
> -			goto again;
> +			if (next) {
> +				/*
> +				 * we have more work, reload @end in case
> +				 * it is clobbered.
> +				 */
> +				end = saved_end;
> +				goto again;
> +			}
>  		}

Doesn't matter if it's clobbered, remove_next will be set to 1 and
that's all we care about. Caller should use vma->vm_next->vm_end as
"end" anyway for case 6 so it wouldn't be set to 2. Also next can't be
NULL if remove_next == 2. So I don't think this is necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
