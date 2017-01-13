Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F93B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:39:05 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 67so51091798ioh.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:39:05 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id a2si462415itd.61.2017.01.12.20.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 20:39:04 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id 101so4538895iom.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:39:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1481260331-360-8-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com> <1481260331-360-8-git-send-email-byungchul.park@lge.com>
From: Lai Jiangshan <jiangshanlai+lkml@gmail.com>
Date: Fri, 13 Jan 2017 12:39:04 +0800
Message-ID: <CAJhGHyBDBUfqeihNMui2doQPet4q8XsORT-t+mQ2F0ang8sn5g@mail.gmail.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Boqun Feng <boqun.feng@gmail.com>, kirill@shutemov.name, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

> +
> +/*
> + * No contention. Irq disable is only required.
> + */
> +static int same_context_plock(struct pend_lock *plock)
> +{
> +       struct task_struct *curr = current;
> +       int cpu = smp_processor_id();
> +
> +       /* In the case of hardirq context */
> +       if (curr->hardirq_context) {
> +               if (plock->hardirq_id != per_cpu(hardirq_id, cpu) ||
> +                   plock->hardirq_context != curr->hardirq_context)
> +                       return 0;
> +       /* In the case of softriq context */
> +       } else if (curr->softirq_context) {
> +               if (plock->softirq_id != per_cpu(softirq_id, cpu) ||
> +                   plock->softirq_context != curr->softirq_context)
> +                       return 0;
> +       /* In the case of process context */
> +       } else {
> +               if (plock->hardirq_context != 0 ||
> +                   plock->softirq_context != 0)
> +                       return 0;
> +       }
> +       return 1;
> +}
>

I have not read the code yet...
but different work functions in workqueues are different "contexts" IMO,
does commit operation work well in work functions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
