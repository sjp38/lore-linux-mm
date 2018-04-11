Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 766CC6B0006
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 10:09:17 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id m75so880293ywd.23
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 07:09:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u127sor283897ywg.104.2018.04.11.07.09.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 07:09:16 -0700 (PDT)
Date: Wed, 11 Apr 2018 07:09:13 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
Message-ID: <20180411140913.GE793541@devbig577.frc2.facebook.com>
References: <20180411095757.28585-1-bigeasy@linutronix.de>
 <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

Hello,

On Wed, Apr 11, 2018 at 03:56:43PM +0200, Vlastimil Babka wrote:
> > vmstat_update() is invoked by a kworker on a specific CPU. This worker
> > it bound to this CPU. The name of the worker was "kworker/1:1" so it
> > should have been a worker which was bound to CPU1. A worker which can
> > run on any CPU would have a `u' before the first digit.
> 
> Oh my, and I have just been assured by Tejun that his cannot happen :)
> And yet, in the original report [1] I see:
> 
> CPU: 0 PID: 269 Comm: kworker/1:1 Not tainted
> 
> So is this perhaps related to the cpu hotplug that [1] mentions? e.g. is
> the cpu being hotplugged cpu 1, the worker started too early before
> stuff can be scheduled on the CPU, so it has to run on different than
> designated CPU?
> 
> [1] https://marc.info/?l=linux-mm&m=152088260625433&w=2

The report says that it happens when hotplug is attempted.  Per-cpu
doesn't pin the cpu alive, so if the cpu goes down while a work item
is in flight or a work item is queued while a cpu is offline it'll end
up executing on some other cpu.  So, if a piece of code doesn't want
that happening, it gotta interlock itself - ie. start queueing when
the cpu comes online and flush and prevent further queueing when its
cpu goes down.

Thanks.

-- 
tejun
