Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D3EF96B003D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 19:11:51 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1O0Bn0Z015116
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Feb 2009 09:11:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4F345DD77
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 09:11:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 893E645DD72
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 09:11:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AB601DB8040
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 09:11:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A39E08002
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 09:11:48 +0900 (JST)
Date: Tue, 24 Feb 2009 09:10:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID v2
Message-Id: <20090224091034.02c37682.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090223145828.d14ff015.nishimura@mxp.nes.nec.co.jp>
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090209145557.d0754a9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090223145828.d14ff015.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Feb 2009 14:58:28 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I'm sorry for my late reply.
> 
> It looks good basically, but I have 1 comment.
> 
> >  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  {
> > -	struct mem_cgroup *mem;
> > +	unsigned short id;
> > +	struct mem_cgroup *mem = NULL;
> >  	swp_entry_t ent;
> >  
> >  	if (!PageSwapCache(page))
> >  		return NULL;
> >  
> >  	ent.val = page_private(page);
> > -	mem = lookup_swap_cgroup(ent);
> > -	if (!mem)
> > -		return NULL;
> > +	id = lookup_swap_cgroup(ent);
> > +	rcu_read_lock();
> > +	mem = mem_cgroup_lookup(id);
> >  	if (!css_tryget(&mem->css))
> We should check whether "mem" is NULL or not before css_tryget, because
> "mem" can be NULL(or "id" can be 0) if the page is on swapcache,
> that is, remove_from_swap_cache has not been called yet.
> 
> Actually, I got NULL pointer dereference bug here.
> 
Okay, will fix.

Thanks,
-kame


> > -		return NULL;
> > +		mem = NULL;
> > +	rcu_read_unlock();
> >  	return mem;
> >  }
> >  
> 
> 
> Thanks,
> Daisuke Nishimura.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
