Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m996pXqB003234
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Oct 2008 15:51:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1949224004A
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:51:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C54BD2DC136
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:51:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD4781DB8037
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:51:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 59EA11DB803B
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:51:32 +0900 (JST)
Date: Thu, 9 Oct 2008 15:51:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] memcg: lazy lru addition
Message-Id: <20081009155116.ccf0833d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081009152132.df6e54c4.nishimura@mxp.nes.nec.co.jp>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001170119.80a617b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20081009152132.df6e54c4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Oct 2008 15:21:32 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 1 Oct 2008 17:01:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Delaying add_to_lru() and do it in batched manner like page_vec.
> > For doing that 2 flags PCG_USED and PCG_LRU.
> > 
> > Because __set_page_cgroup_lru() itself doesn't take lock_page_cgroup(),
> > we need a sanity check inside lru_lock().
> > 
> > And this delaying make css_put()/get() complicated. 
> > To make it clear,
> >  * css_get() is called from mem_cgroup_add_list().
> >  * css_put() is called from mem_cgroup_remove_list().
> >  * css_get()->css_put() is called while try_charge()->commit/cancel sequence.
> > is newly added.
> > 
> 
> I like this new policy, but
> 
> > @@ -710,17 +774,18 @@ static void __mem_cgroup_commit_charge(s
> 
> ===
>                 if (PageCgroupLRU(pc)) {
>                         ClearPageCgroupLRU(pc);
>                         __mem_cgroup_remove_list(mz, pc);
>                         css_put(&pc->mem_cgroup->css);
>                 }
>                 spin_unlock_irqrestore(&mz->lru_lock, flags);
>         }
> ===
> 
> Is this css_put needed yet?
> 
Oh, nice catch. it's unnecessary.
I'll fix this in the next. Thank you for review.


I'll post still-under-discuss set (v7), tomorrow.
includes
  - charge/commit/cancel
  - move account & force_empty
  - lazy lru free
  - lazy lru add
Currently works well under my test..

In the next week, I'd like to restart Mem+Swap series.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
