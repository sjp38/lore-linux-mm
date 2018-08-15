Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD196B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 03:29:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h26-v6so270415eds.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 00:29:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r11-v6si298181edh.359.2018.08.15.00.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 00:29:01 -0700 (PDT)
Date: Wed, 15 Aug 2018 09:29:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm: drain memcg stocks on css offlining
Message-ID: <20180815072900.GM32645@dhcp22.suse.cz>
References: <20180815003620.15678-1-guro@fb.com>
 <20180815003620.15678-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815003620.15678-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Tue 14-08-18 17:36:20, Roman Gushchin wrote:
> Memcg charge is batched using per-cpu stocks, so an offline memcg
> can be pinned by a cached charge up to a moment, when a process
> belonging to some other cgroup will charge some memory on the same
> cpu. In other words, cached charges can prevent a memory cgroup
> from being reclaimed for some time, without any clear need.
> 
> Let's optimize it by explicit draining of all stocks on css offlining.
> As draining is performed asynchronously, and is skipped if any
> parallel draining is happening, it's cheap.

Yes this makes sense.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4e3c1315b1de..cfb64b5b9957 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4575,6 +4575,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	memcg_offline_kmem(memcg);
>  	wb_memcg_offline(memcg);
>  
> +	drain_all_stock(memcg);
> +
>  	mem_cgroup_id_put(memcg);
>  }
>  
> -- 
> 2.14.4

-- 
Michal Hocko
SUSE Labs
