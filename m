Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BD983900138
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 11:54:52 -0400 (EDT)
Received: by eyh6 with SMTP id 6so1415371eyh.20
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 08:54:48 -0700 (PDT)
Date: Thu, 4 Aug 2011 18:53:47 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: select_task_rq_fair: WARNING: at kernel/lockdep.c match_held_lock
Message-ID: <20110804155347.GB3562@swordfish.minsk.epam.com>
References: <20110804141306.GA3536@swordfish.minsk.epam.com>
 <1312470358.16729.25.camel@twins>
 <20110804153752.GA3562@swordfish.minsk.epam.com>
 <1312472867.16729.38.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312472867.16729.38.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On (08/04/11 17:47), Peter Zijlstra wrote:
> On Thu, 2011-08-04 at 18:37 +0300, Sergey Senozhatsky wrote:
> > > > [  132.794685] WARNING: at kernel/lockdep.c:3117 match_held_lock+0xf6/0x12e()
> 
> Just to double check, that line is:
> 
>                 if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
> 
> in your kernel source?
> 

Nope, that's `if (DEBUG_LOCKS_WARN_ON(!class))'

3106 static int match_held_lock(struct held_lock *hlock, struct lockdep_map *lock)
3107 {                                                                                                                                                                                                                             
3108     if (hlock->instance == lock)
3109         return 1;
3110 
3111     if (hlock->references) {
3112         struct lock_class *class = lock->class_cache[0];
3113 
3114         if (!class)
3115             class = look_up_lock_class(lock, 0);
3116 
3117         if (DEBUG_LOCKS_WARN_ON(!class))
3118             return 0;
3119 
3120         if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
3121             return 0;
3122 
3123         if (hlock->class_idx == class - lock_classes + 1)
3124             return 1;
3125     }
3126 
3127     return 0;
3128 }
3129 


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
