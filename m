Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id EC2E66B0092
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 11:37:38 -0500 (EST)
Received: by lagz14 with SMTP id z14so5249082lag.14
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 08:37:37 -0800 (PST)
Date: Sun, 4 Mar 2012 18:37:34 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 3/3] vmevent: Should not grab mutex in the atomic
 context
In-Reply-To: <20120303000932.GC30207@oksana.dev.rtsoft.ru>
Message-ID: <alpine.LFD.2.02.1203041835420.1636@tux.localdomain>
References: <20120303000932.GC30207@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

On Sat, 3 Mar 2012, Anton Vorontsov wrote:
> There is not need to grab mutex in the atomic context, moreover this is
> wrong and causes the following bug:
> 
> BUG: sleeping function called from invalid context at kernel/mutex.c:271
> in_atomic(): 1, irqs_disabled(): 1, pid: 1056, name: m
> no locks held by m/1056.
> irq event stamp: 58768
> hardirqs last  enabled at (58767): [<ffffffff8101ca35>] do_page_fault+0x275/0x450
> hardirqs last disabled at (58768): [<ffffffff81325a2b>] apic_timer_interrupt+0x6b/0x80
> softirqs last  enabled at (58676): [<ffffffff81038def>] __do_softirq+0x10f/0x160
> softirqs last disabled at (58671): [<ffffffff813262ac>] call_softirq+0x1c/0x26
> Pid: 1056, comm: m Not tainted 3.2.0+ #3
> Call Trace:
>  <IRQ>  [<ffffffff81062530>] ? print_irqtrace_events+0xd0/0xe0
>  [<ffffffff8102f5da>] __might_sleep+0x12a/0x1e0
>  [<ffffffff81321dbc>] mutex_lock_nested+0x3c/0x340
>  [<ffffffff81053a8c>] ? __run_hrtimer+0x4c/0x100
>  [<ffffffff810bd920>] ? vmevent_read+0x100/0x100
>  [<ffffffff810bd79e>] vmevent_sample+0x6e/0xf0
>  [<ffffffff810bd946>] vmevent_timer_fn+0x26/0x60
>  [<ffffffff81053a92>] __run_hrtimer+0x52/0x100
>  [<ffffffff81054463>] hrtimer_interrupt+0xf3/0x220
>  [<ffffffff810166d4>] smp_apic_timer_interrupt+0x64/0xa0
>  [<ffffffff81325a30>] apic_timer_interrupt+0x70/0x80
>  <EOI>  [<ffffffff8101ca3a>] ? do_page_fault+0x27a/0x450
>  [<ffffffff8101ca35>] ? do_page_fault+0x275/0x450
>  [<ffffffff810036bf>] ? do_softirq+0x6f/0xc0
>  [<ffffffff8132485d>] ? retint_restore_args+0xe/0xe
>  [<ffffffff8132484a>] ? retint_swapgs+0xe/0x13
>  [<ffffffff8116b31d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff81324a3f>] page_fault+0x1f/0x30
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
> 
> The patch is for git://github.com/penberg/linux.git vmevent/core.
> 
>  mm/vmevent.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index 1375f9d..1dbefb5 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -71,8 +71,6 @@ static void vmevent_sample(struct vmevent_watch *watch)
>  	if (!vmevent_match(watch, &event))
>  		return;
>  
> -	mutex_lock(&watch->mutex);
> -
>  	watch->pending = true;
>  
>  	if (watch->config.event_attrs & VMEVENT_EATTR_NR_AVAIL_PAGES)
> @@ -85,8 +83,6 @@ static void vmevent_sample(struct vmevent_watch *watch)
>  		watch->attr_values[n++] = event.nr_swap_pages;
>  
>  	watch->nr_attrs = n;
> -
> -	mutex_unlock(&watch->mutex);
>  }

Why do you think the mutex is not needed? Surely we need to synchronize 
vmevent_sample() against vmevent_read(), for example.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
