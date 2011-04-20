Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4168D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:50:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D42BE3EE0C5
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:50:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B2A6245DE94
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:50:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9471045DE93
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:50:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 817FDE08003
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:50:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47F291DB803B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:50:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303263673.5076.612.camel@nimitz>
References: <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com> <1303263673.5076.612.camel@nimitz>
Message-Id: <20110420105059.460C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 10:50:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <johnstul@us.ibm.com>

Hi

(Cc to  John Stultz who/proc/<pid>/comm author. I think we need to hear his opinion)

> On Tue, 2011-04-19 at 14:21 -0700, David Rientjes wrote:
> > On Tue, 19 Apr 2011, KOSAKI Motohiro wrote:
> > > The rule is,
> > > 
> > > 1) writing comm
> > > 	need task_lock
> > > 2) read _another_ thread's comm
> > > 	need task_lock
> > > 3) read own comm
> > > 	no need task_lock
> > 
> > That was true a while ago, but you now need to protect every thread's 
> > ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> > against /proc/pid/comm which can change other thread's ->comm.  That was 
> > different before when prctl(PR_SET_NAME) would only operate on current, so 
> > no lock was needed when reading current->comm.
> 
> Everybody still goes through set_task_comm() to _set_ it, though.  That
> means that the worst case scenario that we get is output truncated
> (possibly to nothing).  We already have at least one existing user in
> mm/ (kmemleak) that thinks this is OK.  I'd tend to err in the direction
> of taking a truncated or empty task name to possibly locking up the
> system.
> 
> There are also plenty of instances of current->comm going in to the
> kernel these days.  I count 18 added since 2.6.37.
> 
> As for a long-term fix, locks probably aren't the answer.  Would
> something like this completely untested patch work?  It would have the
> added bonus that it keeps tsk->comm users working for the moment.  We
> could eventually add an rcu_read_lock()-annotated access function.

The concept is ok to me. but AFAIK some caller are now using ARRAY_SIZE(tsk->comm).
or sizeof(tsk->comm). Probably callers need to be changed too.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
