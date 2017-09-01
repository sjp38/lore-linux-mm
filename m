Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52BCD6B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 09:47:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t13so414958qtc.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 06:47:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a21sor6188805qkb.4.2017.09.01.06.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Sep 2017 06:47:53 -0700 (PDT)
Date: Fri, 1 Sep 2017 06:47:49 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170901134748.GC1599492@devbig577.frc2.facebook.com>
References: <20170829214104.GW491396@devbig577.frc2.facebook.com>
 <201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
 <20170831014610.GE491396@devbig577.frc2.facebook.com>
 <201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
 <20170831152523.nwdbjock6b6tams5@dhcp22.suse.cz>
 <201709010707.ABI69774.OLSVMOOFHFQJtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709010707.ABI69774.OLSVMOOFHFQJtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hello,

On Fri, Sep 01, 2017 at 07:07:25AM +0900, Tetsuo Handa wrote:
> cond_resched() from !PF_WQ_WORKER threads is sufficient for PF_WQ_WORKER threads to run.
> But cond_resched() is not sufficient for rescuer threads to start processing a pending work.
> An explicit scheduling (e.g. schedule_timeout_*()) by PF_WQ_WORKER threads is needed for
> rescuer threads to start processing a pending work.

I'm not even sure this is the case.  Unless I'm mistaken, in your
workqueue dumps, the available workers couldn't even leave idle which
means that they likely didn't get scheduled at all.  It looks like
genuine multi minute starvation by competing direct reclaims.  What's
the load number like while these events are in progress?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
