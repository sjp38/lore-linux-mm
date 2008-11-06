Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA675Hu9029479
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 16:05:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEAD12AEA81
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:05:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B703F1EF081
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:05:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A39131DB803F
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:05:16 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 573F41DB803C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:05:16 +0900 (JST)
Date: Thu, 6 Nov 2008 16:03:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/6] memcg updates (05/Nov)
Message-Id: <20081106160313.995eefbc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49129493.9070103@linux.vnet.ibm.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<49129493.9070103@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Nov 2008 12:24:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Weekly (RFC) update for memcg.
> > 
> > This set includes
> > 
> > 1. change force_empty to do move account rather than forget all
> 
> I would like this to be selectable, please. We don't want to break behaviour and
> not everyone would like to pay the cost of movement.
> 
Just current behavior is broken ;)

Hmm. I have an option in my stack to do
 - call try_to_free_pages() only. or
 - call try_to_free_pages(). only when memory is locked, move to parent.

Ok ? *forget all* is no choice.

Thanks,
-Kame

> > 2. swap cache handling
> > 3. mem+swap controller kconfig
> > 4. swap_cgroup for rememver swap account information
> > 5. mem+swap controller core
> > 6. synchronize memcg's LRU and global LRU.
> > 
> > "1" is already sent, "6" is a newcomer.
> > I'd like to push out "2" or "2-5" in the next week (if no bugs.)
> > 
> > after 6, next candidates are
> >   - dirty_ratio handler
> >   - account move at task move.
> > 
> > Some more explanation about purpose of "6". (see details in patch itself)
> > Now, one of complicated logic in memcg is LRU handling. Because the place of
> > lru_head depends on page_cgroup->mem_cgroup pointer, we have to take
> > lock as following even under zone->lru_lock.
> > ==
> >   pc = lookup_page_cgroup(page);
> >   if (!trylock_page_cgroup(pc))
> >   	return -EBUSY;
> > 
> >    if (PageCgroupUsed(pc)) {
> > 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> > 	spin_lock_irqsave(&mz->lru_lock, flags);
> > 	....some operation on LRU.
> > 	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >    }
> >    unlock_page_cgroup(pc);
> > ==
> > Sigh..
> > 
> > After "6", page_cgroup's LRU management can be done independently to some extent.
> > == as
> >   (zone->lru_lock is held here)
> >   pc = lookup_page_cgroup(page);
> >   list operation on pc.
> >   (unlock zone->lru_lock)
> > ==
> > Maybe good for maintainance and as a bonus, we can make use of isolate_lru_page() when
> > doing some racy operation.
> > 
> > 	isolate_lru_page(page);
> > 	pc = lookup_page_cgroup(page);
> > 	do some jobs.
> > 	putback_lru_page(page);
> > 
> > Maybe this will be a help to implement "account move at task move".
> 
> Sounds promising!
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
