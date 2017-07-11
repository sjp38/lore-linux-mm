Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55EFC6B0499
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:19:49 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l87so62409133qki.7
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:19:49 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id c44si13440724qtd.74.2017.07.11.05.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 05:19:48 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id d78so101175301qkb.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:19:48 -0700 (PDT)
Date: Tue, 11 Jul 2017 08:19:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm: Why WQ_MEM_RECLAIM workqueue remains pending?
Message-ID: <20170711121944.GA2969123@devbig577.frc2.facebook.com>
References: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
 <201707071927.IGG34813.tSQOMJFOHOFVLF@I-love.SAKURA.ne.jp>
 <20170710181214.GD1305447@devbig577.frc2.facebook.com>
 <201707111951.IHA98084.OHQtVOFJMLOSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707111951.IHA98084.OHQtVOFJMLOSFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org, hillf.zj@alibaba-inc.com, brouer@redhat.com

Hello,

On Tue, Jul 11, 2017 at 07:51:07PM +0900, Tetsuo Handa wrote:
> I tried below change. It indeed reduced delays, but even with WQ_HIGHPRI, up to a
> few seconds of delay is unavoidable? I wished it is processed within a few jiffies.

The rescuer doesn't take long to kick in but there's only one in the
entire system.  If you have 64 cpus, that one rescuer is gonna be
visiting each CPU servicing them one-by-one and the scheduling
latencies and execution times accumulate.  Again, this is a deadlock
prevention mechanism.  If these per-cpu tasks need to be executed on
every CPU without latency regardless of memory pressure, it has to
pre-allocate all the resources up-front - ie. use kthread_workers
instead of workqueue.

> By the way, I think it might be useful if delay of each work item is
> printed together...

Yeah, sure, please feel free to submit a patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
