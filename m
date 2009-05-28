Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 172986B005C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 21:06:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S16ZIx001522
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 10:06:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC59C45DD81
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:06:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85E1E45DD7F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:06:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 587F11DB803F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:06:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01BAB1DB8038
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:06:35 +0900 (JST)
Date: Thu, 28 May 2009 10:05:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090528100501.ab26953f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090528094157.5c39ac57.nishimura@mxp.nes.nec.co.jp>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528094157.5c39ac57.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009 09:41:57 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -1969,17 +2017,33 @@ int swap_duplicate(swp_entry_t entry)
> >  	offset = swp_offset(entry);
> >  
> >  	spin_lock(&swap_lock);
> > -	if (offset < p->max && p->swap_map[offset]) {
> > -		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
> > -			p->swap_map[offset]++;
> > +
> > +	if (unlikely(offset >= p->max))
> > +		goto unlock_out;
> > +
> > +	count = swap_count(p->swap_map[offset]);
> > +	has_cache = swap_has_cache(p->swap_map[offset]);
> > +	if (cache) {
> > +		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
> > +		if (!has_cache && count) {
> Should we check !has_cache here ?
I added !has_cache to return 0 in racy case.

> 
> Concurrent read_swap_cache_async() might have set SWAP_HAS_CACHE, but not have added
> a page to swap cache yet when find_get_page() was called.
yes.

> add_to_swap_cache() would handle the race of concurrent read_swap_cache_async(),
> but considering more, swapcache_free() at the end of the loop might dangerous in this case...

I can't catch what you mean.

I think swapcache_prepare() returns 0 in racy case and no add_to_swap_cache() happens.
wrong ?

> So I think it should be like:
> 
> 	read_swap_cache_async()
> 		:
> 		valid = swapcache_prepare(entry);
> 		if (!valid)
> 			break;
> 		if (valid == -EAGAIN);
> 			continue;
> 
> to let the context that succeeded in swapcache_prepare() do add_to_swap_cache().
> 

What you reccomend is code like this ?

==
	ret = swapcache_prapare(entry);
	if (ret == -ENOENT)
		break;    /* unused swap entry */
	if (ret == -EBUSY)
		continue; /* to call find_get_page() again */
==

-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
