Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CF8BC6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 21:57:51 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P1vwrV011685
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 10:57:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CC2045DE51
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 10:57:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6409E45DE4E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 10:57:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 315C51DB803F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 10:57:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 76DA7E1800B
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 10:57:57 +0900 (JST)
Date: Fri, 25 Sep 2009 10:55:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] memcg: avoid oom during charge migration
Message-Id: <20090925105547.5c0154c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925104409.b85b1f27.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144902.f4e5854c.nishimura@mxp.nes.nec.co.jp>
	<20090924163440.758ead95.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925104409.b85b1f27.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009 10:44:09 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 24 Sep 2009 16:34:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 24 Sep 2009 14:49:02 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > This charge migration feature has double charges on both "from" and "to"
> > > mem_cgroup during charge migration.
> > > This means unnecessary oom can happen because of charge migration.
> > > 
> > > This patch tries to avoid such oom.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  mm/memcontrol.c |   19 +++++++++++++++++++
> > >  1 files changed, 19 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index fbcc195..25de11c 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -287,6 +287,8 @@ struct migrate_charge {
> > >  	unsigned long precharge;
> > >  };
> > >  static struct migrate_charge *mc;
> > > +static struct task_struct *mc_task;
> > > +static DECLARE_WAIT_QUEUE_HEAD(mc_waitq);
> > >  
> > >  static void mem_cgroup_get(struct mem_cgroup *mem);
> > >  static void mem_cgroup_put(struct mem_cgroup *mem);
> > > @@ -1317,6 +1319,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  	while (1) {
> > >  		int ret = 0;
> > >  		unsigned long flags = 0;
> > > +		DEFINE_WAIT(wait);
> > >  
> > >  		if (mem_cgroup_is_root(mem))
> > >  			goto done;
> > > @@ -1358,6 +1361,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  		if (mem_cgroup_check_under_limit(mem_over_limit))
> > >  			continue;
> > >  
> > > +		/* try to avoid oom while someone is migrating charge */
> > > +		if (mc_task && current != mc_task) {
> > 
> > Hmm, I like
> > 
> > ==
> > 	if (mc && mc->to == mem)
> > or
> > 	if (mc) {
> > 		if (mem is ancestor of mc->to)
> > 			wait for a while
> > ==
> > 
> > ?
> > 
> I think we cannot access safely to mc->to w/o cgroup_lock,
> and we cannot hold cgroup_lock in __mem_cgroup_try_charge.
> 
> And I think we need to check "current != mc_task" anyway to prevent
> the process itself which is moving a task from being stopped.
> (Thas's why I defined mc_task.)

I think
==
static struct migrate_charge *mc;
==
should be
==
static struct migrate_charge mc;
==
Then, mc_task can be a field of mc.

And, it seems ok "don't stop a task which is under migration" .
I agreed.

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
