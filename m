Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C35716B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 05:58:41 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id b202so44264616vka.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:58:41 -0700 (PDT)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id o130si4237865vke.136.2017.03.21.02.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 02:58:40 -0700 (PDT)
Received: by mail-vk0-x22b.google.com with SMTP id x75so88773225vke.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:58:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <005501d2a225$7ab66870$70233950$@alibaba-inc.com>
References: <20170321091026.139655-1-dvyukov@google.com> <005501d2a225$7ab66870$70233950$@alibaba-inc.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 21 Mar 2017 10:58:19 +0100
Message-ID: <CACT4Y+Y90ZJj=FXn-Kdpk6uJ_=qq3NsiOwa1K+xwHDBdHf3MTQ@mail.gmail.com>
Subject: Re: [PATCH] kcov: simplify interrupt check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kefeng Wang <wangkefeng.wang@huawei.com>, James Morse <james.morse@arm.com>, Alexander Popov <alex.popov@linux.com>, Andrey Konovalov <andreyknvl@google.com>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>

On Tue, Mar 21, 2017 at 10:28 AM, Hillf Danton <hillf.zj@alibaba-inc.com> wrote:
>
> On March 21, 2017 5:10 PM Dmitry Vyukov wrote:
>>
>> @@ -60,15 +60,8 @@ void notrace __sanitizer_cov_trace_pc(void)
>>       /*
>>        * We are interested in code coverage as a function of a syscall inputs,
>>        * so we ignore code executed in interrupts.
>> -      * The checks for whether we are in an interrupt are open-coded, because
>> -      * 1. We can't use in_interrupt() here, since it also returns true
>> -      *    when we are inside local_bh_disable() section.
>> -      * 2. We don't want to use (in_irq() | in_serving_softirq() | in_nmi()),
>> -      *    since that leads to slower generated code (three separate tests,
>> -      *    one for each of the flags).
>>        */
>> -     if (!t || (preempt_count() & (HARDIRQ_MASK | SOFTIRQ_OFFSET
>> -                                                     | NMI_MASK)))
>> +     if (!t || !in_task())
>>               return;
>
> Nit: can we get the current task check cut off?


Humm... good question.
I don't remember why exactly I added it. I guess something was
crashing during boot. Note that this call is inserted into almost all
kernel code. But probably that was before I disabled instrumentation
of some early boot code for other reasons (with KCOV_INSTRUMENT := n
in Makefile), because now I can boot kernel in qemu without this
check. But I am still not sure about real hardware/arm/etc.
Does anybody know if current can ever (including early boot) return
invalid pointer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
