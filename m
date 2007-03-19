Date: Mon, 19 Mar 2007 05:46:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
Message-ID: <20070319124630.GK8915@holomorphy.com>
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45FE261F.3030903@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 04:56:47PM +1100, Nick Piggin wrote:
> Yes, I have the patch to do it quite easily. Per-node ZERO_PAGE could be
> another option, but that's going to cost another page flag if we wish to
> recognise the zero page in wp faults like we do now (hmm, for some reason
> it is OK to special case it _there_).

No need for a page flag. A per-node array of struct page * can be used
to check by merely indexing into it with the nid of the page's node. e.g.

struct page *get_zero_page(int nid, unsigned long addr)
{
	return zero_pages[nid][(addr & SOME_ARCHDEP_MASK) >> PAGE_SHIFT];
}

/* any time we fish one out of a pte we have a uvaddr */
int is_zero_page_addr(struct page *page, unsigned long address)
{
	return page == get_zero_page(page_to_nid(page), address);
}


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
