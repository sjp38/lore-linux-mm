Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDBF900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 05:49:27 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so330761pab.33
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 02:49:27 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id az17si777846pdb.198.2014.10.28.02.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 28 Oct 2014 02:49:26 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE500K1SFEYW190@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 28 Oct 2014 09:52:10 +0000 (GMT)
Message-id: <544F66A2.1080302@samsung.com>
Date: Tue, 28 Oct 2014 10:49:22 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: Deadlock with CMA and CPU hotplug
References: <5447E210.8020902@codeaurora.org>
In-reply-to: <5447E210.8020902@codeaurora.org>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, mgorman@suse.de, mina86@mina86.com
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, pratikp@codeaurora.org

Hello,

On 2014-10-22 18:57, Laura Abbott wrote:
> We've run into a AB/BA deadlock situation involving a driver lock and
> the CPU hotplug lock on a 3.10 based kernel. The situation is this:
>
> CPU 0                CPU 1
> -----                ----
> Start CPU hotplug
> mutex_lock(&cpu_hotplug.lock)
> Run CPU hotplug notifier
>                 data for driver comes in
>                 mutex_lock(&driver_lock)
>                 driver calls dma_alloc_coherent
>                 alloc_contig_range
>                 lru_add_drain_all
>                 get_online_cpus()
>                 mutex_lock(&cpu_hotplug.lock)
>
> Driver hotplug notifier runs
> mutex_lock(&driver_lock)
>
> The driver itself is out of tree right now[1] and we're looking at
> ways to rework the driver. The best option for rework right now
> though might result in some performance penalties. The size that's
> being allocated can't easily be converted to an atomic allocation either
> It seems like this might be a limitation of where CMA/
> dma_alloc_coherent could potentially be used and make drivers
> unnecessarily aware of CPU hotplug locking.
>
> Does this seem like an actual problem that needs to be fixed or
> is trying to use CMA in a CPU hotplug notifier path just asking
> for trouble?

IMHO doing any allocation without GFP_ATOMIC from a notifier is asking
for problems. I always considered notifiers as callbacks that might be 
called
directly from i.e. interrupts. I don't know much about your code, but 
maybe it
would be possible to move the problematic code from a notifier to a separate
worker or thread?

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
