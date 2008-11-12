Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC4NCJi004538
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 13:23:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 567342AEA83
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:23:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F83D1EF08A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:23:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 08EE81DB8042
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:22:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 345E01DB8050
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:22:57 +0900 (JST)
Date: Wed, 12 Nov 2008 13:22:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/6] memcg: swap cgroup for remembering account
Message-Id: <20081112132219.20510b57.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112131701.dbb7d003.d-nishimura@mtf.biglobe.ne.jp>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122949.d17bbc7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112131701.dbb7d003.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 13:17:01 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> > +/**
> > + * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
> > + * @ent: swap entry to be looked up.
> > + *
> > + * Returns pointer to mem_cgroup at success. NULL at failure.
> > + */
> > +struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> > +{
> > +	int type = swp_type(ent);
> > +	unsigned long flags;
> > +	unsigned long offset = swp_offset(ent);
> > +	unsigned long idx = offset / SC_PER_PAGE;
> > +	unsigned long pos = offset & SC_POS_MASK;
> > +	struct swap_cgroup_ctrl *ctrl;
> > +	struct page *mappage;
> > +	struct swap_cgroup *sc;
> > +	struct mem_cgroup *ret;
> > +
> > +	if (!do_swap_account)
> > +		return NULL;
> > +
> > +	ctrl = &swap_cgroup_ctrl[type];
> > +
> > +	mappage = ctrl->map[idx];
> > +
> > +	spin_lock_irqsave(&ctrl->lock, flags);
> > +	sc = kmap_atomic(mappage, KM_USER0);
> > +	sc += pos;
> > +	ret = sc->val;
> > +	kunmap_atomic(mapppage, KM_USER0);
> s/mapppage/mappage
> 
> I don't know why I didn't notice this while testing previous version.
> 
Ah...kmap_atomic() doesn't check its argument if HIGHMEM=n.
and mapppage disappears by macro.

I'm now preparing x86-32 test enviroment before goint further.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 
> > +	spin_unlock_irqrestore(&ctrl->lock, flags);
> > +	return ret;
> > +}
> > +
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
