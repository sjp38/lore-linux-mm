Date: Fri, 1 Dec 2006 11:01:03 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
Message-Id: <20061201110103.08d0cf3d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>
References: <20061130170746.GA11363@skynet.ie>
	<20061130173129.4ebccaa2.akpm@osdl.org>
	<Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006 09:54:11 +0000 (GMT)
Mel Gorman <mel@csn.ul.ie> wrote:

> >> @@ -65,7 +65,7 @@ static inline void clear_user_highpage(s
> >>  static inline struct page *
> >>  alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
> >>  {
> >> -	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
> >> +	struct page *page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, vaddr);
> >>
> >>  	if (page)
> >>  		clear_user_highpage(page, vaddr);
> >
> > But this change is presumptuous.  alloc_zeroed_user_highpage() doesn't know
> > that its caller is going to use the page for moveable purposes.  (Ditto lots
> > of other places in this patch).
> >
> 
> according to grep -r, alloc_zeroed_user_highpage() is only used in two 
> places, do_wp_page() (when write faulting the zero page)[1] and 
> do_anonymous_page() (when mapping the zero page for the first time and 
> writing). In these cases, they are known to be movable. What am I missing?

We shouldn't implement a function which "knows" how its callers are using
it in this manner.

You've gone and changed alloc_zeroed_user_highpage() into alloc_user_zeroed_highpage_which_you_must_use_in_an_application_where_it_is_movable().
Now, if we want to put a big fat comment over these functions saying that the caller
must honour the promise we've made on the caller's behalf then OK(ish).  But it'd
be better (albeit perhaps bloaty) to require the caller to pass in the gfp-flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
