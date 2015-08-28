Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 530D26B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:49:36 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so29627282pad.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:49:36 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id d6si10830763pat.167.2015.08.28.09.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 09:49:35 -0700 (PDT)
Date: Fri, 28 Aug 2015 19:49:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150828164918.GJ9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1440775530-18630-5-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 28, 2015 at 11:25:30AM -0400, Tejun Heo wrote:
> On the default hierarchy, all memory consumption will be accounted
> together and controlled by the same set of limits.  Always enable
> kmemcg on the default hierarchy.

IMO we should introduce a boot time knob for disabling it, because kmem
accounting is still not perfect, besides some users might prefer to go
w/o it for performance reasons.

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> ---
>  mm/memcontrol.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c94b686..8a5dd01 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4362,6 +4362,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	if (ret)
>  		return ret;
>  
> +	/* kmem is always accounted together on the default hierarchy */
> +	if (cgroup_on_dfl(css->cgroup)) {
> +		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
> +		if (ret)
> +			return ret;
> +	}
> +

This is a wrong place for this. The kernel will panic on an attempt to
create a sub memcg, because memcg_init_kmem already enables kmem
accounting in this case. I guess we should add this hunk to
memcg_propagate_kmem instead.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
