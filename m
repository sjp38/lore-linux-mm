Date: Mon, 27 Aug 2007 13:13:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
In-Reply-To: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.orgAndrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007, akpm@linux-foundation.org wrote:

> See http://bugzilla.kernel.org/show_bug.cgi?id=8928
> 
> I think it makes sense to permit a non-BUGging get_zeroed_page(GFP_ATOMIC)
> from interrupt context.

AFAIK this works now. GFP_ATOMIC does not set __GFP_HIGHMEM and thus the 
check

	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());

does not trigger

Any use of get_zeroed_page(  | __GFP_HIGHMEM) will cause a bug in

fastcall unsigned long get_zeroed_page(gfp_t gfp_mask)
{
        struct page * page;

        /*
         * get_zeroed_page() returns a 32-bit address, which cannot represent
         * a highmem page
         */
        VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);

        page = alloc_pages(gfp_mask | __GFP_ZERO, 0);
        if (page)
                return (unsigned long) page_address(page);
        return 0;
}


And the patch does not change anything. We currently BUG_ON(GFP_HIGHMEM && 
in_interrupt) and after this patch we will still BUG(). The check was 
reordered but checks the same things. We could clear __GFP_HIGHMEM in 
__alloc_pages() if we are in an interrupt?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
