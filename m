Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 968AB6B004F
	for <linux-mm@kvack.org>; Wed, 27 May 2009 02:51:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R6qUFw004636
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 15:52:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DC3A45DD72
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:52:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 320F0266CC2
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:52:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B9BDE18009
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:52:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A0A6C1DB803E
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:52:28 +0900 (JST)
Date: Wed, 27 May 2009 15:50:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] (experimental) chase and free cache only swap
Message-Id: <20090527155055.2dcee5ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090527153024.bb275962.nishimura@mxp.nes.nec.co.jp>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
	<20090527141442.d191dc2d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090527153024.bb275962.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 15:30:24 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 27 May 2009 14:14:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 26 May 2009 12:18:34 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > This is a replacement for this. (just an idea, not testd.)
> > 
> > I think this works well. Does anyone has concerns ?
> I think so too, except some trivial build errors ;)
> 
Oh, will be fixed in the next post :(

> I'll test it, but it will take a long time to see the effect of this patch
> even if setting the swap space to reasonable size.
> 
Yes, Hot-to-test is my concern, too..

Thanks,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> > Do I have to modify swap-cluster code to do this in sane way ?
> > 
> > ---
> >  mm/swapfile.c |   40 ++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 40 insertions(+)
> > 
> > Index: new-trial-swapcount/mm/swapfile.c
> > ===================================================================
> > --- new-trial-swapcount.orig/mm/swapfile.c
> > +++ new-trial-swapcount/mm/swapfile.c
> > @@ -74,6 +74,26 @@ static inline unsigned short make_swap_c
> >  	return ret;
> >  }
> >  
> > +static int try_to_reuse_swap(struct swap_info_struct *si, unsigned long offset)
> > +{
> > +	int type = si - swap_info;
> > +	swp_entry_t entry = swp_entry(type, offset);
> > +	struct page *page;
> > +
> > +	page = find_get_page(page);
> > +	if (!page)
> > +		return 0;
> > +	if (!trylock_page(page)) {
> > +		page_cache_release(page);
> > +		return 0;
> > +	}
> > +	try_to_free_swap(page);
> > +	unlock_page(page);
> > +	page_cache_release(page);
> > +	return 1;
> > +}
> > +
> > +
> >  /*
> >   * We need this because the bdev->unplug_fn can sleep and we cannot
> >   * hold swap_lock while calling the unplug_fn. And swap_lock
> > @@ -295,6 +315,18 @@ checks:
> >  		goto no_page;
> >  	if (offset > si->highest_bit)
> >  		scan_base = offset = si->lowest_bit;
> > +
> > +	/* reuse swap entry of cache-only swap if not busy. */
> > +	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> > +		int ret;
> > +		spin_unlock(&swap_lock);
> > +		ret = try_to_reuse_swap(si, offset));
> > +		spin_lock(&swap_lock);
> > +		if (ret)
> > +			goto checks; /* we released swap_lock */
> > +		goto scan;
> > +	}
> > +
> >  	if (si->swap_map[offset])
> >  		goto scan;
> >  
> > @@ -378,6 +410,10 @@ scan:
> >  			spin_lock(&swap_lock);
> >  			goto checks;
> >  		}
> > +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> > +			spin_lock(&swap_lock);
> > +			goto checks;
> > +		}
> >  		if (unlikely(--latency_ration < 0)) {
> >  			cond_resched();
> >  			latency_ration = LATENCY_LIMIT;
> > @@ -389,6 +425,10 @@ scan:
> >  			spin_lock(&swap_lock);
> >  			goto checks;
> >  		}
> > +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> > +			spin_lock(&swap_lock);
> > +			goto checks;
> > +		}
> >  		if (unlikely(--latency_ration < 0)) {
> >  			cond_resched();
> >  			latency_ration = LATENCY_LIMIT;
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
