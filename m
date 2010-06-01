Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5FA6E6B0217
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:36:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517ar7A011354
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:36:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C38E945DE54
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:36:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C53445DE53
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:36:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA8F1DB8016
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:36:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2104D1DB8013
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:36:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006010015030.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015030.29202@chino.kir.corp.google.com>
Message-Id: <20100601163627.245D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:36:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This a complete rewrite of the oom killer's badness() heuristic which is
> used to determine which task to kill in oom conditions.  The goal is to
> make it as simple and predictable as possible so the results are better
> understood and we end up killing the task which will lead to the most
> memory freeing while still respecting the fine-tuning from userspace.
> 
> The baseline for the heuristic is a proportion of memory that each task is
> currently using in memory plus swap compared to the amount of "allowable"
> memory.  "Allowable," in this sense, means the system-wide resources for
> unconstrained oom conditions, the set of mempolicy nodes, the mems
> attached to current's cpuset, or a memory controller's limit.  The
> proportion is given on a scale of 0 (never kill) to 1000 (always kill),
> roughly meaning that if a task has a badness() score of 500 that the task
> consumes approximately 50% of allowable memory resident in RAM or in swap
> space.
> 
> The proportion is always relative to the amount of "allowable" memory and
> not the total amount of RAM systemwide so that mempolicies and cpusets may
> operate in isolation; they shall not need to know the true size of the
> machine on which they are running if they are bound to a specific set of
> nodes or mems, respectively.
> 
> Root tasks are given 3% extra memory just like __vm_enough_memory()
> provides in LSMs.  In the event of two tasks consuming similar amounts of
> memory, it is generally better to save root's task.
> 
> Because of the change in the badness() heuristic's baseline, it is also
> necessary to introduce a new user interface to tune it.  It's not possible
> to redefine the meaning of /proc/pid/oom_adj with a new scale since the
> ABI cannot be changed for backward compatability.  Instead, a new tunable,
> /proc/pid/oom_score_adj, is added that ranges from -1000 to +1000.  It may
> be used to polarize the heuristic such that certain tasks are never
> considered for oom kill while others may always be considered.  The value
> is added directly into the badness() score so a value of -500, for
> example, means to discount 50% of its memory consumption in comparison to
> other tasks either on the system, bound to the mempolicy, in the cpuset,
> or sharing the same memory controller.
> 
> /proc/pid/oom_adj is changed so that its meaning is rescaled into the
> units used by /proc/pid/oom_score_adj, and vice versa.  Changing one of
> these per-task tunables will rescale the value of the other to an
> equivalent meaning.  Although /proc/pid/oom_adj was originally defined as
> a bitshift on the badness score, it now shares the same linear growth as
> /proc/pid/oom_score_adj but with different granularity.  This is required
> so the ABI is not broken with userspace applications and allows oom_adj to
> be deprecated for future removal.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

nack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
