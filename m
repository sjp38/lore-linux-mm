Date: Wed, 22 Sep 2004 14:52:39 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: OOM killer being triggered too soon
Message-ID: <20040922175239.GG8197@logos.cnet>
References: <20040922172406.GD8197@logos.cnet> <Pine.LNX.4.44.0409222006230.23879-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0409222006230.23879-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, Barry Silverman <barry@disus.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 22, 2004 at 08:10:19PM +0100, Hugh Dickins wrote:
> Hi Marcelo,
> 
> On Wed, 22 Sep 2004, Marcelo Tosatti wrote:
> > 
> > While investigating it I found out that, at refill_inactive_zone, we dont 
> > move mapped anon, swapcache pages to the inactive list if nr_swap_pages is zero.
> 
> I don't see a need for that patch.  It's testing "total_swap_pages == 0"
> not "nr_swap_pages == 0", so unless you're anxious about what happens
> during swapoff, there won't be any PageSwapCache pages at all.

Oh right, I misundertood "total_swap_pages" with "nr_swap_pages".

Thanks!

> Hugh
> 
> > We should move them because they already have allocated on-swap address.
> > 
> > Andrew, please apply.
> > 
> > --- linux-2.6.9-rc1-mm5/mm/vmscan.c.orig	2004-09-22 15:25:31.800412784 -0300
> > +++ linux-2.6.9-rc1-mm5/mm/vmscan.c	2004-09-22 15:25:34.618984296 -0300
> > @@ -722,7 +722,8 @@
> >  		list_del(&page->lru);
> >  		if (page_mapped(page)) {
> >  			if (!reclaim_mapped ||
> > -			    (total_swap_pages == 0 && PageAnon(page)) ||
> > +			    (total_swap_pages == 0 && PageAnon(page) && 
> > +				!PageSwapCache(page)) ||
> >  			    page_referenced(page, 0)) {
> >  				list_add(&page->lru, &l_active);
> >  				continue;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
