Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id DBEE56B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 21:33:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6425194pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 18:33:22 -0700 (PDT)
Date: Fri, 29 Jun 2012 18:33:18 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH -mm v2 05/11] mm: get unmapped area from VMA tree
Message-ID: <20120630013318.GB27797@google.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
 <1340315835-28571-6-git-send-email-riel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340315835-28571-6-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, Jun 21, 2012 at 05:57:09PM -0400, Rik van Riel wrote:
> +			if (!vma->vm_prev) {
> +				/* This is the left-most VMA. */
> +				if (vma->vm_start - len >= lower_limit) {
> +					addr = lower_limit;
> +					goto found_addr;
> +				}
> +			} else {
> +				/* Is this gap large enough? Remember it. */
> +				vma_start = max(vma->vm_prev->vm_end, lower_limit);
> +				if (vma->vm_start - len >= vma_start) {
> +					addr = vma_start;
> +					found_here = true;
> +				}
> +			}

You could unify these two cases:

			vma_start = lower_limit;
			if (vma->vm_prev && vma->vm_prev->vm_end > vma_start)
				vma_start = vma->vm_prev->vm_end;
			if (vma->vm_start - len >= vma_start) {
				addr = vma_start;
				found_here = true;
			}

You don't need the goto found_addr; the search won't be going left as there
is no node there and it won't be going right as found_here is true.

We may also be albe to dispense with found_here and replace it with a special
value (either NULL or something not page aligned) for addr.

> +		if (!found_here && node_free_gap(rb_node->rb_right) >= len) {
> +			/* Last known gap is to the right of this subtree. */
> +			rb_node = rb_node->rb_right;
> +			continue;
> +		} else if (!addr) {
> +			rb_node = rb_find_next_uncle(rb_node);
> +			continue;
>  		}

Looks like you're already using my suggestion of using !addr to indicate
we haven't found a suitable gap yet :)

I don't think we want to visit just any uncle though - we want to visit one
that has a large enough free gap somewhere in its subtree.

So, maybe:

		if (!found_here) {	// or if(!addr) or whatever
			struct rb_node *rb_prev = NULL;
			do {
				if (rb_node != rb_prev &&
				    node_free_gap(rb_node->rb_right) >= len) {
					rb_node = rb_node->rb_right;
					break;
				}
				rb_prev = rb_node;
				rb_node = rb_parent(rb_node);
			} while (rb_node);
			continue;
		}

> +		/* This is the left-most gap. */
> +		goto found_addr;
>  	}
> +
> +	/*
> +	 * There is not enough space to the left of any VMA.
> +	 * Check the far right-hand side of the VMA tree.
> +	 */
> +	rb_node = mm->mm_rb.rb_node;
> +	while (rb_node->rb_right)
> +		rb_node = rb_node->rb_right;
> +	vma = rb_to_vma(rb_node);
> +	addr = vma->vm_end;
> +
> +	/*
> +	 * The right-most VMA ends below the lower limit. Can only happen
> +	 * if a binary personality loads the stack below the executable.
> +	 */
> +	if (addr < lower_limit)
> +		addr = lower_limit;
> +
> + found_addr:
> +	if (TASK_SIZE - len < addr)
> +		return -ENOMEM;

I'm confused - if we come from 'goto found_addr', we found a gap to the
left of an existing vma; aren't we guaranteed that this gap ends to the
left of TASK_SIZE too since the existing vma's vm_begin should be
less than TASK_SIZE ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
