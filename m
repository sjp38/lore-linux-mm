Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05F5BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:17:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A09CB21530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:17:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A09CB21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49D126B0003; Wed,  8 May 2019 15:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44DB96B0008; Wed,  8 May 2019 15:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33B896B000A; Wed,  8 May 2019 15:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 137146B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 15:17:35 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y10so17296444qti.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0kdIQjk//0xqcb6A/0Yr0ORd0uksJmGe+eWDxma7AG0=;
        b=aqOzF5ouB2xuAK+coiH5iEyx6ZEPkFUpUoJ1WdfR5sYv9PoMctwkZo1ZGMgkncI+VQ
         sG6RJM4ybBtBdINOJ20dLqRjVZiIeyJ4f+kDOhFKloCaWUhvVmoXF4Thm/SSUC6Wo4tW
         NuSh0S0qQyrbPJ81uiqy0I00dIyqs9EA51ScfDABRHxRORHRN5Q2m/dKqPnSrHO8Sm8X
         LH1vrQd7HReEjOLfR11OvAwsCNQ74JiLFfsjp4AEDn7+zukRJw9gcUfMokzLSoUCpUpj
         QzjUfViHbndmMoMAf4BJuMZJyOFRL++JAMInBExzEcXzOEVUgohVMDGMJQDdPQSgeKc9
         tuaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVzGsne/09iR8Z0UhilPoqLc2qlEIPAfiT5OCfCwSKmC/frdJ9A
	49odklUhLBmvICmeVVFzNm0NHm2sdjdnRasRBohQAKJM2akYbwCO+1prqYLPnL12yPcVjwH2PMc
	Q4I5gDmcXITT/bzPAR6aUPHqSAXWcstw9DeGMbIuWZZ+JCJTN2Xzb8tWaBHKeNJk=
X-Received: by 2002:ac8:2bcc:: with SMTP id n12mr34106726qtn.53.1557343054769;
        Wed, 08 May 2019 12:17:34 -0700 (PDT)
X-Received: by 2002:ac8:2bcc:: with SMTP id n12mr34106666qtn.53.1557343054035;
        Wed, 08 May 2019 12:17:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557343054; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsRiC/O0IHWol8mcZrIg+2sUbt1hkXmkvTzBUkYN5dgdkm3m/2Q3oiNANKxIrJNn+1
         KIsp/Nuq79JzwAOMQEw5U+2AWf9psLKAtx8SqESPqCPdppeABH9I48VZfLruMpyocw7e
         poBZPlO478K6Xk44JRETAlamM338vO66ZzEQ4uutKMhu1llNQ/6O207sadyxtFlZHqi0
         JUGx0A+OJv+c4eJl+3XOAQE2j6e5Vt1zHIXEqSWxykI0BFvNxSYPv0Rg4SoioAHERkYe
         QWd39Ur6daq2q9TSxft7vHM7EOugte1fmbm77F1811XaUWxWPTHNoWm7OvgiwkfkdiYm
         Ru2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0kdIQjk//0xqcb6A/0Yr0ORd0uksJmGe+eWDxma7AG0=;
        b=MkKh4IPapDH0e/al7qny5/RZB3llDOojObVNayWEOsYovXBjTILEkOPCnT2Po1EX2H
         H2MVrpGIcWSuNb0MzJaNJ1Fvi2pXNSA5YjtJp3VqFrDe25UdJCgCUT1XQpkniHHkXnsa
         PUz6n/zuGMilrTaRXr9JydJgOY+1iZIvvWWguv9rI3gODOEk5xo18GJYu3gAvzTYpSDX
         gLJwGB/VnT9JObOp+K/DZM2Vvfmv3HVxgisplUR/00817OR+O2p5VOZYNJsuNTsfK3/H
         oVhtuFDgfz1Arr1qun9YND8sUh0shKnGoDp5QTxEv8lYO2GvBgUc37EazEeHu0pMs8kO
         PMkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a26sor23812353qtm.58.2019.05.08.12.17.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 12:17:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwxNSMPXQw3rLV5LcPRdEhWIgrK1z6TGwVAc/D69xGcgY8eghOJIKmj63uPk/1r1ILamScA+A==
X-Received: by 2002:ac8:45da:: with SMTP id e26mr11693961qto.235.1557343053689;
        Wed, 08 May 2019 12:17:33 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::1:9ddb])
        by smtp.gmail.com with ESMTPSA id r4sm9962317qkb.20.2019.05.08.12.17.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 12:17:32 -0700 (PDT)
Date: Wed, 8 May 2019 15:17:31 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Dennis Zhou <dennis@kernel.org>, Alexei Starovoitov <ast@fb.com>,
	John Sperbeck <jsperbeck@google.com>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] percpu: remove spurious lock dependency between percpu
 and sched
