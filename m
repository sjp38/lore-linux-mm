Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD3E6B0266
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:26:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so18123707lfh.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:26:29 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id f4si859067wma.120.2016.05.27.07.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 07:26:28 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id a136so75518300wme.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:26:27 -0700 (PDT)
Date: Fri, 27 May 2016 16:26:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160527142626.GQ27686@dhcp22.suse.cz>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 17:17:42, Vladimir Davydov wrote:
> When selecting an oom victim, we use the same heuristic for both memory
> cgroup and global oom. The only difference is the scope of tasks to
> select the victim from. So we could just export an iterator over all
> memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> duplicate pieces of it in memcontrol.c reusing some initially private
> functions of oom_kill.c in order to not duplicate all of it. That looks
> ugly and error prone, because any modification of select_bad_process
> should also be propagated to mem_cgroup_out_of_memory.
> 
> Let's rework this as follows: keep all oom heuristic related code
> private to oom_kill.c and make oom_kill.c use exported memcg functions
> when it's really necessary (like in case of iterating over memcg tasks).

I am doing quite large changes in this area and this would cause many
conflicts. Do you think you can postpone this after my patchset [1] gets
sorted out please?

I haven't looked at the patch carefully so I cannot tell much about it
right now but just wanted to give a heads up for the conflicts.

[1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org

Thanks!

> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |  15 ++++
>  include/linux/oom.h        |  51 -------------
>  mm/memcontrol.c            | 112 ++++++++++-----------------
>  mm/oom_kill.c              | 183 +++++++++++++++++++++++++++++----------------
>  4 files changed, 176 insertions(+), 185 deletions(-)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
