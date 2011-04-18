Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D0BE7900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:22:59 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IKsnxa013642
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:54:49 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3ILMvDA409022
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:22:57 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3ILMvJt010497
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:22:57 -0400
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
	 <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
	 <1303139455.9615.2533.camel@nimitz>
	 <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 14:22:54 -0700
Message-ID: <1303161774.9887.346.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-04-18 at 13:25 -0700, David Rientjes wrote:
> It shouldn't be a follow-on patch since you're introducing a new feature 
> here (vmalloc allocation failure warnings) and what I'm identifying is a 
> race in the access to current->comm.  A bug fix for a race should always 
> preceed a feature that touches the same code. 

So, what's the race here?  kmemleak.c says?

                /*
                 * There is a small chance of a race with set_task_comm(),
                 * however using get_task_comm() here may cause locking
                 * dependency issues with current->alloc_lock. In the worst
                 * case, the command line is not correct.
                 */
                strncpy(object->comm, current->comm, sizeof(object->comm));

We're trying to make sure we don't print out a partially updated
tsk->comm?  Or, is there a bigger issue here like potential oopses or
kernel information leaks.

1. We require that no memory allocator ever holds the task lock for the
   current task, and we audit all the existing GFP_ATOMIC users in the
   kernel to ensure they're not doing it now.  In the case of a problem,
   we end up with a hung kernel while trying to get a message out to the
   console.
2. We remove current->comm from the printk(), and deal with the
   information loss.
3. We live with corrupted output, like the other ~400 in-kernel users of
   ->comm do. (I'm assuming that very few of them hold the task lock). 
   In the case of a race, we get junk on the console, but an otherwise
   fine bug report (the way it is now).
4. We come up with some way to print out current->comm, without holding
   any task locks.  We could do this by copying it somewhere safe on
   each context switch.  Could probably also do it with RCU.

There's also a very, very odd message in fs/exec.c:

        /*
         * Threads may access current->comm without holding
         * the task lock, so write the string carefully.
         * Readers without a lock may see incomplete new
         * names but are safe from non-terminating string reads.
         */

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
