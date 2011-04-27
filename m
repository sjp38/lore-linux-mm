Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1689000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:37:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C80AE3EE0B5
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:37:52 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADB6D45DEA6
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:37:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8979845DEA0
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:37:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A6EC1DB803F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:37:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43A441DB803A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:37:52 +0900 (JST)
Date: Wed, 27 Apr 2011 09:31:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/7] memcg watermark reclaim workqueue.
Message-Id: <20110427093116.3e9b43d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikB_4DXw2hPkBW4DDB1ZnXAJuSLKQ@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425184219.285c2396.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikB_4DXw2hPkBW4DDB1ZnXAJuSLKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Tue, 26 Apr 2011 16:19:41 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Apr 25, 2011 at 2:42 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > @@ -3661,6 +3683,67 @@ unsigned long mem_cgroup_soft_limit_recl
> >        return nr_reclaimed;
> >  }
> >
> > +struct workqueue_struct *memcg_bgreclaimq;
> > +
> > +static int memcg_bgreclaim_init(void)
> > +{
> > +       /*
> > +        * use UNBOUND workqueue because we traverse nodes (no locality)
> > and
> > +        * the work is cpu-intensive.
> > +        */
> > +       memcg_bgreclaimq = alloc_workqueue("memcg",
> > +                       WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
> > +       return 0;
> > +}
> >
> 
> I read about the documentation of workqueue. So the WQ_UNBOUND support the
> max 512 execution contexts per CPU. Does the execution context means thread?
> 
> I think I understand the motivation of that flag, so we can have more
> concurrency of bg reclaim workitems. But one question is on the workqueue
> scheduling mechanism. If we can queue the item anywhere as long as they are
> inserted in the queue, do we have mechanism to support the load balancing
> like the system scheduler? The scenario I am thinking is that one CPU has
> 512 work items and the other one has 1.
> 
IIUC, UNBOUND workqueue doesn't have cpumask and it can be scheduled anywhere.
So, scheduler's load balancing works well.

Because unbound_gcwq_nr_running == 0 always (If I believe comment on source),
 __need_more_worker() always returns true and 
need_to_create_worker() returns true if no idle thread.

Then, I think new kthread is created always if there is a work.

I wonder I shoud use WQ_CPU_INTENSIVE and spread jobs to each cpu per memcg. But
I don't see problem with UNBOUND wq, yet.


> I don't think this is directly related issue for this patch, and I just hope
> the workqueue mechanism already support something like that for load
> balancing.
> 
If not, we can add it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
