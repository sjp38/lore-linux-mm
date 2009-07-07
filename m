Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E8C7A6B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 08:47:20 -0400 (EDT)
Subject: Re: kmemleak not tainted
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090707115128.GA3238@localdomain.by>
References: <20090707115128.GA3238@localdomain.by>
Content-Type: text/plain
Date: Tue, 07 Jul 2009 13:47:39 +0100
Message-Id: <1246970859.9451.34.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-07-07 at 14:51 +0300, Sergey Senozhatsky wrote:
> kernel: [ 1917.133154] INFO: RCU detected CPU 0 stall (t=485140/3000 jiffies)

That's the relevant message. With CONFIG_RCU_CPU_STALL_DETECTOR you may
get these messages.

> static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
> {
> 	unsigned long flags;
> 	struct kmemleak_object *object = NULL;
> 
> 	rcu_read_lock();
> 	read_lock_irqsave(&kmemleak_lock, flags);
> 	if (ptr >= min_addr && ptr < max_addr)
> 		object = lookup_object(ptr, alias);
> >>	read_unlock_irqrestore(&kmemleak_lock, flags);
> 
> 	/* check whether the object is still available */
> 	if (object && !get_object(object))
> 		object = NULL;
> 	rcu_read_unlock();
> 
> 	return object;
> }

It just happened here because that's where the interrupts were enabled
and the timer routine invoked. The rcu-locked region above should be
pretty short (just a tree look-up).

What I think happens is that the kmemleak thread runs for several
seconds for scanning the memory and there may not be any context
switches. I have a patch to add more cond_resched() calls throughout the
kmemleak_scan() function which I hope will get merged. I don't get any
of these messages with CONFIG_PREEMPT enabled.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
