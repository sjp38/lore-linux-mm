Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2D6B6B0003
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 07:45:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t19so3790476wmh.3
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:45:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n20si5113604wra.303.2018.03.22.04.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 04:45:55 -0700 (PDT)
Date: Thu, 22 Mar 2018 12:45:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180322114554.GD23100@dhcp22.suse.cz>
References: <1521715916-4153-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521715916-4153-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 22-03-18 19:51:56, Tetsuo Handa wrote:
[...]
> The whole point of the sleep is to give the OOM victim some time to exit.

Yes, and that is why we sleep under the lock because that would rule all
other potential out_of_memory callers from jumping in.

> However, the sleep can prevent contending allocating paths from hitting
> the OOM path again even if the OOM victim was able to exit. We need to
> make sure that the thread which called out_of_memory() will release
> oom_lock shortly. Thus, this patch brings the sleep to outside of the OOM
> path. Since the OOM reaper waits for the oom_lock, this patch unlikely
> allows contending allocating paths to hit the OOM path earlier than now.

The sleep outside of the lock doesn't make much sense to me. It is
basically contradicting its original purpose. If we do want to throttle
direct reclaimers than OK but this patch is not the way how to do that.

If you really believe that the sleep is more harmful than useful, then
fair enough, I would rather see it removed than shuffled all over
outside the lock. 

So
Nacked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
