Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 983ACC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 18:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C2C2216C8
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 18:59:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C2C2216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A76186B0003; Wed,  8 May 2019 14:59:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26A06B0005; Wed,  8 May 2019 14:59:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 914286B0007; Wed,  8 May 2019 14:59:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 718796B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 14:59:37 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id g7so22770695qkb.7
        for <linux-mm@kvack.org>; Wed, 08 May 2019 11:59:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sm3smJDhVDMlXi4hS7D0sl1HnAyaNuMug0E6S5yftB4=;
        b=N4sUeKp+ZFiyn3IVKC4Xj/hHmOsCSj/fsJpR7uWVacKmlPlN1816e7E0LRx0jRd3oG
         ao/k3IBhDd3NLGembLkf93PsxdA+tDPFn+03EgfMu8dXIopuxHrNM4JHG+WfudYx9iaP
         RI1N5mgB1ONUSfxfbFcZbMstNhNGEWywuzJQRMTeEIAPWYjn0ghdfcISO5BQ3rxnmeur
         xP8qNhkFaHuvNsp/2dfN2APPjwi2W+FSLBF6YUYaIxkZjCufoz3pcF79QDqconunhw4I
         Ffzi5eXeL02VM3BXN9swd90rlrVDklk9cWuU9I7o+KESjvZ9l0FORCZFRLsRyqRYT+aY
         ookA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV4gOQjeU2+5SPwkIlyqqYqzlkW4ai9Bun4cSwkYgminpzFAo2N
	RhPq1jwKC+HVqQ8Vp9bF2P74YEVbKoKiV8gzXYw8QzqEsaRq7urPNGpwNNIlUPyninUVHDliLaU
	jsQCJKJW4rgBLwjk/Za5GqohMIUnFFVdCaFRrNJGxWwZ4x6EhjNuh4xUgiQDJKko=
X-Received: by 2002:ae9:f117:: with SMTP id k23mr29547978qkg.344.1557341977137;
        Wed, 08 May 2019 11:59:37 -0700 (PDT)
X-Received: by 2002:ae9:f117:: with SMTP id k23mr29547921qkg.344.1557341976066;
        Wed, 08 May 2019 11:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557341976; cv=none;
        d=google.com; s=arc-20160816;
        b=QTf6uauNA/nwFWu9cldt5Gv/kMCZnzeV87VXy+gLYBuygFQBJ4LX+kGAXJyVcRv5hW
         COVEXz/nz+z+gQyYtk/qMdsyCfoGNRPjIy/B0hzSrG+dBH7pQs3Gj7HxAMP64HQZqnud
         EYSxV6uBBKv/clmgeCBgcEyHAnzMQgBLeYRSdswSjv7uvog9Ts5PO5PmQYoeDOvvbZri
         +Gn+47NU8NgV1G72WtVIi39QYHXu+SEMg3+HjJtz/JywGDi+IKtulCvYPO3KI3uqOm2v
         yZylEgZ8K1Arowx5NbgcRbTXFR+gGQ8RTyGFgXzhCsO5A6PlDhfjhMspRNKnc75hAubf
         j9jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sm3smJDhVDMlXi4hS7D0sl1HnAyaNuMug0E6S5yftB4=;
        b=Ew3OB6VfbFhTLEBUvdtYkJ0s81iaeLFbXlyqjNcI2auK9SFOMhZFX9vWl0tzOQCpuw
         odR7rXmlkQTcQnyOkQnU4msEnwg5nT+ln57vDER9tR6KzSAz0lSBdEkzcNz8pifDov4a
         FxkvEdDY7/HSSkqvgn7D2LadbYDgau8bIW043OfQxhDv3PSWmSKQJ7pw1gOT/RKFaEHd
         q9AYtloX0XH74GQ2wuFoisjOQciGeHWqXr4xsEYcNMepBuCWNQoGUJouNprEzL3BQ7N+
         jmZnJ0nsL5lOLp11nd/crHGPH1MDKnPgXbEkM3rBls0mr/9g16IakQH3tOexuvPafNcg
         kn8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor6041792qkm.114.2019.05.08.11.59.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 11:59:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxDzWdVZ3CcwuyyuFXUcvKoOClhh3q4tYljSs1jh1P9/E8cVDgiivFYdYKGyEXiE7bHvlvOwg==
