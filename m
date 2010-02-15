Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 45E026B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 03:05:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F85nX1019972
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Feb 2010 17:05:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8443E45DE5B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:05:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32DAE45DE56
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:05:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F3BFF1DB8044
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:05:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BC8EE38001
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:05:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
Message-Id: <20100215140349.7287.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Feb 2010 17:05:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This a complete rewrite of the oom killer's badness() heuristic which is
> used to determine which task to kill in oom conditions.  The goal is to
> make it as simple and predictable as possible so the results are better
> understood and we end up killing the task which will lead to the most
> memory freeing while still respecting the fine-tuning from userspace.
> 
> The baseline for the heuristic is a proportion of memory that each task
> is currently using in memory plus swap compared to the amount of
> "allowable" memory.  "Allowable," in this sense, means the system-wide
> resources for unconstrained oom conditions, the set of mempolicy nodes,
> the mems attached to current's cpuset, or a memory controller's limit.
> The proportion is given on a scale of 0 (never kill) to 1000 (always
> kill), roughly meaning that if a task has a badness() score of 500 that
> the task consumes approximately 50% of allowable memory resident in RAM
> or in swap space.
> 
> The proportion is always relative to the amount of "allowable" memory and
> not the total amount of RAM systemwide so that mempolicies and cpusets
> may operate in isolation; they shall not need to know the true size of
> the machine on which they are running if they are bound to a specific set
> of nodes or mems, respectively.
> 
> Forkbomb detection is done in a completely different way: a threshold is
> configurable from userspace to determine how many first-generation execve
> children (those with their own address spaces) a task may have before it
> is considered a forkbomb.  This can be tuned by altering the value in
> /proc/sys/vm/oom_forkbomb_thres, which defaults to 1000.
> 
> When a task has more than 1000 first-generation children with different
> address spaces than itself, a penalty of
> 
> 	(average rss of children) * (# of 1st generation execve children)
> 	-----------------------------------------------------------------
> 			oom_forkbomb_thres
> 
> is assessed.  So, for example, using the default oom_forkbomb_thres of
> 1000, the penalty is twice the average rss of all its execve children if
> there are 2000 such tasks.  A task is considered to count toward the
> threshold if its total runtime is less than one second; for 1000 of such
> tasks to exist, the parent process must be forking at an extremely high
> rate either erroneously or maliciously.
> 
> Even though a particular task may be designated a forkbomb and selected
> as the victim, the oom killer will still kill the 1st generation execve
> child with the highest badness() score in its place.  The avoids killing
> important servers or system daemons.
> 
> Root tasks are given 3% extra memory just like __vm_enough_memory()
> provides in LSMs.  In the event of two tasks consuming similar amounts of
> memory, it is generally better to save root's task.
> 
> Because of the change in the badness() heuristic's baseline, a change
> must also be made to the user interface used to tune it.  Instead of a
> scale from -16 to +15 to indicate a bitshift on the point value given to
> a task, which was very difficult to tune accurately or with any degree of
> precision, /proc/pid/oom_adj now ranges from -1000 to +1000.  That is, it
> can be used to polarize the heuristic such that certain tasks are never
> considered for oom kill while others are always considered.  The value is
> added directly into the badness() score so a value of -500, for example,
> means to discount 50% of its memory consumption in comparison to other
> tasks either on the system, bound to the mempolicy, or in the cpuset.
> 
> OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
> 2006 via include/linux/oom.h.  This alters their values from -16 to -1000
> and from +15 to +1000, respectively.  OOM_DISABLE is now the equivalent
> of the lowest possible value, OOM_ADJUST_MIN.  Adding its value, -1000,
> to any badness score will always return 0.
> 
> Although redefining these values may be controversial, it is much easier
> to understand when the units are fully understood as described above.
> In the short-term, there may be userspace breakage for tasks that
> hardcode -17 meaning OOM_DISABLE, for example, but the long-term will
> make the semantics much easier to understand and oom killing much more
> effective.

I NAK this patch as same as many other people. This patch bring to a lot of
compatibility issue. and it isn't necessary.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
