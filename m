Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 83CF5900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:44:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 545943EE081
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:44:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 388D345DE54
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:44:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13A5445DE51
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:44:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0426D1DB8044
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:44:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C25971DB8040
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:44:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303161774.9887.346.camel@nimitz>
References: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com> <1303161774.9887.346.camel@nimitz>
Message-Id: <20110419094422.9375.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Apr 2011 09:44:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

> On Mon, 2011-04-18 at 13:25 -0700, David Rientjes wrote:
> > It shouldn't be a follow-on patch since you're introducing a new feature 
> > here (vmalloc allocation failure warnings) and what I'm identifying is a 
> > race in the access to current->comm.  A bug fix for a race should always 
> > preceed a feature that touches the same code. 
> 
> So, what's the race here?  kmemleak.c says?
> 
>                 /*
>                  * There is a small chance of a race with set_task_comm(),
>                  * however using get_task_comm() here may cause locking
>                  * dependency issues with current->alloc_lock. In the worst
>                  * case, the command line is not correct.
>                  */
>                 strncpy(object->comm, current->comm, sizeof(object->comm));
> 
> We're trying to make sure we don't print out a partially updated
> tsk->comm?  Or, is there a bigger issue here like potential oopses or
> kernel information leaks.
> 
> 1. We require that no memory allocator ever holds the task lock for the
>    current task, and we audit all the existing GFP_ATOMIC users in the
>    kernel to ensure they're not doing it now.  In the case of a problem,
>    we end up with a hung kernel while trying to get a message out to the
>    console.
> 2. We remove current->comm from the printk(), and deal with the
>    information loss.
> 3. We live with corrupted output, like the other ~400 in-kernel users of
>    ->comm do. (I'm assuming that very few of them hold the task lock). 
>    In the case of a race, we get junk on the console, but an otherwise
>    fine bug report (the way it is now).
> 4. We come up with some way to print out current->comm, without holding
>    any task locks.  We could do this by copying it somewhere safe on
>    each context switch.  Could probably also do it with RCU.
> 
> There's also a very, very odd message in fs/exec.c:
> 
>         /*
>          * Threads may access current->comm without holding
>          * the task lock, so write the string carefully.
>          * Readers without a lock may see incomplete new
>          * names but are safe from non-terminating string reads.
>          */

The rule is,

1) writing comm
	need task_lock
2) read _another_ thread's comm
	need task_lock
3) read own comm
	no need task_lock

That's the reason why oom-kill.c need task_lock and other a lot of place don't need
task_lock. I agree this is very strange. it's only historical reason.

The comment of set_task_comm() explained a race against (3).

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
