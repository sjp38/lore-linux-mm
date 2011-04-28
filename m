Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7086B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:32:14 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3S0LPNR010930
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:21:25 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3S0WD0p095102
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:32:13 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3S0WCpu007247
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:32:13 -0400
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104271641350.25369@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
	 <1303331695.2796.159.camel@work-vm>
	 <20110421103009.731B.A69D9226@jp.fujitsu.com>
	 <1303846026.2816.117.camel@work-vm>
	 <alpine.DEB.2.00.1104271641350.25369@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 17:32:08 -0700
Message-ID: <1303950728.2971.35.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2011-04-27 at 16:51 -0700, David Rientjes wrote:
> On Tue, 26 Apr 2011, john stultz wrote:
> > In the meantime, I'll put some effort into trying to protect unlocked
> > current->comm acccess using get_task_comm() where possible. Won't happen
> > in a day, and help would be appreciated. 
> > 
> 
> We need to stop protecting ->comm with ->alloc_lock since it is used for 
> other members of task_struct that may or may not be held in a function 
> that wants to read ->comm.  We should probably introduce a seqlock.

Agreed. My initial approach is to consolidate accesses to use
get_task_comm(), with special case to skip the locking if tsk==current,
as well as a lock free __get_task_comm() for cases where its not current
being accessed and the task locking is already done.

Once that's all done, the next step is to switch to a seqlock (or
possibly RCU if Dave is still playing with that idea), internally in the
get_task_comm implementation and then yank the special __get_task_comm. 

But other suggestions are welcome.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
