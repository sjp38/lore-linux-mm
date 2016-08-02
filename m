Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25E9A6B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 12:01:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so106965298wml.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:01:07 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j141si3895093wmg.128.2016.08.02.09.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 09:01:06 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so31694161wmg.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:01:06 -0700 (PDT)
Date: Tue, 2 Aug 2016 18:01:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] mm: memcontrol: add sanity checks for
 memcg->id.ref on get/put
Message-ID: <20160802160103.GC28900@dhcp22.suse.cz>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <32402ace75b459c8523f5b237a62061e1df7a3b5.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32402ace75b459c8523f5b237a62061e1df7a3b5.1470149524.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-08-16 18:00:50, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 67109d556a4a..32b2f33865f9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4033,6 +4033,7 @@ static DEFINE_IDR(mem_cgroup_idr);
>  
>  static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> +	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
>  	atomic_add(n, &memcg->id.ref);
>  }
>  
> @@ -4056,6 +4057,7 @@ static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> +	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
>  	if (atomic_sub_and_test(n, &memcg->id.ref)) {
>  		idr_remove(&mem_cgroup_idr, memcg->id.id);
>  		memcg->id.id = 0;
> @@ -4176,6 +4178,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	INIT_LIST_HEAD(&memcg->cgwb_list);
>  #endif
>  	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
> +	atomic_set(&memcg->id.ref, 1);
>  	return memcg;
>  fail:
>  	if (memcg->id.id > 0)
> @@ -4245,7 +4248,6 @@ fail:
>  static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  {
>  	/* Online state pins memcg ID, memcg ID pins CSS */
> -	mem_cgroup_id_get(mem_cgroup_from_css(css));
>  	css_get(css);
>  	return 0;
>  }
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
