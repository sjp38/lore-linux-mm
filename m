Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C0CEE6B0082
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 00:11:56 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1H5BsP5013094
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Feb 2009 14:11:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32DEB45DE50
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:11:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B931B45DE52
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:11:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 659861DB8041
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:11:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD8CBE3800B
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:11:52 +0900 (JST)
Date: Tue, 17 Feb 2009 14:10:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches (v2)
Message-Id: <20090217141039.440e5463.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090217044110.GD20958@balbir.in.ibm.com>
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
	<20090217090523.975bbec2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090217030526.GA20958@balbir.in.ibm.com>
	<20090217130352.4ba7f91c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090217044110.GD20958@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Feb 2009 10:11:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-17 13:03:52]:
> 
> > On Tue, 17 Feb 2009 08:35:26 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I don't want to add any new big burden to kernel hackers of memory management,
> > they work hard to improve memory reclaim. This patch will change the behavior.
> > 
> 
> I don't think I agree, this approach suggests that before doing global
> reclaim, there are several groups that are using more than their
> share of memory, so it makes sense to reclaim from them first.
> 

> 
> > BTW, in typical bad case, several threads on cpus goes into memory recalim at once and
> > all thread will visit this memcg's soft-limit tree at once and soft-limit will
> > not work as desired anyway.
> > You can't avoid this problem at alloc_page() hot-path.
> 
> Even if all threads go into soft-reclaim at once, the tree will become
> empty after a point and we will just return saying there are no more
> memcg's to reclaim from (we remove the memcg from the tree when
> reclaiming), then those threads will go into regular reclaim if there
> is still memory pressure.

Yes. the largest-excess group will be removed. So, it seems that it doesn't work
as designed. rbtree is considered as just a hint ? If so, rbtree seems to be
overkill.

just a question:
Assume memcg under hierarchy.
   ../group_A/                 usage=1G, soft_limit=900M  hierarchy=1
              01/              usage=200M, soft_limit=100M
              02/              usage=300M, soft_limit=200M
              03/              usage=500M, soft_limit=300M  <==== 200M over.
                 004/          usage=200M, soft_limit=100M
                 005/          usage=300M, soft_limit=200M

At memory shortage, group 03's memory will be reclaimed 
  - reclaim memory from 03, 03/004, 03/005

When 100M of group 03' memory is reclaimed, group_A 's memory is reclaimd at the
same time, implicitly. Doesn't this break your rb-tree ?

I recommend you that soft-limit can be only applied to the node which is top of
hierarchy.
 
> > 
> > > > 3. After this patch, res_counter is no longer for general purpose res_counter...
> > > >    It seems to have too many unnecessary accessories for general purpose.  
> > > 
> > > Why not? Soft limits are a feature of any controller. The return of
> > > highest ancestor might be the only policy we impose right now. But as
> > > new controllers start using res_counter, we can clearly add a policy
> > > callback.
> > > 
> > I think you forget that memroy cgroups is an only controller in which the kernel
> > can reduce the usage of resource without any harmful to users.
> > soft-limit is nonsense for general resources, I think.
> > 
> 
> Really? Even for CPUs? soft-limit is a form of shares (please don't
> confuse with cpu.shares). Soft limits is used as a way of implementing
> work conserving controllers.
> 

I don't think cpu needs this. It works under share and no hardlimit.

THanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
