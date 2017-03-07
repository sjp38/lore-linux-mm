Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89DD16B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:23:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id h188so1801453wma.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:23:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si199733wra.226.2017.03.07.06.23.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 06:23:40 -0800 (PST)
Date: Tue, 7 Mar 2017 15:23:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
Message-ID: <20170307142338.GL28642@dhcp22.suse.cz>
References: <20170307131751.24936-1-mhocko@kernel.org>
 <201703072250.FJD86423.FJOHOFLFOMQVSt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703072250.FJD86423.FJOHOFLFOMQVSt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 07-03-17 22:50:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> > vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> > per cpu lru caches. This seems more than necessary because both can run
> > on a single WQ. Both do not block on locks requiring a memory allocation
> > nor perform any allocations themselves. We will save one rescuer thread
> > this way.
> > 
> > On the other hand drain_all_pages() queues work on the system wq which
> > doesn't have rescuer and so this depend on memory allocation (when all
> > workers are stuck allocating and new ones cannot be created). This is
> > not critical as there should be somebody invoking the OOM killer (e.g.
> > the forking worker) and get the situation unstuck and eventually
> > performs the draining. Quite annoying though. This worker should be
> > using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> > and vmstat.
> 
> Is "there should be somebody invoking the OOM killer" really true?

in most cases there should be... I didn't say there will be...

> According to http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp
> 
>   kthreadd (PID = 2) is trying to allocate "struct task_struct" requested by
>   workqueue managers (PID = 19, 157, 10499) but is blocked on memory allocation.
> 
> __GFP_FS allocations could get stuck waiting for drain_all_pages() ?
> Also, order > 0 allocation request by the forking worker could get stuck
> at too_many_isolated() in mm/compaction.c ?

There might be some extreme cases which however do not change the
justification of this patch. I didn't see such cases reported anywhere
- other than in your stress testing where we do not really know what is
going on yet - and so I didn't mention them and nor I have marked the
patch for stable.

I am wondering what is the point of this feedback actually? Do you
see anything wrong in the patch or is this about the wording of the
changelog? If it is the later is your concern serious enough to warrant
the rewording/reposting?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
