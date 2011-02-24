Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D73208D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 19:20:08 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4FF1B3EE0BD
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:20:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3509F45DE5D
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:20:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BD045DE5B
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:20:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04C8AE38002
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:20:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B37CAE08001
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 09:20:04 +0900 (JST)
Date: Thu, 24 Feb 2011 09:13:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110224091348.a95ed1b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110223150850.8b52f244.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 23 Feb 2011 15:08:50 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 9 Feb 2011 14:19:50 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because it
> > is unresponsive.  This scenario creates a memcg deadlock: tasks are
> > sitting in TASK_KILLABLE waiting for the limit to be increased, a task to
> > exit or move, or the oom killer reenabled and userspace is unable to do
> > so.
> > 
> > An additional possible use case is to defer oom killing within a memcg
> > for a set period of time, probably to prevent unnecessary kills due to
> > temporary memory spikes, before allowing the kernel to handle the
> > condition.
> > 
> > This patch adds an oom killer delay so that a memcg may be configured to
> > wait at least a pre-defined number of milliseconds before calling the oom
> > killer.  If the oom condition persists for this number of milliseconds,
> > the oom killer will be called the next time the memory controller
> > attempts to charge a page (and memory.oom_control is set to 0).  This
> > allows userspace to have a short period of time to respond to the
> > condition before deferring to the kernel to kill a task.
> > 
> > Admins may set the oom killer delay using the new interface:
> > 
> > 	# echo 60000 > memory.oom_delay_millisecs
> > 
> > This will defer oom killing to the kernel only after 60 seconds has
> > elapsed by putting the task to sleep for 60 seconds.  When setting
> > memory.oom_delay_millisecs, all pending delays have their charges retried
> > and, if necessary, the new delay is then enforced.
> > 
> > The delay is cleared the first time the memcg is oom to avoid unnecessary
> > waiting when userspace is unresponsive for future oom conditions.  It may
> > be set again using the above interface to enforce a delay on the next
> > oom.
> > 
> > When a memory.oom_delay_millisecs is set for a cgroup, it is propagated
> > to all children memcg as well and is inherited when a new memcg is
> > created.
> 
> Your patch still stinks!
> 
> If userspace can't handle a disabled oom-killer then userspace
> shouldn't have disabled the oom-killer.
> 
> How do we fix this properly?
> 
> A little birdie tells me that the offending userspace oom handler is
> running in a separate memcg and is not itself running out of memory. 
> The problem is that the userspace oom handler is also taking peeks into
> processes which are in the stressed memcg and is getting stuck on
> mmap_sem in the procfs reads.  Correct?
> 

Hmm, I think memcg's oom-kill just happens under down_read(mmap_sem). 
And all tasks, which is under oom, will be in wait-queue.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
