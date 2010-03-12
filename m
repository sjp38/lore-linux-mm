Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B6FC06B010D
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 21:28:19 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C2SHF9030464
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 11:28:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2259245DE55
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:28:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F00CF45DE4F
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:28:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A391DB801B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:28:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6276B1DB8012
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 11:28:16 +0900 (JST)
Date: Fri, 12 Mar 2010 11:24:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100312112433.689c7294.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100312101411.b2639128.nishimura@mxp.nes.nec.co.jp>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311184244.6735076a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312101411.b2639128.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 10:14:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 11 Mar 2010 18:42:44 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 11 Mar 2010 18:25:00 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > Then, it's not problem that check pc->mem_cgroup is root cgroup or not
> > > without spinlock.
> > > ==
> > > void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
> > > {
> > > 	pc = lookup_page_cgroup(page);
> > > 	if (unlikely(!pc) || mem_cgroup_is_root(pc->mem_cgroup))
> > > 		return;	
> > > 	...
> > > }
> > > ==
> > > This can be handle in the same logic of "lock failure" path.
> > > And we just do ignore accounting.
> > > 
> > > There are will be no spinlocks....to do more than this,
> > > I think we have to use "struct page" rather than "struct page_cgroup".
> > > 
> > Hmm..like this ? The bad point of this patch is that this will corrupt FILE_MAPPED
> > status in root cgroup. This kind of change is not very good.
> > So, one way is to use this kind of function only for new parameters. Hmm.
> IMHO, if we disable accounting file stats in root cgroup, it would be better
> not to show them in memory.stat to avoid confusing users.
agreed.

> But, hmm, I think accounting them in root cgroup isn't so meaningless.
> Isn't making mem_cgroup_has_dirty_limit() return false in case of root cgroup enough?
> 
The problem is spinlock overhead.

IMHO, there are 2 excuse for "not accounting" in root cgroup
 1. Low overhead is always appreciated.
 2. Root's statistics can be obtained by "total - sum of children".

And another thinking is that "how root cgroup is used when there are children ?"
What's benefit we have to place a task to "unlimited/no control" group even when
some important tasks are placed into children groups ?
I think administartors don't want to place tasks which they want to watch
into root cgroup because of lacks of accounting...

Yes, it's the best that root cgroup works as other children, but unfortunately we
know cgroup's accounting adds some burden.(and it's not avoidable.)

But there will be trade-off. If accounting is useful, it should be.
My concerns is the cost which we have to pay even when cgroup is _not_ mounted.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
