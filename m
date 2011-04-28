Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 18493900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:48:30 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3SMmS20031079
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 15:48:28 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz37.hot.corp.google.com with ESMTP id p3SMm8gq015163
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 15:48:27 -0700
Received: by pvh11 with SMTP id 11so2379837pvh.8
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 15:48:27 -0700 (PDT)
Date: Thu, 28 Apr 2011 15:48:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303954193.2971.43.camel@work-vm>
Message-ID: <alpine.DEB.2.00.1104281545590.24536@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com> <1303331695.2796.159.camel@work-vm> <20110421103009.731B.A69D9226@jp.fujitsu.com> <1303846026.2816.117.camel@work-vm> <alpine.DEB.2.00.1104271641350.25369@chino.kir.corp.google.com>
 <1303950728.2971.35.camel@work-vm> <1303954193.2971.43.camel@work-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 27 Apr 2011, john stultz wrote:

> So thinking further, this can be simplified by adding the seqlock first,
> and then retaining the task_locking only in the set_task_comm path until
> all comm accessors are converted to using get_task_comm.
> 

On second thought, I think it would be better to just retain using a 
spinlock but instead of using alloc_lock, introduce a new spinlock to 
task_struct for the sole purpose of protecting comm.

And, instead, of using get_task_comm() to write into a preallocated 
buffer, I think it would be easier in the vast majority of cases that 
you'll need to convert to just provide task_comm_lock(p) and 
task_comm_unlock(p) so that p->comm can be dereferenced safely.  
get_task_comm() could use that interface itself and then write into a 
preallocated buffer.

The problem with using get_task_comm() everywhere is it requires 16 
additional bytes to be allocated on the stack in hundreds of locations 
around the kernel which may or may not be safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