Message-ID: <20190508191731.GA71205@dennisz-mbp>
References: <20190508014320.55404-1-jsperbeck@google.com>
 <20190508185932.GA68786@dennisz-mbp>
 <CANn89iJa7qLqDjQOV9y_f3jsLogv9K0j1x=+eViKa2MQEcEjBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iJa7qLqDjQOV9y_f3jsLogv9K0j1x=+eViKa2MQEcEjBw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 12:04:08PM -0700, Eric Dumazet wrote:
> On Wed, May 8, 2019 at 11:59 AM Dennis Zhou <dennis@kernel.org> wrote:
> >
> > On Tue, May 07, 2019 at 06:43:20PM -0700, John Sperbeck wrote:
> > > In free_percpu() we sometimes call pcpu_schedule_balance_work() to
> > > queue a work item (which does a wakeup) while holding pcpu_lock.
> > > This creates an unnecessary lock dependency between pcpu_lock and
> > > the scheduler's pi_lock.  There are other places where we call
> > > pcpu_schedule_balance_work() without hold pcpu_lock, and this case
> > > doesn't need to be different.
> > >
> > > Moving the call outside the lock prevents the following lockdep splat
> > > when running tools/testing/selftests/bpf/{test_maps,test_progs} in
> > > sequence with lockdep enabled:
> > >
> > > ======================================================
> > > WARNING: possible circular locking dependency detected
> > > 5.1.0-dbg-DEV #1 Not tainted
> > > ------------------------------------------------------
> > > kworker/23:255/18872 is trying to acquire lock:
> > > 000000000bc79290 (&(&pool->lock)->rlock){-.-.}, at: __queue_work+0xb2/0x520
> > >
> > > but task is already holding lock:
> > > 00000000e3e7a6aa (pcpu_lock){..-.}, at: free_percpu+0x36/0x260
> > >
> > > which lock already depends on the new lock.
> > >
> > > the existing dependency chain (in reverse order) is:
> > >
> > > -> #4 (pcpu_lock){..-.}:
> > >        lock_acquire+0x9e/0x180
> > >        _raw_spin_lock_irqsave+0x3a/0x50
> > >        pcpu_alloc+0xfa/0x780
> > >        __alloc_percpu_gfp+0x12/0x20
> > >        alloc_htab_elem+0x184/0x2b0
> > >        __htab_percpu_map_update_elem+0x252/0x290
> > >        bpf_percpu_hash_update+0x7c/0x130
> > >        __do_sys_bpf+0x1912/0x1be0
> > >        __x64_sys_bpf+0x1a/0x20
> > >        do_syscall_64+0x59/0x400
> > >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > >
> > > -> #3 (&htab->buckets[i].lock){....}:
> > >        lock_acquire+0x9e/0x180
> > >        _raw_spin_lock_irqsave+0x3a/0x50
> > >        htab_map_update_elem+0x1af/0x3a0
> > >
> > > -> #2 (&rq->lock){-.-.}:
> > >        lock_acquire+0x9e/0x180
> > >        _raw_spin_lock+0x2f/0x40
> > >        task_fork_fair+0x37/0x160
> > >        sched_fork+0x211/0x310
> > >        copy_process.part.43+0x7b1/0x2160
> > >        _do_fork+0xda/0x6b0
> > >        kernel_thread+0x29/0x30
> > >        rest_init+0x22/0x260
> > >        arch_call_rest_init+0xe/0x10
> > >        start_kernel+0x4fd/0x520
> > >        x86_64_start_reservations+0x24/0x26
> > >        x86_64_start_kernel+0x6f/0x72
> > >        secondary_startup_64+0xa4/0xb0
> > >
> > > -> #1 (&p->pi_lock){-.-.}:
> > >        lock_acquire+0x9e/0x180
> > >        _raw_spin_lock_irqsave+0x3a/0x50
> > >        try_to_wake_up+0x41/0x600
> > >        wake_up_process+0x15/0x20
> > >        create_worker+0x16b/0x1e0
> > >        workqueue_init+0x279/0x2ee
> > >        kernel_init_freeable+0xf7/0x288
> > >        kernel_init+0xf/0x180
> > >        ret_from_fork+0x24/0x30
> > >
> > > -> #0 (&(&pool->lock)->rlock){-.-.}:
> > >        __lock_acquire+0x101f/0x12a0
> > >        lock_acquire+0x9e/0x180
> > >        _raw_spin_lock+0x2f/0x40
> > >        __queue_work+0xb2/0x520
> > >        queue_work_on+0x38/0x80
> > >        free_percpu+0x221/0x260
> > >        pcpu_freelist_destroy+0x11/0x20
> > >        stack_map_free+0x2a/0x40
> > >        bpf_map_free_deferred+0x3c/0x50
> > >        process_one_work+0x1f7/0x580
> > >        worker_thread+0x54/0x410
> > >        kthread+0x10f/0x150
> > >        ret_from_fork+0x24/0x30
> > >
> > > other info that might help us debug this:
> > >
> > > Chain exists of:
> > >   &(&pool->lock)->rlock --> &htab->buckets[i].lock --> pcpu_lock
> > >
> > >  Possible unsafe locking scenario:
> > >
> > >        CPU0                    CPU1
> > >        ----                    ----
> > >   lock(pcpu_lock);
> > >                                lock(&htab->buckets[i].lock);
> > >                                lock(pcpu_lock);
> > >   lock(&(&pool->lock)->rlock);
> > >
> > >  *** DEADLOCK ***
> > >
> > > 3 locks held by kworker/23:255/18872:
> > >  #0: 00000000b36a6e16 ((wq_completion)events){+.+.},
> > >      at: process_one_work+0x17a/0x580
> > >  #1: 00000000dfd966f0 ((work_completion)(&map->work)){+.+.},
> > >      at: process_one_work+0x17a/0x580
> > >  #2: 00000000e3e7a6aa (pcpu_lock){..-.},
> > >      at: free_percpu+0x36/0x260
> > >
> > > stack backtrace:
> > > CPU: 23 PID: 18872 Comm: kworker/23:255 Not tainted 5.1.0-dbg-DEV #1
> > > Hardware name: ...
> > > Workqueue: events bpf_map_free_deferred
> > > Call Trace:
> > >  dump_stack+0x67/0x95
> > >  print_circular_bug.isra.38+0x1c6/0x220
> > >  check_prev_add.constprop.50+0x9f6/0xd20
> > >  __lock_acquire+0x101f/0x12a0
> > >  lock_acquire+0x9e/0x180
> > >  _raw_spin_lock+0x2f/0x40
> > >  __queue_work+0xb2/0x520
> > >  queue_work_on+0x38/0x80
> > >  free_percpu+0x221/0x260
> > >  pcpu_freelist_destroy+0x11/0x20
> > >  stack_map_free+0x2a/0x40
> > >  bpf_map_free_deferred+0x3c/0x50
> > >  process_one_work+0x1f7/0x580
> > >  worker_thread+0x54/0x410
> > >  kthread+0x10f/0x150
> > >  ret_from_fork+0x24/0x30
> > >
> > > Signed-off-by: John Sperbeck <jsperbeck@google.com>
> > > ---
> > >  mm/percpu.c | 6 +++++-
> > >  1 file changed, 5 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/mm/percpu.c b/mm/percpu.c
> > > index 68dd2e7e73b5..d832793bf83a 100644
> > > --- a/mm/percpu.c
> > > +++ b/mm/percpu.c
> > > @@ -1738,6 +1738,7 @@ void free_percpu(void __percpu *ptr)
> > >       struct pcpu_chunk *chunk;
> > >       unsigned long flags;
> > >       int off;
> > > +     bool need_balance = false;
> > >
> > >       if (!ptr)
> > >               return;
> > > @@ -1759,7 +1760,7 @@ void free_percpu(void __percpu *ptr)
> > >
> > >               list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
> > >                       if (pos != chunk) {
> > > -                             pcpu_schedule_balance_work();
> > > +                             need_balance = true;
> > >                               break;
> > >                       }
> > >       }
> > > @@ -1767,6 +1768,9 @@ void free_percpu(void __percpu *ptr)
> > >       trace_percpu_free_percpu(chunk->base_addr, off, ptr);
> > >
> > >       spin_unlock_irqrestore(&pcpu_lock, flags);
> > > +
> > > +     if (need_balance)
> > > +             pcpu_schedule_balance_work();
> > >  }
> > >  EXPORT_SYMBOL_GPL(free_percpu);
> > >
> > > --
> > > 2.21.0.1020.gf2820cf01a-goog
> > >
> >
> > Hi John,
> >
> > The free_percpu() function hasn't changed in a little under 2 years. So,
> > either lockdep has gotten smarter or something else has changed. There
> > was a workqueue change recently merged: 6d25be5782e4 ("sched/core,
> > workqueues: Distangle worker accounting from rq lock"). Would you mind
> > reverting this and then seeing if you still encounter deadlock?
> >
> 
> We have the issue even without 6d25be5782e4 in the picture.
> 
> I sent the splat months ago to Alexei, because I thought it was BPF
> related at first

Ah I see. Great, I've applied this to for-5.2.

Thanks,
Dennis

