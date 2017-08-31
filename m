Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20A276B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 21:46:15 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p13so24447515qtp.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 18:46:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor2232518qkf.18.2017.08.30.18.46.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 18:46:14 -0700 (PDT)
Date: Wed, 30 Aug 2017 18:46:10 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170831014610.GE491396@devbig577.frc2.facebook.com>
References: <20170828230256.GF491396@devbig577.frc2.facebook.com>
 <20170828230924.GG491396@devbig577.frc2.facebook.com>
 <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
 <20170829143817.GK491396@devbig577.frc2.facebook.com>
 <20170829214104.GW491396@devbig577.frc2.facebook.com>
 <201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hello,

On Wed, Aug 30, 2017 at 10:51:57PM +0900, Tetsuo Handa wrote:
> Here are logs from the patch applied on top of linux-next-20170828.
> Can you find some clue?
> 
> http://I-love.SAKURA.ne.jp/tmp/serial-20170830.txt.xz :
> 
> [  150.580362] Showing busy workqueues and worker pools:
> [  150.580425] workqueue events_power_efficient: flags=0x80
> [  150.580452]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
> [  150.580456]     in-flight: 57:fb_flashcursor{53}
> [  150.580486] workqueue mm_percpu_wq: flags=0x18
> [  150.580513]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
> [  150.580516]     pending: drain_local_pages_wq{14139} BAR(1706){14139}

So, there clear are work items queued

> [  150.580558] workqueue writeback: flags=0x4e
> [  150.580559]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
> [  150.580562]     in-flight: 400:wb_workfn{0} wb_workfn{0}
> [  150.581413] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 178 3
> [  150.581417] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 4 98
> [  150.581420] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=15s workers=4 idle: 81 2104 17 285
> [  150.581424] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=14s workers=2 idle: 18 92

But all of the pool's workers are staying idle.  The only two
possibilities I can think of are

1. Concurrency management is completely broken for some reason.  One
   reason this could happen is if a work item changes the affinity of
   a per-cpu worker thread.  I don't think this is too likely here.

2. Somehow high memory pressure is preventing the worker to leave
   idle.  I have no idea how this would happen but it *could* be that
   there is somehow memory allocation dependency in the worker waking
   up path.  Can you strip down your kernel config to bare minimum and
   see whether the problem still persists.  Alternatively, we can dump
   stack traces of the tasks after a stall detection and try to see if
   the kworkers are stuck somewhere.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
