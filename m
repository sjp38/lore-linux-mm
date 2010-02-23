Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B876E6B0089
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 19:02:09 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O027X4005156
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 09:02:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A4CE2E6A2E
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:02:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 191161EF081
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:02:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 004691DB804B
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:02:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CE801DB8044
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:02:06 +0900 (JST)
Date: Wed, 24 Feb 2010 08:58:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100224085836.871aa7b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100223200052.29a3375d.d-nishimura@mtf.biglobe.ne.jp>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
	<20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223173835.f260c111.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223200052.29a3375d.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 20:00:52 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> On Tue, 23 Feb 2010 17:38:35 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 23 Feb 2010 16:07:14 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Tue, 23 Feb 2010 15:55:43 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Tue, 23 Feb 2010 15:26:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > On Tue, 23 Feb 2010 15:21:16 +0900
> > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > 
> > > > > > On Tue, 23 Feb 2010 14:02:18 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > > On Tue, 23 Feb 2010 12:03:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > > > Nishimura-san, could you review and test your extreme test case with this ?
> > > > > > > > 
> > > > > > > Thank you for your patch.
> > > > > > > I don't know why, but the problem seems not so easy to cause in mmotm as in 2.6.32.8,
> > > > > > > but I'll try more anyway.
> > > > > > > 
> > > > > > I can triggered the problem in mmotm.
> > > > > > 
> > > > > > I'll continue my test with your patch applied.
> > > > > > 
> > > > > 
> > > > > Thank you. Updated one here.
> > > > > 
> > > > Unfortunately, we need one more fix to avoid build error: remove the declaration
> > > > of mem_cgroup_oom_called() from memcontrol.h.
> > > > 
> > > Ouch, I missed to add memcontrol.h to quilt's reflesh set..
> > > This is updated one. Anyway, I'd like to wait for the next mmotm.
> > > We already have several changes. 
> > > 
> > 
> > After reviewing again, we may be able to remove memcg->oom_jiffies.
> > Because select_bad_process() returns -1 if there is a TIF_MEMDIE task,
> > no oom-kill will happen if a tasks is being killed.
> > 
> > But a concern is simultaneous calls of out-of-memory. I think mutex will
> > be necessary. I'll check tomorrow, again.
> > 
> I see.
> 
> I have one more point.
> 
> > > @@ -1549,11 +1540,25 @@ static int __mem_cgroup_try_charge(struc
> > >  		}
> > >  
> > >  		if (!nr_retries--) {
> > > -			if (oom) {
> > > -				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> > > +			int oom_kill_called;
> > > +			if (!oom)
> > > +				goto nomem;
> > > +			mutex_lock(&memcg_oom_mutex);
> > > +			oom_kill_called = mem_cgroup_oom_called(mem_over_limit);
> > > +			if (!oom_kill_called)
> > >  				record_last_oom(mem_over_limit);
> > > -			}
> > > -			goto nomem;
> > > +			mutex_unlock(&memcg_oom_mutex);
> > > +			if (!oom_kill_called)
> > > +				mem_cgroup_out_of_memory(mem_over_limit,
> > > +				gfp_mask);
> > > +			else /* give a chance to die for other tasks */
> > > +				schedule_timeout(1);
> > > +			nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > > +			/* Killed myself ? */
> > > +			if (!test_thread_flag(TIF_MEMDIE))
> > > +				continue;
> > > +			/* For smooth oom-kill of current, return 0 */
> > > +			return 0;
> We must call css_put() and reset *memcg to NULL before returning 0.
> Otherwise, following commit_charge will commits the page(i.e. set PCG_USED)
> while we've not charged res_counter.
> (In fact, I saw res_counter underflow warnings(res_counter.c:72).)
> 
Ah, ok. I'll do.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
