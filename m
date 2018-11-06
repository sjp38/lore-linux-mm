Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 967CF6B031D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 07:42:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z72-v6so7554530ede.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 04:42:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h62-v6si1408186edc.299.2018.11.06.04.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 04:42:27 -0800 (PST)
Date: Tue, 6 Nov 2018 13:42:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181106124224.GM27423@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org>
 <20181026192551.GC18839@dhcp22.suse.cz>
 <20181026193304.GD18839@dhcp22.suse.cz>
 <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
 <c38e352a-dd23-a5e4-ac50-75b557506479@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c38e352a-dd23-a5e4-ac50-75b557506479@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 06-11-18 18:44:43, Tetsuo Handa wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6e1469b..a97648a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1382,8 +1382,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	};
>  	bool ret;
>  
> -	mutex_lock(&oom_lock);
> -	ret = out_of_memory(&oc);
> +	if (mutex_lock_killable(&oom_lock))
> +		return true;
> +	/*
> +	 * A few threads which were not waiting at mutex_lock_killable() can
> +	 * fail to bail out. Therefore, check again after holding oom_lock.
> +	 */
> +	ret = fatal_signal_pending(current) || out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  	return ret;
>  }

If we are goging with a memcg specific thingy then I really prefer
tsk_is_oom_victim approach. Or is there any reason why this is not
suitable?

-- 
Michal Hocko
SUSE Labs
