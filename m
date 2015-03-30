Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id E74D36B006E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:14:23 -0400 (EDT)
Received: by oicf142 with SMTP id f142so118795216oic.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 06:14:23 -0700 (PDT)
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com. [209.85.214.182])
        by mx.google.com with ESMTPS id x198si5852554oia.88.2015.03.30.06.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 06:14:23 -0700 (PDT)
Received: by obbgh1 with SMTP id gh1so58242534obb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 06:14:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150330124746.GI21418@twins.programming.kicks-ass.net>
References: <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
	<20150328095322.GH27490@worktop.programming.kicks-ass.net>
	<55169723.3070006@linaro.org>
	<20150328134457.GK27490@worktop.programming.kicks-ass.net>
	<20150329102440.GC32047@worktop.ger.corp.intel.com>
	<CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
	<20150330124746.GI21418@twins.programming.kicks-ass.net>
Date: Mon, 30 Mar 2015 18:44:22 +0530
Message-ID: <CAKohpo=2_v8n+tnrEbb4bYAxU8cgA+OWpTNe8XX3yjpzL4ySGw@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 30 March 2015 at 18:17, Peter Zijlstra <peterz@infradead.org> wrote:
> No, I means something else with that. We can remove the
> tvec_base::running_timer field. Everything that uses that can use
> tbase_running() AFAICT.

Okay, there is one instance which still needs it.

migrate_timers():

        BUG_ON(old_base->running_timer);

What I wasn't sure about it is if we get can drop this statement or not.
If we decide not to drop it, then we can convert running_timer into a bool.

> Drop yes, racy not so much I think.
>
>
> diff --git a/kernel/time/timer.c b/kernel/time/timer.c
> index 2d3f5c504939..1394f9540348 100644
> --- a/kernel/time/timer.c
> +++ b/kernel/time/timer.c
> @@ -1189,12 +1189,39 @@ static inline void __run_timers(struct tvec_base *base)
>                         cascade(base, &base->tv5, INDEX(3));
>                 ++base->timer_jiffies;
>                 list_replace_init(base->tv1.vec + index, head);
> +
> +again:
>                 while (!list_empty(head)) {
>                         void (*fn)(unsigned long);
>                         unsigned long data;
>                         bool irqsafe;
>
> -                       timer = list_first_entry(head, struct timer_list,entry);
> +                       timer = list_first_entry(head, struct timer_list, entry);
> +                       if (unlikely(tbase_running(timer))) {
> +                               /* Only one timer on the list, force wait. */
> +                               if (unlikely(head->next == head->prev)) {
> +                                       spin_unlock(&base->lock);
> +
> +                                       /*
> +                                        * The only way to get here is if the
> +                                        * handler requeued itself on another
> +                                        * base, this guarantees the timer will
> +                                        * not go away.
> +                                        */
> +                                       while (tbase_running(timer))
> +                                               cpu_relax();
> +
> +                                       spin_lock(&base->lock);
> +                               } else  {
> +                                       /*
> +                                        * Otherwise, rotate the list and try
> +                                        * someone else.
> +                                        */
> +                                       list_move_tail(&timer->entry, head);
> +                               }
> +                               goto again;
> +                       }
> +
>                         fn = timer->function;
>                         data = timer->data;
>                         irqsafe = tbase_get_irqsafe(timer->base);

Yeah, so I have written something similar only. Wasn't sure about what you wrote
earlier. Thanks for the clarification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
