Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA2226B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 15:07:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v77so1533729wrc.18
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 12:07:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c16si1304253wrc.322.2018.04.11.12.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 12:07:33 -0700 (PDT)
Date: Wed, 11 Apr 2018 21:07:30 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
Message-ID: <20180411190729.7sbmbsxtkcng7ddx@linutronix.de>
References: <20180411095757.28585-1-bigeasy@linutronix.de>
 <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
 <20180411140913.GE793541@devbig577.frc2.facebook.com>
 <20180411144221.o3v73v536tpnc6n3@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180411144221.o3v73v536tpnc6n3@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On 2018-04-11 16:42:21 [+0200], To Tejun Heo wrote:
> > > So is this perhaps related to the cpu hotplug that [1] mentions? e.g. is
> > > the cpu being hotplugged cpu 1, the worker started too early before
> > > stuff can be scheduled on the CPU, so it has to run on different than
> > > designated CPU?
> > > 
> > > [1] https://marc.info/?l=linux-mm&m=152088260625433&w=2
> > 
> > The report says that it happens when hotplug is attempted.  Per-cpu
> > doesn't pin the cpu alive, so if the cpu goes down while a work item
> > is in flight or a work item is queued while a cpu is offline it'll end
> > up executing on some other cpu.  So, if a piece of code doesn't want
> > that happening, it gotta interlock itself - ie. start queueing when
> > the cpu comes online and flush and prevent further queueing when its
> > cpu goes down.
> 
> I missed that cpuhotplug part while reading it. So in that case, let me
> add a CPU-hotplug notifier which cancels that work. After all it is not
> need once the CPU is gone.

This already happens:
- vmstat_shepherd() does get_online_cpus() and within this block it does
  queue_delayed_work_on(). So this has to wait until cpuhotplug
  completed before it can schedule something and then it won't schedule
  anything on the "off" CPU.

- The work item itself (vmstat_update()) schedules itself
  (conditionally) again.

- vmstat_cpu_down_prep() is the down event and does
  cancel_delayed_work_sync(). So it waits for the work-item to complete
  and cancels it.

This looks all good to me.

> > Thanks.

Sebastian
