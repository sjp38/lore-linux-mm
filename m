Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5998E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 12:36:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so8063847edr.21
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 09:36:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o12si7391696edi.351.2019.01.13.09.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 09:36:04 -0800 (PST)
Date: Sun, 13 Jan 2019 18:36:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190113173309.GA1578@dhcp22.suse.cz>
References: <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
 <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
 <20190111133401.GA6997@dhcp22.suse.cz>
 <d9f7b139-d51b-93ae-b5ad-856fd9f2c168@i-love.sakura.ne.jp>
 <20190111150703.GI14956@dhcp22.suse.cz>
 <baa43a5a-6cae-bc4e-5911-13d4bfcd32f2@i-love.sakura.ne.jp>
 <20190111164536.GJ14956@dhcp22.suse.cz>
 <0aacad13-3e91-646a-90b1-c70993b05701@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0aacad13-3e91-646a-90b1-c70993b05701@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 12-01-19 19:52:50, Tetsuo Handa wrote:
> On 2019/01/12 1:45, Michal Hocko wrote:
> >>> Anyway, could you update your patch and abstract 
> >>> 	if (unlikely(tsk_is_oom_victim(current) ||
> >>> 		     fatal_signal_pending(current) ||
> >>> 		     current->flags & PF_EXITING))
> >>>
> >>> in try_charge and reuse it in mem_cgroup_out_of_memory under the
> >>> oom_lock with an explanation please?
> >>
> >> I don't think doing so makes sense, for
> >>
> >>   tsk_is_oom_victim(current) = T && fatal_signal_pending(current) == F
> >>
> >> can't happen for mem_cgroup_out_of_memory() under the oom_lock, and
> >> current->flags cannot get PF_EXITING when current is inside
> >> mem_cgroup_out_of_memory(). fatal_signal_pending(current) alone is
> >> appropriate for mem_cgroup_out_of_memory() under the oom_lock because
> >>
> >>   tsk_is_oom_victim(current) = F && fatal_signal_pending(current) == T
> >>
> >> can happen there.
> > 
> > I meant to use the same check consistently. If we can bypass the charge
> > under a list of conditions in the charge path we should be surely be
> > able to the the same for the oom path. I will not insist but unless
> > there is a strong reason I would prefer that.
> > 
> 
> You mean something like this? I'm not sure this change is safe.
> 
>  mm/memcontrol.c | 27 +++++++++++++++++++++++----
>  1 file changed, 23 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 17189da..1733d019 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -248,6 +248,12 @@ enum res_type {
>  	     iter != NULL;				\
>  	     iter = mem_cgroup_iter(NULL, iter, NULL))
>  
> +static inline bool can_ignore_limit(void)
> +{
> +	return tsk_is_oom_victim(current) || fatal_signal_pending(current) ||
> +		(current->flags & PF_EXITING);
> +}
> +
>  /* Some nice accessors for the vmpressure. */
>  struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
>  {
> @@ -1395,7 +1401,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * A few threads which were not waiting at mutex_lock_killable() can
>  	 * fail to bail out. Therefore, check again after holding oom_lock.
>  	 */
> -	ret = fatal_signal_pending(current) || out_of_memory(&oc);
> +	ret = can_ignore_limit() || out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  	return ret;
>  }
> @@ -2215,9 +2230,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * bypass the last charges so that they can exit quickly and
>  	 * free their memory.
>  	 */
> -	if (unlikely(tsk_is_oom_victim(current) ||
> -		     fatal_signal_pending(current) ||
> -		     current->flags & PF_EXITING))
> +	if (unlikely(can_ignore_limit()))
>  		goto force;
>  
>  	/*

I meant something as simple as this, indeed. I would just
s@can_ignore_limit@should_force_charge@ but this is a minor thing.

-- 
Michal Hocko
SUSE Labs
