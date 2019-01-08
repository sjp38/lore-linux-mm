Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B47CC8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:46:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so1534650edc.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:46:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si6805019eda.224.2019.01.08.03.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:46:41 -0800 (PST)
Date: Tue, 8 Jan 2019 12:46:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20190108114639.GR31793@dhcp22.suse.cz>
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190107143802.16847-3-mhocko@kernel.org>
 <fa8892d1-4a38-dccd-9597-923924aa0a66@i-love.sakura.ne.jp>
 <20190108081441.GO31793@dhcp22.suse.cz>
 <3b105bba-3542-1d00-c6e2-52f6d125eff2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b105bba-3542-1d00-c6e2-52f6d125eff2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 08-01-19 19:39:58, Tetsuo Handa wrote:
> On 2019/01/08 17:14, Michal Hocko wrote:
> >>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>> index af7f18b32389..90eb2e2093e7 100644
> >>> --- a/mm/memcontrol.c
> >>> +++ b/mm/memcontrol.c
> >>> @@ -1387,10 +1387,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >>>  		.gfp_mask = gfp_mask,
> >>>  		.order = order,
> >>>  	};
> >>> -	bool ret;
> >>> +	bool ret = true;
> >>>  
> >>>  	mutex_lock(&oom_lock);
> >>
> >> And because of "[PATCH 1/2] mm, oom: marks all killed tasks as oom
> >> victims", mark_oom_victim() will be called on current thread even if
> >> we used mutex_lock_killable(&oom_lock) here, like you said
> >>
> >>   mutex_lock_killable would take care of exiting task already. I would
> >>   then still prefer to check for mark_oom_victim because that is not racy
> >>   with the exit path clearing signals. I can update my patch to use
> >>   _killable lock variant if we are really going with the memcg specific
> >>   fix.
> >>
> >> . If current thread is not yet killed by the OOM killer but can terminate
> >> without invoking the OOM killer, using mutex_lock_killable(&oom_lock) here
> >> saves some processes. What is the race you are referring by "racy with the
> >> exit path clearing signals" ?
> > 
> > This is unrelated to the patch.
> 
> Ultimately related! This is the reasoning why your patch should be preferred
> over my patch.

No! I've said I do not mind using mutex_lock_killable on top of this
patch. I just want to have this fix minimal.

-- 
Michal Hocko
SUSE Labs
