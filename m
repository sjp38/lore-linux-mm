Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 862096B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:30:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so98872461lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:30:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c6si3671208wjq.184.2016.08.02.10.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:30:13 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:27:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 3/3] mm: memcontrol: add sanity checks for
 memcg->id.ref on get/put
Message-ID: <20160802172736.GC6637@cmpxchg.org>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <32402ace75b459c8523f5b237a62061e1df7a3b5.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32402ace75b459c8523f5b237a62061e1df7a3b5.1470149524.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 06:00:50PM +0300, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
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

This comment and code is no very, very confusing. Can you move the
atomic_set(&memcg->id.ref, 1) down here instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
