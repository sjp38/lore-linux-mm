Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0DA6B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 05:04:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z5so1111970wmz.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 02:04:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z128si645927wmg.186.2017.06.29.02.04.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 02:04:32 -0700 (PDT)
Date: Thu, 29 Jun 2017 11:04:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 1/6] mm, oom: use oom_victims counter to synchronize oom
 victim selection
Message-ID: <20170629090431.GG31603@dhcp22.suse.cz>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-2-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498079956-24467-2-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 21-06-17 22:19:11, Roman Gushchin wrote:
> Oom killer should avoid unnecessary kills. To prevent them, during
> the tasks list traverse we check for task which was previously
> selected as oom victims. If there is such a task, new victim
> is not selected.
> 
> This approach is sub-optimal (we're doing costly iteration over the task
> list every time) and will not work for the cgroup-aware oom killer.
> 
> We already have oom_victims counter, which can be effectively used
> for the task.

A global counter will not work properly, I am afraid. a) you should
consider the oom domain and do not block oom on unrelated domains and b)
you have no guarantee that the oom victim will terminate reasonably.
That is why we have MMF_OOM_SKIP check in oom_evaluate_task.

I think you should have something similar for your memcg victim selection.
If you see a memcg in the oom hierarchy with oom victims which are alive
and not MMF_OOM_SKIP, you should abort the scanning.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
