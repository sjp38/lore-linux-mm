Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA8B26B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 07:44:13 -0400 (EDT)
Received: by bwz17 with SMTP id 17so511214bwz.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 04:44:11 -0700 (PDT)
Date: Thu, 26 May 2011 13:44:06 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH v3 7/10] workqueue: add WQ_IDLEPRI
Message-ID: <20110526114406.GG9715@htj.dyndns.org>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
 <20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
 <20110526093808.GE9715@htj.dyndns.org>
 <20110526193018.12b3ddea.kamezawa.hiroyu@jp.fujitsu.com>
 <20110526195019.8af6d882.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110526195019.8af6d882.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

Hello,

On Thu, May 26, 2011 at 07:50:19PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 26 May 2011 19:30:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > In the next version, I'll try some like..
> > ==
> > 	process_one_work(...) {
> > 		.....
> > 		spin_unlock_irq(&gcwq->lock);
> > 		.....
> > 		if (cwq->wq->flags & WQ_IDLEPRI) {
> > 			set_scheduler(...SCHED_IDLE...)
> > 			cond_resched();
> > 			scheduler_switched = true;
> > 		}
> > 		f(work) 
> > 		if (scheduler_switched)
> > 			set_scheduler(...SCHED_OTHER...)
> > 		spin_lock_irq(&gcwq->lock);
> > 	}
> > ==
> > Patch size will be much smaller. (Should I do this in memcg's code ??)
> > 
> 
> BTW, my concern is that if f(work) is enough short,effect of SCHED_IDLE will never
> be found because SCHED_OTHER -> SCHED_IDLE -> SCHED_OTHER switch is very fast.
> Changed "weight" of CFQ never affects the next calculation of vruntime..of the
> thread and the work will show the same behavior with SCHED_OTHER.
> 
> I'm sorry if I misunderstand CFQ and setscheduler().

Hmm... I'm not too familiar there either but,

* If prio is lowered (you're gonna lower it too, right?),
  prio_changed_fair() is called which in turn does resched_task() as
  necessary.

* More importantly, for short work items, it's likely to not matter at
  all.  If you can determine beforehand that it's not gonna take very
  long time, queueing on system_wq would be more efficient.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
