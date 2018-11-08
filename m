Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D27F6B05B9
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:32:27 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so10888384edc.17
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:32:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u12si1879595edy.88.2018.11.08.01.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 01:32:26 -0800 (PST)
Date: Thu, 8 Nov 2018 10:32:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
Message-ID: <20181108093224.GS27423@dhcp22.suse.cz>
References: <20181025082403.3806-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025082403.3806-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 25-10-18 10:24:00, Michal Hocko wrote:
> The previous version of this RFC has been posted here [1]. I have fixed
> few issues spotted during the review and by 0day bot. I have also reworked
> patch 2 to be ratio rather than an absolute number based.
> 
> With this series applied the locking protocol between the oom_reaper and
> the exit path is as follows.
> 
> All parts which cannot race should use the exclusive lock on the exit
> path. Once the exit path has passed the moment when no blocking locks
> are taken then it clears mm->mmap under the exclusive lock. oom_reaper
> checks for this and sets MMF_OOM_SKIP only if the exit path is not guaranteed
> to finish the job. This is patch 3 so see the changelog for all the details.
> 
> I would really appreciate if David could give this a try and see how
> this behaves in workloads where the oom_reaper falls flat now. I have
> been playing with sparsely allocated memory with a high pte/real memory
> ratio and large mlocked processes and it worked reasonably well.

Does this help workloads you were referring to earlier David?

> There is still some room for tuning here of course. We can change the
> number of retries for the oom_reaper as well as the threshold when the
> keep retrying.
> 
> Michal Hocko (3):
>       mm, oom: rework mmap_exit vs. oom_reaper synchronization
>       mm, oom: keep retrying the oom_reap operation as long as there is substantial memory left
>       mm, oom: hand over MMF_OOM_SKIP to exit path if it is guranteed to finish
> 
> Diffstat:
>  include/linux/oom.h |  2 --
>  mm/internal.h       |  3 +++
>  mm/memory.c         | 28 ++++++++++++++--------
>  mm/mmap.c           | 69 +++++++++++++++++++++++++++++++++--------------------
>  mm/oom_kill.c       | 45 ++++++++++++++++++++++++----------
>  5 files changed, 97 insertions(+), 50 deletions(-)
> 
> [1] http://lkml.kernel.org/r/20180910125513.311-1-mhocko@kernel.org
> 

-- 
Michal Hocko
SUSE Labs
