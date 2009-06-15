Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C09DC6B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:03:45 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5F33nvM001165
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Jun 2009 12:03:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 65A4A45DE7D
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:03:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6419345DE7C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:03:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C67F2E08009
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:03:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8481CE0800A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:03:45 +0900 (JST)
Date: Mon, 15 Jun 2009 12:02:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 11:50:21 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:


> > Then, my suggestion is here.
> > ==
> > } else {
> > 	ent.val = page_private(page);
> > 	id = lookup_swap_cgroup(ent);
> > 	rcu_read_lock();
> > 	mem = mem_cgroup_lookup(id);
> > 	if (mem) {
> > 		if (css_tryget(mem->css)) {
> > 			/*
> > 			 * If no processes in this cgroup, accounting back to
> > 			 * this cgroup seems silly and prevents RMDIR.
> > 			 */
> > 			struct cgroup *cg = mem->css.cgroup;
> > 			if (!atomic_read(&cg->count) && list_empty(&cg->children)) {
> > 				css_put(&mem->css);
> > 				mem = NULL;
> > 			}
> > 	}
> > 	rcu_read_unlock();
> >  }
> > ==
> > 
> Thank you for your suggestion.
> To be honest, I think swap cache behavior would be complicated anyway :(
> 
> I prefer my change because the behavior would become consistent with
> the case we don't use mem+swap controller and with the behavior of page cache.
> 
I don't like implict resource move. I'll try some today. plz see it.
_But_ this case just happens when swap is shared between cgroups and _very_ heavy
swap-in continues very long. I don't think this is a fatal and BUG.

But ok, maybe wake-up path is not enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
