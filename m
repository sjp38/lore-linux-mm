Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D79AC6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:12:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 35-v6so4641775pla.18
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 02:12:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q62si4674018pgq.297.2018.04.20.02.12.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 02:12:27 -0700 (PDT)
Date: Fri, 20 Apr 2018 11:12:24 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420021511.GB6397@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 2018-04-20 11:15:11, Sergey Senozhatsky wrote:
> On (04/19/18 14:53), Petr Mladek wrote:
> > > > > 
> > > > > Besides 100 lines is absolutely not enough for any real lockdep splat.
> > > > > My call would be - up to 1000 lines in a 1 minute interval.
> > 
> > But this would break the intention of this patch.
> 
> You picked an arbitrary value and now you are saying that any other
> value will not work?

Yes, my number was arbitrary. The important thing is that it was long
enough. Or do you know about an console that will not be able to write
100 lines within one hour?

On the other hand. Let's take a classic 9600 baud console
1000 lines 80 characters long. If I count correctly,
the console would need:

      80 * 1000 * 8 / 9600 = 66.6666666 seconds

You might argue that average lines are below 80 characters.
But there eveidently is a non-trivial risk that 1000 lines
per minute ratelimiting would not help.


> > Come on guys! The first reaction how to fix the infinite loop was
> > to fix the console drivers and remove the recursive messages. We are
> > talking about messages that should not be there or they should
> > get replaced by WARN_ONCE(), print_once() or so. This patch only
> > give us a chance to see the problem and do not blow up immediately.
> > 
> > I am fine with increasing the number of lines. But we need to keep
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

> > the timeout long. In fact, 1 hour is still rather short from my POV.
> 
> Disagree.
> 
> I saw 3 or 4 lockdep reports coming from console drivers. "100 lines"
> is way too restrictive.

As I already wrote. I am fine with increasing the number of lines.
Will 1000 lines within 1 hour be enough for you, please?


> > > > Well, if we want to basically turn printk_safe() into printk_safe_ratelimited().
> > > > I'm not so sure about it.
> > 
> > No, it is not about printk_safe(). The ratelimit is active when
> > console_owner == current. It triggers when printk() is called
> > inside
> 
> "console_owner == current" is exactly the point when we call console
> drivers and add scheduler, networking, timekeeping, etc. locks to the
> picture. And so far all of the lockdeps reports that we had were from
> call_console_drivers(). So it very much is about printk_safe().

I am lost. In the mail
https://lkml.kernel.org/r/20180416014729.GB1034@jagdpanzerIV
you wrote:

<paste>
Chatty console drivers is not exactly the case which printk_safe() was
meant to fix. I'm pretty sure I put call_console_drivers() under printk_safe
just because we call console_drivers with local IRQs disabled anyway and I
was too lazy to do something like this
</paste>

My understanding of the older mail is that you called
console_drivers() in printk_safe() context only because it was
easier to disable printk_safe context later together with
enabling irqs.

My understanding of today's mail is that it is important
to call console drivers in printk_safe() context.

It is a contradiction. Could you please explain?


> > > > Besides the patch also rate limits printk_nmi->logbuf - the logbuf
> > > > PRINTK_NMI_DEFERRED_CONTEXT_MASK bypass, which is way too important
> > > > to rate limit it - for no reason.
> > 
> > Again. It has the effect only when console_owner == current. It means
> > that it affects "only" NMIs that interrupt console_unlock() when calling
> > console drivers.
> 
> What is your objection here? NMIs can come anytime.

Why do you completely ignore that I put "only" into quotation marks?
Why did you comment only the first paragraph and removed the
following paragraph from my reply?:

<paste>
Anyway, it needs to get fixed. I suggest to update the check in
printk_func():

	if (console_owner == current && !in_nmi() &&
	    !__ratelimit(&ratelimit_console))
		return 0;

</paste>

What is you real intention, please? Do you just want to show me as
an idiot or solve the problem? Is this some politics game?


> > > One more thing,
> > > I'd really prefer to rate limit the function which flushes per-CPU
> > > printk_safe buffers; not the function that appends new messages to
> > > the per-CPU printk_safe buffers.
> > 
> > I wonder if this opinion is still valid after explaining the
> > dependency on printk_safe(). In each case, it sounds weird
> > to block printk_safe buffers with some "unwanted" messages.
> > Or maybe I miss something.
> 
> I'm not following.
> 
> The fact that some consoles under some circumstances can add unwanted
> messages to the buffer does not look like a good enough reason to start
> rate limiting _all_ messages and to potentially discard the _important_
> ones.

Could you please read the original patch again? The ratelimiting
happens only when console_owner == current. This will be true
only if you print a message from the small context of
console_unlock() where console drivers are called?

What do you mean by _all_ messages, please?

Best Regards,
Petr
