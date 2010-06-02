Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CAFE66B01B4
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 10:32:11 -0400 (EDT)
Received: by pwj6 with SMTP id 6so338138pwj.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 07:32:09 -0700 (PDT)
Date: Wed, 2 Jun 2010 11:20:18 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100602142018.GH17404@uudg.org>
References: <20100601173535.GD23428@uudg.org>
 <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com>
 <20100602220429.F51E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602220429.F51E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 02, 2010 at 10:54:01PM +0900, KOSAKI Motohiro wrote:
| > > @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
| > >  		 * Otherwise we could get an easy OOM deadlock.
| > >  		 */
| > >  		if (p->flags & PF_EXITING) {
| > > -			if (p != current)
| > > +			if (p != current) {
| > > +				boost_dying_task_prio(p, mem);
| > >  				return ERR_PTR(-1UL);
| > > -
| > > +			}
| > >  			chosen = p;
| > >  			*ppoints = ULONG_MAX;
| > >  		}
| > 
| > This has the potential to actually make it harder to free memory if p is 
| > waiting to acquire a writelock on mm->mmap_sem in the exit path while the 
| > thread holding mm->mmap_sem is trying to run.
| 
| if p is waiting, changing prio have no effect. It continue tol wait to release mmap_sem.

Ok, that was not a good idea after all :)

But I understand the !rt_task(p) test is necessary to avoid decrementing
the priority of an eventual RT task selected to die. Though it may also be
a corner case in badness().

Luis
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
