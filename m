Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9716744043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 19:56:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y128so3706599pfg.5
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 16:56:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u196sor1429491pgc.111.2017.11.08.16.56.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 16:56:40 -0800 (PST)
Date: Thu, 9 Nov 2017 09:56:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171109005635.GA775@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
 <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
 <20171107014015.GA1822@jagdpanzerIV>
 <20171108051955.GA468@jagdpanzerIV>
 <20171108092951.4d677bca@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108092951.4d677bca@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

Hello Steven,

On (11/08/17 09:29), Steven Rostedt wrote:
> On Wed, 8 Nov 2017 14:19:55 +0900
> Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> 
> > the change goes further. I did express some of my concerns during the KS,
> > I'll just bring them to the list.
> > 
> > 
> > we now always shift printing from a save - scheduleable - context to
> > a potentially unsafe one - atomic. by example:
> 
> And vice versa. We are now likely to go from a unscheduleable context
> to a schedule one, where before, that didn't exist.

the existence of "and vice versa" is kinda alarming, isn't it? it's sort
of "yes, we can break some things, but we also can improve some things."

> And my approach, makes it more likely that the task doing the printk
> prints its own message, and less likely to print someone else's.
> 
> > 
> > CPU0			CPU1~CPU10	CPU11
> > 
> > console_lock()
> > 
> > 			printk();
> > 
> > console_unlock()			IRQ
> >  set console_owner			printk()
> > 					 sees console_owner
> > 					 set console_waiter
> >  sees console_waiter
> >  break
> > 					 console_unlock()
> > 					 ^^^^ lockup [?]
> 
> How?

oh, yes, the missing part - assume CPU1~CPU10 did 5000 printk() calls,
while console_sem was locked on CPU0. then we console_unlock() from CPU0
and shortly after IRQ->printk() from CPU11 forcibly takes over, so now
we are in console_unlock() from atomic, printing some 5000 messages.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
