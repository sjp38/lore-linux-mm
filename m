Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD49F6B2D84
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:48:30 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w7-v6so15644686plp.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:48:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15-v6si50501281pff.131.2018.11.23.03.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:48:29 -0800 (PST)
Date: Fri, 23 Nov 2018 12:48:26 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181123114826.h27t7qiwfp7grrqx@pathway.suse.cz>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
 <20181122101606.GP2131@hirez.programming.kicks-ass.net>
 <20181123024048.GD1582@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123024048.GD1582@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On Fri 2018-11-23 11:40:48, Sergey Senozhatsky wrote:
> On (11/22/18 11:16), Peter Zijlstra wrote:
> > > So maybe we need to switch debug objects print-outs to _always_
> > > printk_deferred(). Debug objects can be used in code which cannot
> > > do direct printk() - timekeeping is just one example.
> > 
> > No, printk_deferred() is a disease, it needs to be eradicated, not
> > spread around.
> 
> deadlock-free printk() is deferred, but OK.

The best solution would be lockless console drivers. Sigh.


> Another idea then:
> 
> ---
> 
> diff --git a/lib/debugobjects.c b/lib/debugobjects.c
> index 70935ed91125..3928c2b2f77c 100644
> --- a/lib/debugobjects.c
> +++ b/lib/debugobjects.c
> @@ -323,10 +323,13 @@ static void debug_print_object(struct debug_obj *obj, char *msg)
>  		void *hint = descr->debug_hint ?
>  			descr->debug_hint(obj->object) : NULL;
>  		limit++;
> +
> +		bust_spinlocks(1);
>  		WARN(1, KERN_ERR "ODEBUG: %s %s (active state %u) "
>  				 "object type: %s hint: %pS\n",
>  			msg, obj_states[obj->state], obj->astate,
>  			descr->name, hint);
> +		bust_spinlocks(0);
>  	}
>  	debug_objects_warnings++;
>  }
> 
> ---
> 
> This should make serial consoles re-entrant.
> So printk->console_driver_write() hopefully will not deadlock.

Is the re-entrance safe? Some risk might be acceptable in Oops/panic
situations. It is much less acceptable for random warnings.

Best Regards,
Petr
