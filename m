Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C513E6B18B4
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:53:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q29-v6so567888edd.0
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:53:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si7120464edq.426.2018.08.20.03.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 03:53:37 -0700 (PDT)
Date: Mon, 20 Aug 2018 12:53:36 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
Message-ID: <20180820105336.GJ29735@dhcp22.suse.cz>
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On Mon 20-08-18 19:37:45, Tetsuo Handa wrote:
> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed to select next OOM victim as soon as
> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
> and then give up (if !memcg OOM) or can use forced charge and then retry
> (if memcg OOM), OOM victims do not need to select next OOM victim unless
> they are doing __GFP_NOFAIL allocations.

I do not like this at all. It seems hackish to say the least. And more
importantly...

> This is a quick mitigation because syzbot is hitting WARN(1) caused by
> this race window [1]. More robust fix (e.g. make it possible to reclaim
> more memory before MMF_OOM_SKIP is set, wait for some more after
> MMF_OOM_SKIP is set) is a future work.

.. there is already a patch (by Johannes) for that warning IIRC.

> [1] https://syzkaller.appspot.com/bug?id=ea8c7912757d253537375e981b61749b2da69258
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-and-tested-by: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
> ---
>  mm/oom_kill.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 412f434..421c0f6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1031,6 +1031,9 @@ bool out_of_memory(struct oom_control *oc)
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
> +	if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
> +		return true;
> +
>  	if (oom_killer_disabled)
>  		return false;
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