X-Received: by 2002:a37:5042:: with SMTP id e63mr30203493qkb.240.1557341975502;
        Wed, 08 May 2019 11:59:35 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::1:9ddb])
        by smtp.gmail.com with ESMTPSA id v31sm7518403qtv.6.2019.05.08.11.59.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 11:59:34 -0700 (PDT)
Date: Wed, 8 May 2019 14:59:32 -0400
From: Dennis Zhou <dennis@kernel.org>
To: John Sperbeck <jsperbeck@google.com>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Eric Dumazet <edumazet@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] percpu: remove spurious lock dependency between percpu
 and sched
Message-ID: <20190508185932.GA68786@dennisz-mbp>
References: <20190508014320.55404-1-jsperbeck@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508014320.55404-1-jsperbeck@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 06:43:20PM -0700, John Sperbeck wrote:
> In free_percpu() we sometimes call pcpu_schedule_balance_work() to
> queue a work item (which does a wakeup) while holding pcpu_lock.
> This creates an unnecessary lock dependency between pcpu_lock and
> the scheduler's pi_lock.  There are other places where we call
> pcpu_schedule_balance_work() without hold pcpu_lock, and this case
> doesn't need to be different.
> 
> Moving the call outside the lock prevents the following lockdep splat
> when running tools/testing/selftests/bpf/{test_maps,test_progs} in
> sequence with lockdep enabled:
> 
> ======================================================
> WARNING: possible circular locking dependency detected
> 5.1.0-dbg-DEV #1 Not tainted
> ------------------------------------------------------
> kworker/23:255/18872 is trying to acquire lock:
> 000000000bc79290 (&(&pool->lock)->rlock){-.-.}, at: __queue_work+0xb2/0x520
> 
> but task is already holding lock:
> 00000000e3e7a6aa (pcpu_lock){..-.}, at: free_percpu+0x36/0x260
> 
> which lock already depends on the new lock.
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #4 (pcpu_lock){..-.}:
>        lock_acquire+0x9e/0x180
>        _raw_spin_lock_irqsave+0x3a/0x50
>        pcpu_alloc+0xfa/0x780
>        __alloc_percpu_gfp+0x12/0x20
>        alloc_htab_elem+0x184/0x2b0
>        __htab_percpu_map_update_elem+0x252/0x290
>        bpf_percpu_hash_update+0x7c/0x130
>        __do_sys_bpf+0x1912/0x1be0
>        __x64_sys_bpf+0x1a/0x20
>        do_syscall_64+0x59/0x400
>        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> -> #3 (&htab->buckets[i].lock){....}:
>        lock_acquire+0x9e/0x180
>        _raw_spin_lock_irqsave+0x3a/0x50
>        htab_map_update_elem+0x1af/0x3a0
> 
> -> #2 (&rq->lock){-.-.}:
>        lock_acquire+0x9e/0x180
>        _raw_spin_lock+0x2f/0x40
>        task_fork_fair+0x37/0x160
>        sched_fork+0x211/0x310
>        copy_process.part.43+0x7b1/0x2160
>        _do_fork+0xda/0x6b0
>        kernel_thread+0x29/0x30
>        rest_init+0x22/0x260
>        arch_call_rest_init+0xe/0x10
>        start_kernel+0x4fd/0x520
>        x86_64_start_reservations+0x24/0x26
>        x86_64_start_kernel+0x6f/0x72
>        secondary_startup_64+0xa4/0xb0
> 
> -> #1 (&p->pi_lock){-.-.}:
>        lock_acquire+0x9e/0x180
>        _raw_spin_lock_irqsave+0x3a/0x50
>        try_to_wake_up+0x41/0x600
>        wake_up_process+0x15/0x20
>        create_worker+0x16b/0x1e0
>        workqueue_init+0x279/0x2ee
>        kernel_init_freeable+0xf7/0x288
>        kernel_init+0xf/0x180
>        ret_from_fork+0x24/0x30
> 
> -> #0 (&(&pool->lock)->rlock){-.-.}:
>        __lock_acquire+0x101f/0x12a0
>        lock_acquire+0x9e/0x180
>        _raw_spin_lock+0x2f/0x40
>        __queue_work+0xb2/0x520
>        queue_work_on+0x38/0x80
>        free_percpu+0x221/0x260
>        pcpu_freelist_destroy+0x11/0x20
>        stack_map_free+0x2a/0x40
>        bpf_map_free_deferred+0x3c/0x50
>        process_one_work+0x1f7/0x580
>        worker_thread+0x54/0x410
>        kthread+0x10f/0x150
>        ret_from_fork+0x24/0x30
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   &(&pool->lock)->rlock --> &htab->buckets[i].lock --> pcpu_lock
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(pcpu_lock);
>                                lock(&htab->buckets[i].lock);
>                                lock(pcpu_lock);
>   lock(&(&pool->lock)->rlock);
> 
>  *** DEADLOCK ***
> 
> 3 locks held by kworker/23:255/18872:
>  #0: 00000000b36a6e16 ((wq_completion)events){+.+.},
>      at: process_one_work+0x17a/0x580
>  #1: 00000000dfd966f0 ((work_completion)(&map->work)){+.+.},
>      at: process_one_work+0x17a/0x580
>  #2: 00000000e3e7a6aa (pcpu_lock){..-.},
>      at: free_percpu+0x36/0x260
> 
> stack backtrace:
> CPU: 23 PID: 18872 Comm: kworker/23:255 Not tainted 5.1.0-dbg-DEV #1
> Hardware name: ...
> Workqueue: events bpf_map_free_deferred
> Call Trace:
>  dump_stack+0x67/0x95
>  print_circular_bug.isra.38+0x1c6/0x220
>  check_prev_add.constprop.50+0x9f6/0xd20
>  __lock_acquire+0x101f/0x12a0
>  lock_acquire+0x9e/0x180
>  _raw_spin_lock+0x2f/0x40
>  __queue_work+0xb2/0x520
>  queue_work_on+0x38/0x80
>  free_percpu+0x221/0x260
>  pcpu_freelist_destroy+0x11/0x20
>  stack_map_free+0x2a/0x40
>  bpf_map_free_deferred+0x3c/0x50
>  process_one_work+0x1f7/0x580
>  worker_thread+0x54/0x410
>  kthread+0x10f/0x150
>  ret_from_fork+0x24/0x30
> 
> Signed-off-by: John Sperbeck <jsperbeck@google.com>
> ---
>  mm/percpu.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 68dd2e7e73b5..d832793bf83a 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1738,6 +1738,7 @@ void free_percpu(void __percpu *ptr)
>  	struct pcpu_chunk *chunk;
>  	unsigned long flags;
>  	int off;
> +	bool need_balance = false;
>  
>  	if (!ptr)
>  		return;
> @@ -1759,7 +1760,7 @@ void free_percpu(void __percpu *ptr)
>  
>  		list_for_each_entry(pos, &pcpu_slot[pcpu_nr_slots - 1], list)
>  			if (pos != chunk) {
> -				pcpu_schedule_balance_work();
> +				need_balance = true;
>  				break;
>  			}
>  	}
> @@ -1767,6 +1768,9 @@ void free_percpu(void __percpu *ptr)
>  	trace_percpu_free_percpu(chunk->base_addr, off, ptr);
>  
>  	spin_unlock_irqrestore(&pcpu_lock, flags);
> +
> +	if (need_balance)
> +		pcpu_schedule_balance_work();
>  }
>  EXPORT_SYMBOL_GPL(free_percpu);
>  
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

Hi John,

The free_percpu() function hasn't changed in a little under 2 years. So,
either lockdep has gotten smarter or something else has changed. There
was a workqueue change recently merged: 6d25be5782e4 ("sched/core,
workqueues: Distangle worker accounting from rq lock"). Would you mind
reverting this and then seeing if you still encounter deadlock?

Thanks,
Dennis

