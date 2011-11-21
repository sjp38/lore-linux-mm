Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB386B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 23:16:21 -0500 (EST)
Received: by iaek3 with SMTP id k3so8990220iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 20:16:17 -0800 (PST)
Date: Sun, 20 Nov 2011 20:16:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
In-Reply-To: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1111201923330.1806@sister.anvils>
References: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Sat, 19 Nov 2011, Hillf Danton wrote:

> The flag, FAULT_FLAG_ALLOW_RETRY, was introduced by the patch,
> 
> 	mm: retry page fault when blocking on disk transfer
> 	commit: d065bd810b6deb67d4897a14bfe21f8eb526ba99
> 
> for reducing mmap_sem hold times that are caused by waiting for disk
> transfers when accessing file mapped VMAs.
> 
> To break COW, handle_mm_fault() is repeated with mmap_sem held, where
> the introduced flag could be used again.
> 
> The straight way is to add changes in break_ksm(), but the function could be
> under write-mode mmap_sem, so it has to be dupilcated.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Thank you for making the patch; but unless I'm mistaken - please
correct me if so - I think it's better to keep break_cow() simple
than add special FAULT_FLAG_ALLOW_RETRY handling there.  Do you
have any evidence that its down_read of mmap_sem is a problem in
some workload?  I sense that you're using it "because it's there".

I'm sceptical on several grounds.

One, break_cow() is itself only called on an "error" path: not
really an error, but when KSM's bet that it can merge pages turns
out to be wrong before it can complete the merge; not a rare case,
but not on the hot path.

Two, break_ksm()'s loop is required for correctness, but it
is a rare case that it actually needs to go round a second time.
The typical case it's needed (am I forgetting a more common one?)
is when userspace access flips a pte bit in between handle_pte_fault()
noting faulting pte, and the chosen fault handler checking pte_same()
before committing to its action.  With the page marked PageKsm, yet
not in the stable tree, even page reclaim is unable to interfere.

Three, FAULT_FLAG_ALLOW_RETRY is acted upon only in lock_page_or_retry(),
which is called only from filemap_fault() (not the case here since we
don't consider file pages for conversion to PageKsm) or do_swap_page();
yet the fault we're provoking would be handled by do_wp_page().

Four, lock_page_or_retry() is called in those places when there's a
possibility that the page is being read in from disk, to drop the
mmap_sem across the slow I/O.  There is no precedent for dropping
mmap_sem here while allocating a new page, nor when pte_same() fails:
in the former case it could only be a win when the system is already
slowed by memory pressure, in the latter case there's little point,
since mmap_sem would be reacquired in a moment.

I think that amounts to a genial Nack!

Hugh

> ---
> 
> --- a/mm/ksm.c	Sat Nov 19 16:08:10 2011
> +++ b/mm/ksm.c	Sat Nov 19 19:33:49 2011
> @@ -394,7 +394,31 @@ static void break_cow(struct rmap_item *
>  		goto out;
>  	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
>  		goto out;
> -	break_ksm(vma, addr);
> +	for (;;) {
> +		struct page *page;
> +		int ret;
> +
> +		page = follow_page(vma, addr, FOLL_GET);
> +		if (IS_ERR_OR_NULL(page))
> +			break;
> +
> +		if (PageKsm(page))
> +			ret = handle_mm_fault(mm, vma, addr,
> +				FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_WRITE);
> +		else
> +			ret = VM_FAULT_WRITE;
> +
> +		put_page(page);
> +
> +		if (!(ret & (VM_FAULT_WRITE|VM_FAULT_SIGBUS|VM_FAULT_OOM))) {
> +			if (ret & VM_FAULT_RETRY)
> +				down_read(&mm->mmap_sem);
> +		} else {
> +			if (ret & VM_FAULT_RETRY)
> +				return;
> +			break;
> +		}
> +	}
>  out:
>  	up_read(&mm->mmap_sem);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
