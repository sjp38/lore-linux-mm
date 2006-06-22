Date: Thu, 22 Jun 2006 18:21:27 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 4/6] mm: optimize the new mprotect() code a bit
In-Reply-To: <20060619175326.24655.90153.sendpatchset@lappy>
Message-ID: <Pine.LNX.4.64.0606221811170.4977@blonde.wat.veritas.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175326.24655.90153.sendpatchset@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Peter Zijlstra wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> mprotect() resets the page protections, which could result in extra write
> faults for those pages whos dirty state we track using write faults
> and are dirty already.
> 
> @@ -43,7 +44,13 @@ static void change_pte_range(struct mm_s
>  			 * bits by wiping the pte and then setting the new pte
>  			 * into place.
>  			 */
> -			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
> +			ptent = ptep_get_and_clear(mm, addr, pte);
> +			ptent = pte_modify(ptent, newprot);
> +			/* Avoid taking write faults for pages we know to be
> +			 * dirty.
> +			 */
> +			if (is_accountable && pte_dirty(ptent))
> +				ptent = pte_mkwrite(ptent);
>  			set_pte_at(mm, addr, pte, ptent);
>  			lazy_mmu_prot_update(ptent);

Thanks for adding that comment, I completely misread this when you
first showed it to me, and didn't get the point at all.  (But you're
a little too fond of "/* Multiline" comments: in this case, with no
blank line above, it'd look better with a "/*" lone line to separate
from the pte_modify code.)

Yes, I guess that is worth doing, though it's a bit sad and ugly:
goes right against the simplicity of working with vm_page_prot.

Could you change "is_accountable" to "dirty_accountable" throughout?
We've various different kinds of accounting going on hereabouts,
I think it'd be more understandable as "dirty_accountable".

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
