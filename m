Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0AD666001DA
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 05:58:27 -0500 (EST)
Date: Tue, 23 Feb 2010 20:00:52 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100223200052.29a3375d.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100223173835.f260c111.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
	<20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223173835.f260c111.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 17:38:35 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 23 Feb 2010 16:07:14 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 23 Feb 2010 15:55:43 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Tue, 23 Feb 2010 15:26:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > On Tue, 23 Feb 2010 15:21:16 +0900
> > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > 
> > > > > On Tue, 23 Feb 2010 14:02:18 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > On Tue, 23 Feb 2010 12:03:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > > Nishimura-san, could you review and test your extreme test case with this ?
> > > > > > > 
> > > > > > Thank you for your patch.
> > > > > > I don't know why, but the problem seems not so easy to cause in mmotm as in 2.6.32.8,
> > > > > > but I'll try more anyway.
> > > > > > 
> > > > > I can triggered the problem in mmotm.
> > > > > 
> > > > > I'll continue my test with your patch applied.
> > > > > 
> > > > 
> > > > Thank you. Updated one here.
> > > > 
> > > Unfortunately, we need one more fix to avoid build error: remove the declaration
> > > of mem_cgroup_oom_called() from memcontrol.h.
> > > 
> > Ouch, I missed to add memcontrol.h to quilt's reflesh set..
> > This is updated one. Anyway, I'd like to wait for the next mmotm.
> > We already have several changes. 
> > 
> 
> After reviewing again, we may be able to remove memcg->oom_jiffies.
> Because select_bad_process() returns -1 if there is a TIF_MEMDIE task,
> no oom-kill will happen if a tasks is being killed.
> 
> But a concern is simultaneous calls of out-of-memory. I think mutex will
> be necessary. I'll check tomorrow, again.
> 
I see.

I have one more point.

> > @@ -1549,11 +1540,25 @@ static int __mem_cgroup_try_charge(struc
> >  		}
> >  
> >  		if (!nr_retries--) {
> > -			if (oom) {
> > -				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> > +			int oom_kill_called;
> > +			if (!oom)
> > +				goto nomem;
> > +			mutex_lock(&memcg_oom_mutex);
> > +			oom_kill_called = mem_cgroup_oom_called(mem_over_limit);
> > +			if (!oom_kill_called)
> >  				record_last_oom(mem_over_limit);
> > -			}
> > -			goto nomem;
> > +			mutex_unlock(&memcg_oom_mutex);
> > +			if (!oom_kill_called)
> > +				mem_cgroup_out_of_memory(mem_over_limit,
> > +				gfp_mask);
> > +			else /* give a chance to die for other tasks */
> > +				schedule_timeout(1);
> > +			nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > +			/* Killed myself ? */
> > +			if (!test_thread_flag(TIF_MEMDIE))
> > +				continue;
> > +			/* For smooth oom-kill of current, return 0 */
> > +			return 0;
We must call css_put() and reset *memcg to NULL before returning 0.
Otherwise, following commit_charge will commits the page(i.e. set PCG_USED)
while we've not charged res_counter.
(In fact, I saw res_counter underflow warnings(res_counter.c:72).)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
