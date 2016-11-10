Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF6A6B0278
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:05:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so5355075wme.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:05:49 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id sm3si3971393wjc.199.2016.11.10.01.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:05:48 -0800 (PST)
Date: Thu, 10 Nov 2016 10:03:11 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
In-Reply-To: <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1611100959040.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com> <alpine.DEB.2.20.1611092227200.3501@nanos> <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On Thu, 10 Nov 2016, Jason A. Donenfeld wrote:

> Hey Thomas,
> 
> On Wed, Nov 9, 2016 at 10:40 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > That preempt_disable() prevents merily preemption as the name says, but it
> > wont prevent softirq handlers from running on return from interrupt. So
> > what's the point?
> 
> Oh, interesting. Okay, then in that case the proposed define wouldn't
> be useful for my purposes.

If you want to go with that config, then you need
local_bh_disable()/enable() to fend softirqs off, which disables also
preemption.

> What clever tricks do I have at my disposal, then?

Make MIPS use interrupt stacks.
 
> >> If not, do you have a better solution for me (which doesn't
> >> involve using kmalloc or choosing a different crypto primitive)?
> >
> > What's wrong with using kmalloc?
> 
> It's cumbersome and potentially slow. This is crypto code, where speed
> matters a lot. Avoiding allocations is usually the lowest hanging
> fruit among optimizations. To give you some idea, here's a somewhat
> horrible solution using kmalloc I hacked together: [1]. I'm not to
> happy with what it looks like, code-wise, and there's around a 16%
> slowdown, which isn't nice either.

Does the slowdown come from the kmalloc overhead or mostly from the less
efficient code?

If it's mainly kmalloc, then you can preallocate the buffer once for the
kthread you're running in and be done with it. If it's the code, then bad
luck.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
