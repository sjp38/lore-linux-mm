Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 0ABE36B003D
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 11:44:13 -0400 (EDT)
Received: by mail-qe0-f52.google.com with SMTP id i11so4523972qej.39
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 08:44:13 -0700 (PDT)
Date: Thu, 11 Jul 2013 08:44:08 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
Message-ID: <20130711154408.GA9229@mtj.dyndns.org>
References: <20130710184254.GA16979@mtj.dyndns.org>
 <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
 <20130711093300.GE21667@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711093300.GE21667@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hello, Michal.

On Thu, Jul 11, 2013 at 11:33:00AM +0200, Michal Hocko wrote:
> +static inline
> +struct mem_cgroup *vmpressure_to_mem_cgroup(struct vmpressure *vmpr)
> +{
> +	return container_of(vmpr, struct mem_cgroup, vmpressure);
> +}
> +
> +void vmpressure_pin_memcg(struct vmpressure *vmpr)
> +{
> +	struct mem_cgroup *memcg = vmpressure_to_mem_cgroup(vmpr);
> +
> +	css_get(&memcg->css);
> +}
> +
> +void vmpressure_unpin_memcg(struct vmpressure *vmpr)
> +{
> +	struct mem_cgroup *memcg = vmpressure_to_mem_cgroup(vmpr);
> +
> +	css_put(&memcg->css);
> +}

So, while this *should* work, can't we just cancel/flush the work item
from offline?  There doesn't seem to be any possible deadlocks from my
shallow glance and those mutexes don't seem to be held for long (do
they actually need to be mutexes?  what blocks inside them?).

Also, while at it, can you please remove the work_pending() check?
They're almost always spurious or racy and should be avoided in
general.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
