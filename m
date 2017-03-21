Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 237A86B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 05:28:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e126so48945299pfg.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:28:27 -0700 (PDT)
Received: from out0-139.mail.aliyun.com (out0-139.mail.aliyun.com. [140.205.0.139])
        by mx.google.com with ESMTP id 1si20678509plu.161.2017.03.21.02.28.25
        for <linux-mm@kvack.org>;
        Tue, 21 Mar 2017 02:28:26 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170321091026.139655-1-dvyukov@google.com>
In-Reply-To: <20170321091026.139655-1-dvyukov@google.com>
Subject: Re: [PATCH] kcov: simplify interrupt check
Date: Tue, 21 Mar 2017 17:28:19 +0800
Message-ID: <005501d2a225$7ab66870$70233950$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dmitry Vyukov' <dvyukov@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: 'Kefeng Wang' <wangkefeng.wang@huawei.com>, 'James Morse' <james.morse@arm.com>, 'Alexander Popov' <alex.popov@linux.com>, 'Andrey Konovalov' <andreyknvl@google.com>, linux-kernel@vger.kernel.org, syzkaller@googlegroups.com


On March 21, 2017 5:10 PM Dmitry Vyukov wrote: 
> 
> @@ -60,15 +60,8 @@ void notrace __sanitizer_cov_trace_pc(void)
>  	/*
>  	 * We are interested in code coverage as a function of a syscall inputs,
>  	 * so we ignore code executed in interrupts.
> -	 * The checks for whether we are in an interrupt are open-coded, because
> -	 * 1. We can't use in_interrupt() here, since it also returns true
> -	 *    when we are inside local_bh_disable() section.
> -	 * 2. We don't want to use (in_irq() | in_serving_softirq() | in_nmi()),
> -	 *    since that leads to slower generated code (three separate tests,
> -	 *    one for each of the flags).
>  	 */
> -	if (!t || (preempt_count() & (HARDIRQ_MASK | SOFTIRQ_OFFSET
> -							| NMI_MASK)))
> +	if (!t || !in_task())
>  		return;

Nit: can we get the current task check cut off?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
