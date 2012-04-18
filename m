Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3DF246B00F6
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:04 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so350228lbb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 13:02:02 -0700 (PDT)
Date: Wed, 18 Apr 2012 23:01:58 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1/2] vmevent: Should not grab mutex in the atomic
 context
In-Reply-To: <20120418083356.GA31556@lizard>
Message-ID: <alpine.LFD.2.02.1204182301430.11868@tux.localdomain>
References: <20120418083208.GA24904@lizard> <20120418083356.GA31556@lizard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Wed, 18 Apr 2012, Anton Vorontsov wrote:
> vmevent grabs a mutex in the atomic context, and so this pops up:
> 
> BUG: sleeping function called from invalid context at kernel/mutex.c:271
> in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper/0
> 1 lock held by swapper/0/0:
>  #0:  (&watch->timer){+.-...}, at: [<ffffffff8103eb80>] call_timer_fn+0x0/0xf0
> Pid: 0, comm: swapper/0 Not tainted 3.2.0+ #6
> Call Trace:
>  <IRQ>  [<ffffffff8102f5da>] __might_sleep+0x12a/0x1e0
>  [<ffffffff810bd990>] ? vmevent_match+0xe0/0xe0
>  [<ffffffff81321f2c>] mutex_lock_nested+0x3c/0x340
>  [<ffffffff81064b33>] ? lock_acquire+0xa3/0xc0
>  [<ffffffff8103eb80>] ? internal_add_timer+0x110/0x110
>  [<ffffffff810bd990>] ? vmevent_match+0xe0/0xe0
>  [<ffffffff810bda21>] vmevent_timer_fn+0x91/0xf0
>  [<ffffffff810bd990>] ? vmevent_match+0xe0/0xe0
>  [<ffffffff8103ebf5>] call_timer_fn+0x75/0xf0
>  [<ffffffff8103eb80>] ? internal_add_timer+0x110/0x110
>  [<ffffffff81062fdd>] ? trace_hardirqs_on_caller+0x7d/0x120
>  [<ffffffff8103ee9f>] run_timer_softirq+0x10f/0x1e0
>  [<ffffffff810bd990>] ? vmevent_match+0xe0/0xe0
>  [<ffffffff81038d90>] __do_softirq+0xb0/0x160
>  [<ffffffff8105eb0f>] ? tick_program_event+0x1f/0x30
>  [<ffffffff8132642c>] call_softirq+0x1c/0x26
>  [<ffffffff810036d5>] do_softirq+0x85/0xc0
> 
> This patch fixes the issue by removing the mutex and making the logic
> lock-free.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
