Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3EDD26B01C3
	for <linux-mm@kvack.org>; Fri, 28 May 2010 02:38:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S6cqd5008238
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 May 2010 15:38:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B541E45DE4F
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 909F345DE51
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D7BAE08006
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E21EE08003
	for <linux-mm@kvack.org>; Fri, 28 May 2010 15:38:52 +0900 (JST)
Date: Fri, 28 May 2010 15:34:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-Id: <20100528153432.a4f5ef2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100528062701.GA3519@balbir.in.ibm.com>
References: <20100528035147.GD11364@uudg.org>
	<20100528043339.GZ3519@balbir.in.ibm.com>
	<20100528134133.7E24.A69D9226@jp.fujitsu.com>
	<20100528062701.GA3519@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010 11:57:01 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I am still not convinced, specially if we are running under mem
> cgroup. Even setting SCHED_FIFO does not help, you could have other
> things like cpusets that might restrict the CPUs you can run on, or
> any other policy and we could end up contending anyway with other
> SCHED_FIFO tasks.
>  
> > That's the reason I acked it.
> 
> If we could show faster recovery from OOM or anything else, I would be
> more convinced.
> 
Off topic.

 1. Run a daemon in the highest RT priority.
 2. disable OOM for a mem cgroup.
 3. The daemon register oom-event-notifier of the mem cgroup.

 When OOM happens.
 4. The daemon receive a event, and then,
    a) enlarge limit
    or
    b) kill a task 
    or
    c) enlarge limit temporary and kill a task, later, reduce limit again.

This is the fastest and promissing operation for memcg users.

memcg's oom slowdown happens just because it's limited by a user configuration
not by the system. That's a point to be considered.
The oom situation can be _immediaterly_ fixed up by enlarge limit as emergency mode.

If you has to wait for the end of a task, there will be delay, it's unavoidable.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
