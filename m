Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C44E6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 10:49:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r6so5489314pfj.14
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:49:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y1si2429821plk.261.2017.11.02.07.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 07:49:55 -0700 (PDT)
Date: Thu, 2 Nov 2017 10:49:51 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171102104951.63c7b2ac@gandalf.local.home>
In-Reply-To: <20171102114650.GB31148@pathway.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171031153225.218234b4@gandalf.local.home>
	<187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
	<20171101133845.GF20040@pathway.suse.cz>
	<20171101113647.243eecf8@gandalf.local.home>
	<20171102114650.GB31148@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Thu, 2 Nov 2017 12:46:50 +0100
Petr Mladek <pmladek@suse.com> wrote:

> On Wed 2017-11-01 11:36:47, Steven Rostedt wrote:
> > On Wed, 1 Nov 2017 14:38:45 +0100
> > Petr Mladek <pmladek@suse.com> wrote:  
> > > My current main worry with Steven's approach is a risk of deadlocks
> > > that Jan Kara saw when he played with similar solution.  
> > 
> > And if there exists such a deadlock, then the deadlock exists today.  
> 
> The patch is going to effectively change console_trylock() to
> console_lock() and this might add problems.
> 
> The most simple example is:
> 
>        console_lock()
>          printk()
> 	    console_trylock() was SAFE.
> 
>        console_lock()
>          printk()
> 	   console_lock() cause DEADLOCK!
> 
> Sure, we could detect this and avoid waiting when
> console_owner == current. But does this cover all

Which I will do.

> situations? What about?
> 
> CPU0			CPU1
> 
> console_lock()          func()
>   console->write()        take_lockA()
>     func()		    printk()
> 			      busy wait for console_lock()
> 
>       take_lockA()

How does this not deadlock without my changes?

 func()
   take_lockA()
     printk()
       console_lock()
         console->write()
             func()
                take_lockA()

DEADLOCK!


> 
> By other words, it used to be safe to call printk() from
> console->write() functions because printk() used console_trylock().

I still don't see how this can be safe now.

> Your patch is going to change this. It is even worse because
> you probably will not use console_lock() directly and therefore
> this might be hidden for lockdep.

And no, my patch adds lockdep annotation for the spinner. And if I get
that wrong, I'm sure Peter Zijltra will help.

> 
> BTW: I am still not sure how to make the busy waiter preferred
> over console_lock() callers. I mean that the busy waiter has
> to get console_sem even if there are some tasks in the workqueue.

I started struggling with this, then realized that console_sem is just
that: a semaphore. Which doesn't have a concept of ownership. I can
simply hand off the semaphore without ever letting it go. My RFC patch
is almost done, you'll see it soon.

> 
> 
> > > But let's wait for the patch. It might look and work nicely
> > > in the end.  
> > 
> > Oh, I need to write a patch? Bah, I guess I should. Where's all those
> > developers dying to do kernel programing where I can pass this off to?  
> 
> Yes, where are these days when my primary task was to learn kernel
> hacking? This would have been a great training material.

:)

> 
> I still have to invest time into fixing printk. But I personally
> think that the lazy offloading to kthreads is more promising
> way to go. It is pretty straightforward. The only problem is
> the guaranty of the takeover. But there must be a reasonable
> way how to detect that the system heart is still beating
> and we are not the only working CPU.

My patch isn't that big. Let's talk more after I post it.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
