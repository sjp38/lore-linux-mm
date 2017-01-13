Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 166396B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:02:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so100260037pfb.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 21:02:34 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b1si11499071pld.129.2017.01.12.21.02.32
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 21:02:33 -0800 (PST)
Date: Fri, 13 Jan 2017 14:02:29 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170113050229.GD3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <CAJhGHyBDBUfqeihNMui2doQPet4q8XsORT-t+mQ2F0ang8sn5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJhGHyBDBUfqeihNMui2doQPet4q8XsORT-t+mQ2F0ang8sn5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <jiangshanlai+lkml@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Boqun Feng <boqun.feng@gmail.com>, kirill@shutemov.name, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Jan 13, 2017 at 12:39:04PM +0800, Lai Jiangshan wrote:
> > +
> > +/*
> > + * No contention. Irq disable is only required.
> > + */
> > +static int same_context_plock(struct pend_lock *plock)
> > +{
> > +       struct task_struct *curr = current;
> > +       int cpu = smp_processor_id();
> > +
> > +       /* In the case of hardirq context */
> > +       if (curr->hardirq_context) {
> > +               if (plock->hardirq_id != per_cpu(hardirq_id, cpu) ||
> > +                   plock->hardirq_context != curr->hardirq_context)
> > +                       return 0;
> > +       /* In the case of softriq context */
> > +       } else if (curr->softirq_context) {
> > +               if (plock->softirq_id != per_cpu(softirq_id, cpu) ||
> > +                   plock->softirq_context != curr->softirq_context)
> > +                       return 0;
> > +       /* In the case of process context */
> > +       } else {
> > +               if (plock->hardirq_context != 0 ||
> > +                   plock->softirq_context != 0)
> > +                       return 0;
> > +       }
> > +       return 1;
> > +}
> >
> 
> I have not read the code yet...
> but different work functions in workqueues are different "contexts" IMO,
> does commit operation work well in work functions?

Hello,

Yes. I also think it should be considered since each work might be run in
different context from another, thanks to concurrency support of workqueue.
I will reflect it.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
