Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFF282F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:33:41 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so93989288wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:33:40 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id v11si12637058wie.0.2015.10.21.07.33.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 07:33:40 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so93988575wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:33:39 -0700 (PDT)
Date: Wed, 21 Oct 2015 16:33:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151021143337.GD8805@dhcp22.suse.cz>
References: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Wed 21-10-15 09:22:40, Christoph Lameter wrote:
> On Wed, 21 Oct 2015, Tetsuo Handa wrote:
> 
> > However, if a workqueue which is processed before vmstat_update
> > workqueue is processed got stuck inside memory allocation request,
> > values in vm_stat_diff[] cannot be merged into vm_stat[]. As a result,
> > zone_reclaimable() continues using outdated vm_stat[] values and the
> > task which is doing direct reclaim path thinks that there are reclaimable
> > pages and therefore continues looping. The consequence is a silent
> > livelock (hang up without any kernel messages) because the OOM killer
> > will not be invoked.
> 
> The diffs will be merged if they reach a certain threshold regardless. You
> can decrease that threshhold. See calculate_pressure_threshhold().

The thing is that they will not reach the threshold. The LRUs in this
particular case are empty so there is nothing scanned so
NR_PAGES_SCANNED doesn't increase.

> Why is the merging not occurring if a process gets stuck? Workrequests are
> not blocked by a process being stuck doing memory allocation or reclaim.

Because all the WQ workers are stuck somewhere, maybe in the memory
allocation which cannot make any progress and the vmstat update work is
queued behind them.

At least this is my current understanding.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
