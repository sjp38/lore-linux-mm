Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAEA900138
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 12:05:24 -0400 (EDT)
Received: by eyh6 with SMTP id 6so1426056eyh.20
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 09:05:21 -0700 (PDT)
Date: Thu, 4 Aug 2011 19:04:16 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: select_task_rq_fair: WARNING: at kernel/lockdep.c match_held_lock
Message-ID: <20110804160415.GC3562@swordfish.minsk.epam.com>
References: <20110804141306.GA3536@swordfish.minsk.epam.com>
 <1312470358.16729.25.camel@twins>
 <20110804153752.GA3562@swordfish.minsk.epam.com>
 <1312472867.16729.38.camel@twins>
 <20110804155347.GB3562@swordfish.minsk.epam.com>
 <1312473473.16729.44.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312473473.16729.44.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On (08/04/11 17:57), Peter Zijlstra wrote:
> > > > > > [  132.794685] WARNING: at kernel/lockdep.c:3117 match_held_lock+0xf6/0x12e()
> > > 
> > > Just to double check, that line is:
> > > 
> > >                 if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
> > > 
> > > in your kernel source?
> > > 
> > 
> > Nope, that's `if (DEBUG_LOCKS_WARN_ON(!class))'
> > 
> > 3106 static int match_held_lock(struct held_lock *hlock, struct lockdep_map *lock)
> > 3107 {                                                                                                                                                                                                                             
> > 3108     if (hlock->instance == lock)
> > 3109         return 1;
> > 3110 
> > 3111     if (hlock->references) {
> > 3112         struct lock_class *class = lock->class_cache[0];
> > 3113 
> > 3114         if (!class)
> > 3115             class = look_up_lock_class(lock, 0);
> > 3116 
> > 3117         if (DEBUG_LOCKS_WARN_ON(!class))
> > 3118             return 0;
> > 3119 
> > 3120         if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
> > 3121             return 0;
> > 3122 
> > 3123         if (hlock->class_idx == class - lock_classes + 1)
> > 3124             return 1;
> > 3125     }
> > 3126 
> > 3127     return 0;
> > 3128 }
> > 3129 
> 
> Ah, in that case my previous analysis was pointless and I shall need to
> scratch my head some more. 
> 

That was a good idea to check what's going on on 3117 line. Well, your analysis
was correct, it's just we have different match_held_lock() lines, and I guess we 
may have different lines within match_held_lock()-callers in that case.

Just for note, I'm using the latest
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
$ git pull
Already up-to-date.


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
