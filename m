Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E10746B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 12:09:26 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so33151079qge.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:09:26 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id q201si6034678qha.62.2015.08.05.09.09.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 09:09:25 -0700 (PDT)
Date: Wed, 5 Aug 2015 11:09:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <55C18D2E.4030009@rjmx.net>
Message-ID: <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net>
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.11.1508051105072.29534@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

> [1.] One line summary of the problem:
>     4.1.4 -- Kernel Panic on shutdown

This is a kfree of an object that was not allocated via the slab
allocators or was already freed. If you boot with the kernel command line
argument "slub_debug" then you could get some more information. Could also
be that memory was somehow corrupted.

The backtrace shows that this is a call occurring in the
scheduler.

CCing scheduler developers.



Call Trace:
 <IRQ>
 [<ffffffff81072189>] free_sched_group+0x29/0x30
 [<ffffffff810721a0>] free_sched_group+rcu+0x10/0x20
 [<ffffffff81099771>] rcu_process_callbacks+0x231/0x510
 [<ffffffff81055cee>] __do_softirq+0xee/0x1e0
 [<ffffffff81055ef5>] irq_exit+0x55/0x60
 [<ffffffff810382f5>] smp_apic_timer_interrupt+0x45/0x60
 [<ffffffff815e4f5b>] apic_timer_interrupt+0x6b/0x70
 <EOI>
 [<ffffffff81071b61>] ? finish_task_switch+0x61/0x100
 [<ffffffff814ddc7d>] ? cpuidle_enter_state+0xad/0x170
 [<ffffffff814ddc76>] ? cpuidle_enter_state+0xa6/0x170
 [<ffffffff814ddd62>] cpuidle_enter+0x12/0x20
 [<ffffffff810883a8>] cpu_startup_entry+0x268/0x2e0
 [<ffffffff81036437>] start_secondary+0x167/0x170

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
