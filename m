Message-ID: <3D2B7DF7.9528F0@zip.com.au>
Date: Tue, 09 Jul 2002 17:21:11 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take two
References: <59590000.1026241454@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> Here's a version of my pte_chain removal patch that does not use anonymous
> unions, so it'll compile with gcc 2.95.  Once again, it's based on Rik's
> rmap-2.5.25-akpmtested.

Seems sane and simple, thanks.

This bit is icky:

+       union {
+               struct pte_chain * _pte_chain;  /* Reverse pte mapping pointer.
                                         * protected by PG_chainlock */
+               pte_t            * _pte_direct;
+       } _pte_union;
...
+
+#define        pte__chain      _pte_union._pte_chain
+#define        pte_direct      _pte_union._pte_direct


You could instead make it just a void * and have:

static inline struct pte_chain *page_pte_chain(struct page *page)
{
#ifdef DEBUG_RMAP
	BUG_ON(PageDirect(page));
#endif
	return page->rmap_thingy;
}

static inline pte_t *page_pte_direct(struct page *page)
{
#ifdef DEBUG_RMAP
	BUG_ON(!PageDirect(page));
#endif
	return page->rmap_thingy;
}

static inline void
set_page_pte_chain(struct page *page, struct pte_chain *pte_chain)
{
#ifdef DEBUG_RMAP
	BUG_ON(PageDirect(page));
#endif
	page->rmap_thingy = pte_chain;
}

static inline void
set_page_pte_direct(struct page *page, pte_t *ptep)
{
#ifdef DEBUG_RMAP
	BUG_ON(!PageDirect(page));
#endif
	page->rmap_thingy = ptep;
}

I think it's neater.  But then, I'm a convicted C++ weenie.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
