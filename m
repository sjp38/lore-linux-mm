Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49CA86B0012
	for <linux-mm@kvack.org>; Mon, 16 May 2011 02:29:52 -0400 (EDT)
Date: Mon, 16 May 2011 08:29:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Possible sandybridge livelock issue
Message-ID: <20110516062930.GA24836@elte.hu>
References: <1305303156.2611.51.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305303156.2611.51.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: x86@kernel.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> We've just come off a large round of debugging a kswapd problem over on
> linux-mm:
> 
> http://marc.info/?t=130392066000001
> 
> The upshot was that kswapd wasn't being allowed to sleep (which we're
> now fixing).  However, in spite of intensive efforts, the actual hang
> was only reproducible on sandybridge laptops.
> 
> When the hang occurred, kswapd basically pegged one core in 100% system
> time.  This looks like there's something specific to sandybridge that
> causes this type of bad interaction.  I was wondering if it could be
> something to to with a scheduling problem in turbo mode?  Once kswapd
> goes flat out, the core its on will kick into turbo mode, which causes
> it to get preferentially scheduled there, leading to the live lock.

There's no explicit 'schedule Sandybridge differently' logic in the scheduler.

Thus turbo mode can only affect scheduling by executing code faster. Executing 
faster *does* mean more scheduling on that CPU: it's faster to do work so it's 
faster back to idle again.

I.e. i can see Sandybridge being special only due to timing and performance 
differences.

> The only evidence I have to support this theory is that when I reproduce the 
> problem with PREEMPT, the core pegs at 100% system time and stays there even 
> if I turn off the load.  However, if I can execute work that causes kswapd to 
> be kicked off the core it's running on, it will calm back down and go to 
> sleep.

At first sight this looks like some sort of kswapd problem: if you put kswapd 
into TASK_*INTERRUPTIBLE and schedule() it then the scheduler won't keep it 
running, on Sandybridge or elsewhere. The scheduler can't magically make kswapd 
runnable unless there's some big bug in it. So you first need to examine why 
kswapd never schedules to idle.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
