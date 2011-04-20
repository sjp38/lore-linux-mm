Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BEFE28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:39:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AAB443EE0BD
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:39:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F99445DE92
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:39:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC5FB45DE8F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:39:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF78EE08002
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:39:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0D66E08001
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:39:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
References: <20110419094422.9375.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
Message-Id: <20110420093900.45F6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 09:39:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

> On Tue, 19 Apr 2011, KOSAKI Motohiro wrote:
> 
> > The rule is,
> > 
> > 1) writing comm
> > 	need task_lock
> > 2) read _another_ thread's comm
> > 	need task_lock
> > 3) read own comm
> > 	no need task_lock
> > 
> 
> That was true a while ago, but you now need to protect every thread's 
> ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> against /proc/pid/comm which can change other thread's ->comm.  That was 
> different before when prctl(PR_SET_NAME) would only operate on current, so 
> no lock was needed when reading current->comm.

Right. /proc/pid/comm is evil. We have to fix it. otherwise we need change
all of current->comm user. It's very lots!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
