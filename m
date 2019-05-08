Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453B3C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB91B216C4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ed6YBkns"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB91B216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89EC76B0005; Wed,  8 May 2019 15:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84DF76B0007; Wed,  8 May 2019 15:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764FE6B0008; Wed,  8 May 2019 15:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5411C6B0005
	for <linux-mm@kvack.org>; Wed,  8 May 2019 15:04:26 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k134so17586577ywe.7
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qjSy2g2nVVj6BCdNMVaDCCqCXAust5dkZBT7nTUp9+Y=;
        b=WXqWYi/S/7r1otFGd5Bl7Uq18pSdCek+ZndXmILD8cxxu3YxmJriMZ0HuiknkJoL1l
         ADDY1JkktrMUkI6aFcLLGC98WclH7rvoTs4AW4Zkcg3AMOCJD48c2oM9lPtIydHgbYoR
         3xG3wR1PhDF/tAm1gPsHeWy5PoEVxVOpmemIlKGnkaDTrTK1WRGPT/dChI2XA/wNMR44
         VxOOXRPfKYrBajoJYu43wWlJIxxm58wxwgWDI2e89JKHtA9nkszO2SQHGdVOCoiQn4NO
         o9usKMw+rdV5o0GNKfBrYvRXq4SsBdeg9b0NRonVclZPL6vMmmybN3WLhW/GH7u6i4Tp
         GZrQ==
X-Gm-Message-State: APjAAAWKddnv1vX2ufE9Ug41jWg1Jowvt3PItFN9Y429zbw0Qb6YsMn0
	dHd9IdzsaAGPdkQ8EoxXDlOWOAx7Qsec8v2w3+IUj3HItKrWuVz8YUGgRHbg0tKBfrtNR1a2gb2
	6LxksWWLluZ3XSQsAgK9UA+5SwG5d0LDMfOZzu2SQIYx9UAmtGunQV+ZycpoGvlXt7g==
X-Received: by 2002:a81:1ccc:: with SMTP id c195mr25314553ywc.372.1557342266028;
        Wed, 08 May 2019 12:04:26 -0700 (PDT)
X-Received: by 2002:a81:1ccc:: with SMTP id c195mr25314445ywc.372.1557342264629;
        Wed, 08 May 2019 12:04:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557342264; cv=none;
        d=google.com; s=arc-20160816;
        b=spCGmaHLZkeUs2Nz6+G3432SJZnedHPt8Fs5p7DON7N9RxVWp0hGqdiZpBGXyPSUfe
         ynER78KcsINtQIXQb/0aYpPHbcPll2Ua4OZ8nfYEGeyt+oVD3Oh5OwRMtuUd/ieqlb6t
         ts1FXU4p0mZePJYOsqdtSsPuv409ekEQcmwggFjoAqDS1gl1Q3k6TMMoKRAqHlK8AQbK
         g8W+hs30vKoDD10dB7Ypv9lZnZBW6J6Wvu8rmZqbD286rnBa7Rk8PRuMebFJerbdjrPw
         +Ah4NZOyezxlmJjY9rFopDcekNl90F5VSL8PnF0lYyADOrWWEF+GVjf0XTiC9KggOMIT
         Km+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qjSy2g2nVVj6BCdNMVaDCCqCXAust5dkZBT7nTUp9+Y=;
        b=db2ymf/W4r1StVOEu8KCnnz6jRtYtb5PID9r0OuoFjukIhfU5zkjljuf/OiOB5vNfj
         fZrob72vJz3Q8jk63coKfKL2RgwUrJaHheMcT2paGTT+wofuiSS8mSwm4rcPKjxoEX35
         csGxRNX/UB2Qf/QmQsWeJpHyzRcCo/C0OFK7MKTwkAocLzmBTx7enSkbTHWm5oSSlJCW
         GzstXKg9c93FbJheqezctb7PZzjWaN3QhWwlI4ClRM9aYuOqbu2hGtptNzzs0WDCjcrp
         NHlerXPlB+FVVTkP2dFrD3LjmTaIkJ3vYbk5WQ7wZaD+3TCbOzeumcsSijIrDXCiFjq0
         uOUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ed6YBkns;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor25920ywo.97.2019.05.08.12.04.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 12:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ed6YBkns;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qjSy2g2nVVj6BCdNMVaDCCqCXAust5dkZBT7nTUp9+Y=;
        b=Ed6YBkns1HRHDeVo6Z3Z7u0qlthRGEA/YbvoFs5FNS4sBcJhDmu/RlVV5YngZm8krj
         M2IAXv/DtHcB5qrWfcyKXTl06cZ22QXFcnsJ+kPtZxALlEkDwevdlgQ9oz5zTpuEQqZa
         O5ZoK6RMpVmgyFS6acCS7s9BOxKevhNUTIpRDJbSx/XpyTG/kNgGkLq8fHCHLA++d2Xn
         asDZ/55oWSJvp1UZgo+xI0bJimACzS5X5tMyh7t1ZwgHGAraYEf4tr/nMQjqvitdQDFf
         Am4QtCO6G4SSPtZjOgjgWeqbhTH1WQRM84u63IGOdM+beDLGPeU84nkhqmX5+Xy6919C
         SoHg==
