Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3D666B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:28:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x203-v6so4373633wmg.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:28:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35-v6si5847308edi.14.2018.06.07.04.28.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 04:28:37 -0700 (PDT)
Date: Thu, 7 Jun 2018 13:28:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm,oom: Check pending victims earlier in
 out_of_memory().
Message-ID: <20180607112836.GN32433@dhcp22.suse.cz>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1528369223-7571-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1528369223-7571-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 07-06-18 20:00:23, Tetsuo Handa wrote:
> The "mm, oom: cgroup-aware OOM killer" patchset is trying to introduce
> INFLIGHT_VICTIM in order to replace open-coded ((void *)-1UL). But
> (regarding CONFIG_MMU=y case) we have a list of inflight OOM victim
> threads which are connected to oom_reaper_list. Thus we can check
> whether there are inflight OOM victims before starting process/memcg
> list traversal. Since it is likely that only few threads are linked to
> oom_reaper_list, checking all victims' OOM domain will not matter.
> 
> Thus, check whether there are inflight OOM victims before starting
> process/memcg list traversal and eliminate the "abort" path.

OK, this looks like a nice shortcut. I am quite surprise that all your
NOMMU concerns are gone now while you clearly regress that case because
inflight victims are not detected anymore AFAICS. Not that I care all
that much, just sayin'.

Anyway, I would suggest splitting this into two patches. One to add an
early check for inflight oom victims and one removing the detection from
oom_evaluate_task. Just to make it easier to revert if somebody on nommu
actually notices a regression.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>

[...]
-- 
Michal Hocko
SUSE Labs
