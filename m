Date: Thu, 21 Oct 2004 14:45:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-Id: <20041021144531.22dd0d54.akpm@osdl.org>
In-Reply-To: <1098393346.7157.112.camel@localhost>
References: <1098393346.7157.112.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Cc: andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Kleikamp <shaggy@austin.ibm.com> wrote:
>
> Doing O_DIRECT writes to an mmapped file caused pages in the page cache to
> be marked dirty but not uptodate.  This led to a bug in mpage_writepage.
> 

Methinks this merely reduces the probability of the BUG.

> diff -urp linux-2.6.9/mm/memory.c linux/mm/memory.c
> --- linux-2.6.9/mm/memory.c	2004-10-21 10:49:26.598031488 -0500
> +++ linux/mm/memory.c	2004-10-21 16:01:44.902376232 -0500
> @@ -414,7 +414,15 @@ static void zap_pte_range(struct mmu_gat
>  			    && linear_page_index(details->nonlinear_vma,
>  					address+offset) != page->index)
>  				set_pte(ptep, pgoff_to_pte(page->index));
> -			if (pte_dirty(pte))
> +			/*
> +			 * PG_uptodate can be cleared by
> +			 * invalidate_inode_pages2, so we must not try to write
> +			 * not uptodate pages.  Otherwise we risk invalidating
> +			 * underlying O_DIRECT writes, and secondly because
> +			 * pdflush would BUG().  Coherency of mmaps against
> +			 * O_DIRECT still cannot be guaranteed though.
> +			 */
> +			if (pte_dirty(pte) && PageUptodate(page))

	invalidate_inode_pages2 runs ClearPageUptodate() here

>  				set_page_dirty(page);
>  			if (pte_young(pte) && !PageAnon(page))
>  				mark_page_accessed(page);

Maybe we should revisit invalidate_inode_pages2().  It used to be an
invariant that "pages which are mapped into process address space are
always uptodate".  We broke that (good) invariant and we're now seeing
some fallout.  There may be more.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
