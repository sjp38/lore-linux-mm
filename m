Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B6AE66B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:58:03 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2074337pab.28
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:58:03 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id gx10si4281056pbd.136.2014.10.22.09.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 09:57:55 -0700 (PDT)
Message-ID: <5447E210.8020902@codeaurora.org>
Date: Wed, 22 Oct 2014 09:57:52 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Deadlock with CMA and CPU hotplug
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, m.szyprowski@samsung.com, mina86@mina86.com
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, pratikp@codeaurora.org

Hi,

We've run into a AB/BA deadlock situation involving a driver lock and
the CPU hotplug lock on a 3.10 based kernel. The situation is this:

CPU 0				CPU 1
-----				----
Start CPU hotplug
mutex_lock(&cpu_hotplug.lock)
Run CPU hotplug notifier
				data for driver comes in
				mutex_lock(&driver_lock)
				driver calls dma_alloc_coherent
				alloc_contig_range
				lru_add_drain_all
				get_online_cpus()
				mutex_lock(&cpu_hotplug.lock)

Driver hotplug notifier runs
mutex_lock(&driver_lock)

The driver itself is out of tree right now[1] and we're looking at
ways to rework the driver. The best option for rework right now
though might result in some performance penalties. The size that's
being allocated can't easily be converted to an atomic allocation either
It seems like this might be a limitation of where CMA/
dma_alloc_coherent could potentially be used and make drivers
unnecessarily aware of CPU hotplug locking.

Does this seem like an actual problem that needs to be fixed or
is trying to use CMA in a CPU hotplug notifier path just asking
for trouble?

Thanks,
Laura

[1] For reference, the driver is a version of
https://lkml.org/lkml/2014/10/7/495 although that particular
posted version allocates memory at probe instead of runtime
and probably doesn't have the deadlock.

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
