From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: avoid dirtying shared mappings on mlock
Date: Fri, 12 Oct 2007 02:57:05 +1000
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org> <69AF9B2A-6AA7-4078-B0A2-BE3D4914AEDC@FreeBSD.org> <1192179805.27435.6.camel@twins>
In-Reply-To: <1192179805.27435.6.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710120257.05960.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Friday 12 October 2007 19:03, Peter Zijlstra wrote:
> Subject: mm: avoid dirtying shared mappings on mlock
>
> Suleiman noticed that shared mappings get dirtied when mlocked.
> Avoid this by teaching make_pages_present about this case.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Suleiman Souhlal <suleiman@google.com>

Umm, I don't see the other piece of this thread, so I don't
know what the actual problem was.

But I would really rather not do this. If you do this, then you
now can get random SIGBUSes when you write into the memory if it
can't allocate blocks or ... (some other filesystem specific
condition).

I agree it feels suboptimal, but we've _always_ done this, right?
Is it suddenly a problem? Unless a really nice general way is
made to solve this, optimising it like this makes it harder to
ensure good semantics for all corner cases I think (and then once
the optimisation is in place, it's a lot harder to remove it).

I'll go away and have a better look for the old thread.

> ---
>  mm/memory.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -2719,7 +2719,12 @@ int make_pages_present(unsigned long add
>  	vma = find_vma(current->mm, addr);
>  	if (!vma)
>  		return -1;
> -	write = (vma->vm_flags & VM_WRITE) != 0;
> +	/*
> +	 * We want to touch writable mappings with a write fault in order
> +	 * to break COW, except for shared mappings because these don't COW
> +	 * and we would not want to dirty them for nothing.
> +	 */
> +	write = (vma->vm_flags & (VM_WRITE|VM_SHARED)) == VM_WRITE;
>  	BUG_ON(addr >= end);
>  	BUG_ON(end > vma->vm_end);
>  	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
