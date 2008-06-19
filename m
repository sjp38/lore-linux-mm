From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only pte and _count=2?
Date: Thu, 19 Jun 2008 13:31:31 +1000
References: <20080618164158.GC10062@sgi.com> <20080618203300.GA10123@sgi.com> <Pine.LNX.4.64.0806182209320.16252@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0806182209320.16252@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806191331.32056.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 19 June 2008 07:46, Hugh Dickins wrote:

> contain COWs - I used to rail against it for that reason, but in the
> end did an audit and couldn't find any place where that violation of
> our assumptions actually mattered enough to get so excited.

Still, they're slightly troublesome, as our get_user_pages problems
demonstrate :)

>
> Hugh
>
> --- 2.6.26-rc6/mm/memory.c	2008-05-26 20:00:39.000000000 +0100
> +++ linux/mm/memory.c	2008-06-18 22:06:46.000000000 +0100
> @@ -1152,9 +1152,15 @@ int get_user_pages(struct task_struct *t
>  				 * do_wp_page has broken COW when necessary,
>  				 * even if maybe_mkwrite decided not to set
>  				 * pte_write. We can thus safely do subsequent
> -				 * page lookups as if they were reads.
> +				 * page lookups as if they were reads. But only
> +				 * do so when looping for pte_write is futile:
> +				 * in some cases userspace may also be wanting
> +				 * to write to the gotten user page, which a
> +				 * read fault here might prevent (a readonly
> +				 * page would get reCOWed by userspace write).
>  				 */
> -				if (ret & VM_FAULT_WRITE)
> +				if ((ret & VM_FAULT_WRITE) &&
> +				    !(vma->vm_flags & VM_WRITE))
>  					foll_flags &= ~FOLL_WRITE;
>
>  				cond_resched();

Hmm, doesn't this give the same problem for !VM_WRITE vmas? If you
called get_user_pages again, isn't that going to cause another COW
on the already-COWed page that we're hoping to write into? (not sure
about mprotect either, could that be used to make the vma writeable
afterwards and then write to it?)

I would rather (if my reading of the code is correct) make the
trylock page into a full lock_page. The indeterminism of the trylock
has always bugged me anyway... Shouldn't that cause a swap page not
to get reCOWed if we have the only mapping to it?

If the lock_page cost bothers you, we could do a quick unlocked check
on page_mapcount > 1 before taking the lock (which would also avoid
the extra atomic ops and barriers in many cases where the page really
is shared)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
