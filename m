Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 82E3F6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:38:25 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so7274051wes.26
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 08:38:24 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pg7si24777852wjb.56.2014.06.17.08.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 08:38:24 -0700 (PDT)
Date: Tue, 17 Jun 2014 11:38:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140617153814.GB7331@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
 <20140617142317.GD19886@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617142317.GD19886@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 17, 2014 at 04:23:17PM +0200, Michal Hocko wrote:
> On Mon 16-06-14 15:54:23, Johannes Weiner wrote:
> > Transparent huge page charges prefer falling back to regular pages
> > rather than spending a lot of time in direct reclaim.
> > 
> > Desired reclaim behavior is usually declared in the gfp mask, but THP
> > charges use GFP_KERNEL and then rely on the fact that OOM is disabled
> > for THP charges, and that OOM-disabled charges currently skip reclaim.
> > Needless to say, this is anything but obvious and quite error prone.
> > 
> > Convert THP charges to use GFP_TRANSHUGE instead, which implies
> > __GFP_NORETRY, to indicate the low-latency requirement.
> 
> Maybe we can get one step further and even get rid of oom parameter.
> It is only THP (handled by this patch) and mem_cgroup_do_precharge that
> want OOM disabled explicitly.

Great idea!

> GFP_KERNEL & (~__GFP_NORETRY) is ugly and something like GFP_NO_OOM
> would be better but this is just a quick scratch.

I think it's fine, actually.

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 52550bbff1ef..5d247822b03a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2555,15 +2555,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>   * mem_cgroup_try_charge - try charging a memcg
>   * @memcg: memcg to charge
>   * @nr_pages: number of pages to charge
> - * @oom: trigger OOM if reclaim fails
>   *
>   * Returns 0 if @memcg was charged successfully, -EINTR if the charge
>   * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
>   */
>  static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  				 gfp_t gfp_mask,
> -				 unsigned int nr_pages,
> -				 bool oom)
> +				 unsigned int nr_pages)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> @@ -2647,7 +2645,7 @@ retry:
>  	if (fatal_signal_pending(current))
>  		goto bypass;
>  
> -	if (!oom)
> +	if (!oom_gfp_allowed(gfp_mask))
>  		goto nomem;

We don't actually need that check: if __GFP_NORETRY is set, we goto
nomem directly after reclaim fails and don't even reach here.

So here is the patch I have now - can I get your sign-off on this?

---