X-Google-Smtp-Source: APXvYqyl6Ue36OX0phhFb9K9Rb1J4iCEcxIE0y0rWmQLjQ2LUQVdRt5SXrKyrZgqDK3Crp/Krk9/D1icbX5l9McFw60=
X-Received: by 2002:a81:2941:: with SMTP id p62mr11064125ywp.430.1557342263816;
 Wed, 08 May 2019 12:04:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190508014320.55404-1-jsperbeck@google.com> <20190508185932.GA68786@dennisz-mbp>
In-Reply-To: <20190508185932.GA68786@dennisz-mbp>
From: Eric Dumazet <edumazet@google.com>
Date: Wed, 8 May 2019 12:04:08 -0700
Message-ID: <CANn89iJa7qLqDjQOV9y_f3jsLogv9K0j1x=+eViKa2MQEcEjBw@mail.gmail.com>
Subject: Re: [PATCH] percpu: remove spurious lock dependency between percpu
 and sched
To: Dennis Zhou <dennis@kernel.org>, Alexei Starovoitov <ast@fb.com>
Cc: John Sperbeck <jsperbeck@google.com>, Tejun Heo <tj@kernel.org>, 
	Christoph Lameter <cl@linux.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 11:59 AM Dennis Zhou <dennis@kernel.org> wrote:
