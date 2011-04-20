Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 408B28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:46:13 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3K2dHOV018272
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:39:17 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3K2k7Zl152106
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:46:08 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3K2k7JE029624
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:46:07 -0600
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110420112006.461A.A69D9226@jp.fujitsu.com>
References: <1303263673.5076.612.camel@nimitz>
	 <20110420105059.460C.A69D9226@jp.fujitsu.com>
	 <20110420112006.461A.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 19 Apr 2011 19:46:02 -0700
Message-ID: <1303267562.5076.1004.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <johnstul@us.ibm.com>

On Wed, 2011-04-20 at 11:19 +0900, KOSAKI Motohiro wrote:
> > +     memcpy(tmp_comm, tsk->comm_buf, TASK_COMM_LEN);
> > +     tsk->comm = tmp;
> >       /*
> > -      * Threads may access current->comm without holding
> > -      * the task lock, so write the string carefully.
> > -      * Readers without a lock may see incomplete new
> > -      * names but are safe from non-terminating string reads.
> > +      * Make sure no one is still looking at tsk->comm_buf
> >        */
> > -     memset(tsk->comm, 0, TASK_COMM_LEN);
> > -     wmb();
> > -     strlcpy(tsk->comm, buf, sizeof(tsk->comm));
> > +     synchronize_rcu();
> 
> The doc says,
> 
> /**
>  * synchronize_rcu - wait until a grace period has elapsed.

Yeah, yeah... see "completely untested". :)

I'll see if dropping the locks or something else equally hackish can
help.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
