Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2D2900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:03:41 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IL0mjS015082
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:00:48 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3IL3HhA090254
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:03:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3IL3Gfw010303
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:03:16 -0600
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
	 <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
	 <1303139455.9615.2533.camel@nimitz>
	 <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 14:03:14 -0700
Message-ID: <1303160594.9887.309.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-04-18 at 13:25 -0700, David Rientjes wrote:
>  - provide a statically-allocated buffer to use for get_task_comm() and 
>    copy current->comm over before printing it, or
> 
>  - take task_lock(current) to protect against /proc/pid/comm.
> 
> The latter probably isn't safe because we could potentially already be 
> holding task_lock(current) during a GFP_ATOMIC page allocation. 

I'm not sure get_task_comm() is suitable, either.  It takes the task
lock:

char *get_task_comm(char *buf, struct task_struct *tsk)
{
        /* buf must be at least sizeof(tsk->comm) in size */
        task_lock(tsk);
        strncpy(buf, tsk->comm, sizeof(tsk->comm));
        task_unlock(tsk);
        return buf;
}

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