>
> On Tue, May 07, 2019 at 06:43:20PM -0700, John Sperbeck wrote:
> > In free_percpu() we sometimes call pcpu_schedule_balance_work() to
> > queue a work item (which does a wakeup) while holding pcpu_lock.
> > This creates an unnecessary lock dependency between pcpu_lock and
> > the scheduler's pi_lock.  There are other places where we call
> > pcpu_schedule_balance_work() without hold pcpu_lock, and this case
> > doesn't need to be different.
> >
> > Moving the call outside the lock prevents the following lockdep splat
> > when running tools/testing/selftests/bpf/{test_maps,test_progs} in
> > sequence with lockdep enabled:
> >
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 5.1.0-dbg-DEV #1 Not tainted
> > ------------------------------------------------------
> > kworker/23:255/18872 is trying to acquire lock:
> > 000000000bc79290 (&(&pool->lock)->rlock){-.-.}, at: __queue_work+0xb2/0x520
> >
> > but task is already holding lock:
> > 00000000e3e7a6aa (pcpu_lock){..-.}, at: free_percpu+0x36/0x260
> >
> > which lock already depends on the new lock.
> >
> > the existing dependency chain (in reverse order) is:
> >
> > -> #4 (pcpu_lock){..-.}:
> >        lock_acquire+0x9e/0x180
> >        _raw_spin_lock_irqsave+0x3a/0x50
> >        pcpu_alloc+0xfa/0x780
> >        __alloc_percpu_gfp+0x12/0x20
> >        alloc_htab_elem+0x184/0x2b0
> >        __htab_percpu_map_update_elem+0x252/0x290
> >        bpf_percpu_hash_update+0x7c/0x130
> >        __do_sys_bpf+0x1912/0x1be0
> >        __x64_sys_bpf+0x1a/0x20
> >        do_syscall_64+0x59/0x400
> >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > -> #3 (&htab->buckets[i].lock){....}:
> >        lock_acquire+0x9e/0x180
> >        _raw_spin_lock_irqsave+0x3a/0x50
> >        htab_map_update_elem+0x1af/0x3a0
> >
> > -> #2 (&rq->lock){-.-.}:
> >        lock_acquire+0x9e/0x180
> >        _raw_spin_lock+0x2f/0x40
> >        task_fork_fair+0x37/0x160
> >        sched_fork+0x211/0x310
> >        copy_process.part.43+0x7b1/0x2160
> >        _do_fork+0xda/0x6b0
> >        kernel_thread+0x29/0x30
> >        rest_init+0x22/0x260
> >        arch_call_rest_init+0xe/0x10
> >        start_kernel+0x4fd/0x520
> >        x86_64_start_reservations+0x24/0x26
> >        x86_64_start_kernel+0x6f/0x72
> >        secondary_startup_64+0xa4/0xb0
> >
> > -> #1 (&p->pi_lock){-.-.}:
> >        lock_acquire+0x9e/0x180
> >        _raw_spin_lock_irqsave+0x3a/0x50
> >        try_to_wake_up+0x41/0x600
> >        wake_up_process+0x15/0x20
> >        create_worker+0x16b/0x1e0
> >        workqueue_init+0x279/0x2ee
> >        kernel_init_freeable+0xf7/0x288
> >        kernel_init+0xf/0x180
> >        ret_from_fork+0x24/0x30
> >
> > -> #0 (&(&pool->lock)->rlock){-.-.}:
> >        __lock_acquire+0x101f/0x12a0
> >        lock_acquire+0x9e/0x180
> >        _raw_spin_lock+0x2f/0x40
> >        __queue_work+0xb2/0x520
> >        queue_work_on+0x38/0x80
> >        free_percpu+0x221/0x260
> >        pcpu_freelist_destroy+0x11/0x20
> >        stack_map_free+0x2a/0x40
> >        bpf_map_free_deferred+0x3c/0x50
> >        process_one_work+0x1f7/0x580
> >        worker_thread+0x54/0x410
> >        kthread+0x10f/0x150
> >        ret_from_fork+0x24/0x30
> >
> > other info that might help us debug this:
> >
> > Chain exists of:
> >   &(&pool->lock)->rlock --> &htab->buckets[i].lock --> pcpu_lock
> >
> >  Possible unsafe locking scenario:
> >
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(pcpu_lock);
> >                                lock(&htab->buckets[i].lock);
> >                                lock(pcpu_lock);
> >   lock(&(&pool->lock)->rlock);
> >
> >  *** DEADLOCK ***
> >
> > 3 locks held by kworker/23:255/18872:
> >  #0: 00000000b36a6e16 ((wq_completion)events){+.+.},
> >      at: process_one_work+0x17a/0x580
> >  #1: 00000000dfd966f0 ((work_completion)(&map->work)){+.+.},
> >      at: process_one_work+0x17a/0x580
> >  #2: 00000000e3e7a6aa (pcpu_lock){..-.},
> >      at: free_percpu+0x36/0x260
> >
> > stack backtrace:
> > CPU: 23 PID: 18872 Comm: kworker/23:255 Not tainted 5.1.0-dbg-DEV #1
> > Hardware name: ...
> > Workqueue: events bpf_map_free_deferred
> > Call Trace:
> >  dump_stack+0x67/0x95
> >  print_circular_bug.isra.38+0x1c6/0x220
> >  check_prev_add.constprop.50+0x9f6/0xd20
> >  __lock_acquire+0x101f/0x12a0
> >  lock_acquire+0x9e/0x180
> >  _raw_spin_lock+0x2f/0x40
> >  __queue_work+0xb2/0x520
> >  queue_work_on+0x38/0x80
> >  free_percpu+0x221/0x260
> >  pcpu_freelist_destroy+0x11/0x20
> >  stack_map_free+0x2a/0x40
> >  bpf_map_free_deferred+0x3c/0x50
> >  process_one_work+0x1f7/0x580
> >  worker_thread+0x54/0x410
> >  kthread+0x10f/0x150
> >  ret_from_fork+0x24/0x30
> >
> > Signed-off-by: John Sperbeck <jsperbeck@google.com>
> > ---
> >  mm/percpu.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 68dd2e7e73b5..d832793bf83a 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -1738,6 +1738,7 @@ void free_percpu(void __percpu *ptr)
> >       struct pcpu_chunk *chunk;
> >       unsigned long flags;
> >       int off;
> > +     bool need_balance = false;
> >
> >       if (!ptr)
> >               return;
> > @@ -1759,7 +1760,7 @@ void free_percpu(void __percpu *ptr)
> >
> >               list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
> >                       if (pos != chunk) {
> > -                             pcpu_schedule_balance_work();
> > +                             need_balance = true;
> >                               break;
> >                       }
> >       }
> > @@ -1767,6 +1768,9 @@ void free_percpu(void __percpu *ptr)
> >       trace_percpu_free_percpu(chunk->base_addr, off, ptr);
> >
> >       spin_unlock_irqrestore(&pcpu_lock, flags);
> > +
> > +     if (need_balance)
> > +             pcpu_schedule_balance_work();
> >  }
> >  EXPORT_SYMBOL_GPL(free_percpu);
> >
> > --
> > 2.21.0.1020.gf2820cf01a-goog
> >
>
> Hi John,
>
> The free_percpu() function hasn't changed in a little under 2 years. So,
> either lockdep has gotten smarter or something else has changed. There
> was a workqueue change recently merged: 6d25be5782e4 ("sched/core,
> workqueues: Distangle worker accounting from rq lock"). Would you mind
> reverting this and then seeing if you still encounter deadlock?
>

We have the issue even without 6d25be5782e4 in the picture.

I sent the splat months ago to Alexei, because I thought it was BPF
related at first

