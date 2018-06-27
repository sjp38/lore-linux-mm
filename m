Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB856B0270
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:47:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q12-v6so2532131wmf.9
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:47:11 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h30-v6si562518wrh.248.2018.06.27.05.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 05:47:09 -0700 (PDT)
Date: Wed, 27 Jun 2018 14:47:06 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
Message-ID: <20180627124706.g33vlaku7xa4veqq@linutronix.de>
References: <20180411095757.28585-1-bigeasy@linutronix.de>
 <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
 <20180411140913.GE793541@devbig577.frc2.facebook.com>
 <20180411144221.o3v73v536tpnc6n3@linutronix.de>
 <20180411190729.7sbmbsxtkcng7ddx@linutronix.de>
 <20180627123657.2hb7ow4szjyhg5aj@home.goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180627123657.2hb7ow4szjyhg5aj@home.goodmis.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <htejun@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On 2018-06-27 08:36:57 [-0400], Steven Rostedt wrote:
> On Wed, Apr 11, 2018 at 09:07:30PM +0200, Sebastian Andrzej Siewior wrote:
> > 
> > This already happens:
> > - vmstat_shepherd() does get_online_cpus() and within this block it does
> >   queue_delayed_work_on(). So this has to wait until cpuhotplug
> >   completed before it can schedule something and then it won't schedule
> >   anything on the "off" CPU.
> 
> But can't we have something like this happen: ?
> 
> 	CPU0			CPU1			CPU2
> 	----			----			----
>  get_online_cpus()
>  queue_work(vmstat_update, cpu1)
>     wakeup(kworker/1)
> 			     High prio task running
>  put_online_cpus()
>  						     Shutdown CPU 1
> 			     migrate kworker/1
>  schedule kworker/1
>  (smp_processor_id() != 1)

I don't get CPU1 doing in here. kworker/1 should not be migrated to
begin with. The work item should be done before CPU2 shutdowns CPU1 (or
0) because vmstat_cpu_down_prep() cancels the work while the CPUs goes
down so it should not be migrated. Also, the work is enqueued while
holding the CPU HP lock.

Sebastian
