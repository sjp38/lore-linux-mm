Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4F95F6B0055
	for <linux-mm@kvack.org>; Wed, 27 May 2009 21:41:12 -0400 (EDT)
Date: Thu, 28 May 2009 10:40:13 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090528104013.e410235e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090528100501.ab26953f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528094157.5c39ac57.nishimura@mxp.nes.nec.co.jp>
	<20090528100501.ab26953f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009 10:05:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 28 May 2009 09:41:57 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > @@ -1969,17 +2017,33 @@ int swap_duplicate(swp_entry_t entry)
> > >  	offset = swp_offset(entry);
> > >  
> > >  	spin_lock(&swap_lock);
> > > -	if (offset < p->max && p->swap_map[offset]) {
> > > -		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
> > > -			p->swap_map[offset]++;
> > > +
> > > +	if (unlikely(offset >= p->max))
> > > +		goto unlock_out;
> > > +
> > > +	count = swap_count(p->swap_map[offset]);
> > > +	has_cache = swap_has_cache(p->swap_map[offset]);
> > > +	if (cache) {
> > > +		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
> > > +		if (!has_cache && count) {
> > Should we check !has_cache here ?
> I added !has_cache to return 0 in racy case.
> 
> > 
> > Concurrent read_swap_cache_async() might have set SWAP_HAS_CACHE, but not have added
> > a page to swap cache yet when find_get_page() was called.
> yes.
> 
> > add_to_swap_cache() would handle the race of concurrent read_swap_cache_async(),
> > but considering more, swapcache_free() at the end of the loop might dangerous in this case...
> 
> I can't catch what you mean.
> 
> I think swapcache_prepare() returns 0 in racy case and no add_to_swap_cache() happens.
> wrong ?
> 
Ah, you're right in this version of your patch.
I said the case if we changed swapcache_prepare() simply not to return 0 in
SWAP_HAS_CACHE case.

> > So I think it should be like:
> > 
> > 	read_swap_cache_async()
> > 		:
> > 		valid = swapcache_prepare(entry);
> > 		if (!valid)
> > 			break;
> > 		if (valid == -EAGAIN);
> > 			continue;
> > 
> > to let the context that succeeded in swapcache_prepare() do add_to_swap_cache().
> > 
> 
> What you reccomend is code like this ?
> 
> ==
> 	ret = swapcache_prapare(entry);
> 	if (ret == -ENOENT)
> 		break;    /* unused swap entry */
> 	if (ret == -EBUSY)
> 		continue; /* to call find_get_page() again */
> ==
> 
Yes.
By current version of your patch, read_swap_cache_async() might return NULL
if concurrent read_swap_cache_async() exists. It is different from current behavior.
And this means swapin_readahead() might fail(it calls read_swap_cache_async()
twice, though) and can cause oom, right ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
