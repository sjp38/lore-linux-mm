Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AA6C86B0092
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 03:40:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R7f4II001506
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 16:41:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6170C45DD7B
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:41:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B98145DD75
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:41:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2090CE08004
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:41:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC87CE18005
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:41:03 +0900 (JST)
Date: Mon, 27 Apr 2009 16:39:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for memg v3.
Message-Id: <20090427163930.50604bf9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090426010658.c0fa3258.d-nishimura@mtf.biglobe.ne.jp>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
	<20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090425215459.5cab7285.d-nishimura@mtf.biglobe.ne.jp>
	<20090426010658.c0fa3258.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sun, 26 Apr 2009 01:06:58 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> A few minor nitpicks :)
> 
> > > +static void memcg_fixup_stale_swapcache(struct work_struct *work)
> > > +{
> > > +	int pos = 0;
> > > +	swp_entry_t entry;
> > > +	struct page *page;
> > > +	int forget, ret;
> > > +
> > > +	while (ssc.num) {
> > > +		spin_lock(&ssc.lock);
> > > +		pos = find_next_bit(ssc.usemap, STALE_ENTS, pos);
> > > +		spin_unlock(&ssc.lock);
> > > +
> > > +		if (pos >= STALE_ENTS)
> > > +			break;
> > > +
> > > +		entry = ssc.ents[pos];
> > > +
> > > +		forget = 1;
> > > +		page = lookup_swap_cache(entry);
> I think using find_get_page() would be better.
> lookup_swap_cache() update swapcache_info.
> 

ok, and I have to add put_page() somewhere.

> > > +		if (page) {
> > > +			lock_page(page);
> > > +			ret = try_to_free_swap(page);
> > > +			/* If it's still under I/O, don't forget it */
> > > +			if (!ret && PageWriteback(page))
> > > +				forget = 0;
> > > +			unlock_page(page);
> > I think we need page_cache_release().
> > lookup_swap_cache() gets the page.
> > 
> > > +		}
> > > +		if (forget) {
> > > +			spin_lock(&ssc.lock);
> > > +			clear_bit(pos, ssc.usemap);
> > > +			ssc.num--;
> > > +			if (ssc.num < STALE_ENTS/2)
> > > +				ssc.congestion = 0;
> > > +			spin_unlock(&ssc.lock);
> > > +		}
> > > +		pos++;
> > > +	}
> > > +	if (ssc.num) /* schedule me again */
> > > +		schedule_delayed_work(&ssc.gc_work, HZ/10);
> We can use schedule_ssc_gc() here.
> (It should be defined before this, of course. And can be inlined.)
> 
Sure.

will soon post v2. (removing RFC)

Thanks,
-Kame
> > "if (ssc.congestion)" would be better ?
> > 
> > > +	return;
> > > +}
> > > +
> > 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
