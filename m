Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 833E56B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:10:30 -0400 (EDT)
Received: by iofl186 with SMTP id l186so66357543iof.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:10:30 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id p8si8544772ioi.159.2015.10.14.12.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 12:10:29 -0700 (PDT)
Received: by iodv82 with SMTP id v82so66194538iod.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:10:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1510141358460.13663@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<alpine.DEB.2.20.1510141301340.13301@east.gentwo.org>
	<CA+55aFwSjroKXPjsO90DWULy-H8e9Fs=ZDRVkJvQgAZPk1YYRw@mail.gmail.com>
	<alpine.DEB.2.20.1510141358460.13663@east.gentwo.org>
Date: Wed, 14 Oct 2015 12:10:29 -0700
Message-ID: <CA+55aFzhzLZ6jeRqiHrguUG3oXMCxMzoQiLNvgE92a8NBJfksQ@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 11:59 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 14 Oct 2015, Linus Torvalds wrote:
>
>> And "schedule_delayed_work()" uses WORK_CPU_UNBOUND.
>
> Uhhh. Someone changed that?

It always did.  This is from 2007:

int fastcall schedule_delayed_work(struct delayed_work *dwork,
                                        unsigned long delay)
{
        timer_stats_timer_set_start_info(&dwork->timer);
        return queue_delayed_work(keventd_wq, dwork, delay);
}
...
int fastcall queue_delayed_work(struct workqueue_struct *wq,
                        struct delayed_work *dwork, unsigned long delay)
{
        timer_stats_timer_set_start_info(&dwork->timer);
        if (delay == 0)
                return queue_work(wq, &dwork->work);

        return queue_delayed_work_on(-1, wq, dwork, delay);
}
...
int queue_delayed_work_on(int cpu, struct workqueue_struct *wq,
                        struct delayed_work *dwork, unsigned long delay)
{
....
                timer->function = delayed_work_timer_fn;

                if (unlikely(cpu >= 0))
                        add_timer_on(timer, cpu);
                else
                        add_timer(timer);
}
...
void delayed_work_timer_fn(unsigned long __data)
{
        int cpu = smp_processor_id();
        ...
        __queue_work(per_cpu_ptr(wq->cpu_wq, cpu), &dwork->work);
}


so notice how it always just used "add_timer()", and then queued it on
whatever cpu workqueue the timer ran on.

Now, 99.9% of the time, the timer is just added to the current CPU
queues, so yes, in practice it ended up running on the same CPU almost
all the time. There are exceptions (timers can get moved around, and
active timers end up staying on the CPU they were scheduled on when
they get updated, rather than get moved to the current cpu), but they
are hard to hit.

But the code clearly didn't do that "same CPU" intentionally, and just
going by naming of things I would also say that it was never implied.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
