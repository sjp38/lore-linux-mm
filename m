Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0996B6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:23:56 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so130382449pac.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:23:55 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id q9si31256135pap.101.2015.10.23.11.23.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 11:23:55 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so124432276pab.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:23:55 -0700 (PDT)
Date: Sat, 24 Oct 2015 03:23:43 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151023182343.GB14610@mtj.duckdns.org>
References: <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello, Tetsuo.

On Fri, Oct 23, 2015 at 09:25:11PM +0900, Tetsuo Handa wrote:
> WQ_MEM_RECLAIM only guarantees that a "struct task_struct" is preallocated
> in order to avoid failing to allocate it on demand due to a GFP_KERNEL
> allocation? Is this correct?
> 
> WQ_CPU_INTENSIVE only guarantees that work items don't participate in
> concurrency management in order to avoid failing to wake up a "struct
> task_struct" which will process the work items? Is this correct?

CPU_INTENSIVE avoids the tail end of concurrency management.  The
previous HIGHPRI or the posted IMMEDIATE avoids the head end.

> Is Michal's question "does it make sense to use WQ_MEM_RECLAIM without
> WQ_CPU_INTENSIVE"? In other words, any "struct task_struct" which calls
> rescuer_thread() must imply WQ_CPU_INTENSIVE in order to avoid failing to
> wake up due to being participated in concurrency management?

If this is an actual problem, a better approach would be something
which detects the stall condition and kicks off the next work item but
if we do that I think I'd still trigger a warning there.  I don't
know.  Don't go busy waiting in kernel.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
