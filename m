Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 593746B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 15:53:09 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id v14-v6so6367390ybq.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:53:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w74-v6sor1087722ybe.189.2018.04.10.12.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 12:53:08 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:53:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] mm, slab: reschedule cache_reap() on the same CPU
Message-ID: <20180410195247.GQ3126663@devbig577.frc2.facebook.com>
References: <20180410081531.18053-1-vbabka@suse.cz>
 <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
 <983c61d1-1444-db1f-65c1-3b519ac4d57b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <983c61d1-1444-db1f-65c1-3b519ac4d57b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

Hello,

On Tue, Apr 10, 2018 at 09:40:19PM +0200, Vlastimil Babka wrote:
> On 04/10/2018 04:12 PM, Christopher Lameter wrote:
> > On Tue, 10 Apr 2018, Vlastimil Babka wrote:
> > 
> >> cache_reap() is initially scheduled in start_cpu_timer() via
> >> schedule_delayed_work_on(). But then the next iterations are scheduled via
> >> schedule_delayed_work(), thus using WORK_CPU_UNBOUND.
> > 
> > That is a bug.. cache_reap must run on the same cpu since it deals with
> > the per cpu queues of the current cpu. Scheduled_delayed_work() used to
> > guarantee running on teh same cpu.
> 
> Did it? When did it stop? (which stable kernels should we backport to?)

It goes back to v4.5 - ef557180447f ("workqueue: schedule
WORK_CPU_UNBOUND work on wq_unbound_cpumask CPUs") which made
WQ_CPU_UNBOUND on percpu workqueues honor wq_unbound_cpusmask so that
cpu isolation works better.  Unless the force_rr option or
unbound_cpumask is set, it still follows local cpu.

> So is my assumption correct that without specifying a CPU, the next work
> might be processed on a different cpu than the current one, *and also*
> be executed with a kthread/u* that can migrate to another cpu *in the
> middle of the work*? Tejun?

For percpu work items, they'll keep executing on the same cpu it
started on unless the cpu goes down while executing.

> > schedule_delayed_work_on(smp_processor_id(), work, round_jiffies_relative(REAPTIMEOUT_AC));
> > 
> > instead all of the other changes?
> 
> If we can rely on that 100%, sure.

Yeah, you can.

Thanks.

-- 
tejun
