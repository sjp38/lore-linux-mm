Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A14316B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 08:49:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1-v6so14029146eds.15
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:49:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19-v6sor10530099edg.4.2018.10.16.05.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 05:49:48 -0700 (PDT)
Date: Tue, 16 Oct 2018 14:49:39 +0200
From: Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH] mm: Convert mem_cgroup_id::ref to refcount_t type
Message-ID: <20181016124939.GA13278@andrea>
References: <153910718919.7006.13400779039257185427.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153910718919.7006.13400779039257185427.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Kirill,

On Tue, Oct 09, 2018 at 08:46:56PM +0300, Kirill Tkhai wrote:
> This will allow to use generic refcount_t interfaces
> to check counters overflow instead of currently existing
> VM_BUG_ON(). The only difference after the patch is
> VM_BUG_ON() may cause BUG(), while refcount_t fires
> with WARN().

refcount_{sub_and_test,inc_not_zero}() are documented to provide
"slightly" more relaxed ordering than their atomic_* counterpart,
c.f.,

  Documentation/core-api/refcount-vs-atomic.rst
  lib/refcount.c (inline comments)

IIUC, this semantic change won't cause problems here (but please
double-check? ;D ).

  Andrea


>But this seems not to be significant here,
> since such the problems are usually caught by syzbot
> with panic-on-warn enabled.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |    2 +-
>  mm/memcontrol.c            |   10 ++++------
>  2 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4399cc3f00e4..7ab2120155a4 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -78,7 +78,7 @@ struct mem_cgroup_reclaim_cookie {
>  
>  struct mem_cgroup_id {
>  	int id;
> -	atomic_t ref;
> +	refcount_t ref;
>  };
>  
>  /*
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7bebe2ddec05..aa728d5b3d72 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4299,14 +4299,12 @@ static void mem_cgroup_id_remove(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> -	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
> -	atomic_add(n, &memcg->id.ref);
> +	refcount_add(n, &memcg->id.ref);
>  }
>  
>  static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> -	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
> -	if (atomic_sub_and_test(n, &memcg->id.ref)) {
> +	if (refcount_sub_and_test(n, &memcg->id.ref)) {
>  		mem_cgroup_id_remove(memcg);
>  
>  		/* Memcg ID pins CSS */
> @@ -4523,7 +4521,7 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	}
>  
>  	/* Online state pins memcg ID, memcg ID pins CSS */
> -	atomic_set(&memcg->id.ref, 1);
> +	refcount_set(&memcg->id.ref, 1);
>  	css_get(css);
>  	return 0;
>  }
> @@ -6357,7 +6355,7 @@ subsys_initcall(mem_cgroup_init);
>  #ifdef CONFIG_MEMCG_SWAP
>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
>  {
> -	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> +	while (!refcount_inc_not_zero(&memcg->id.ref)) {
>  		/*
>  		 * The root cgroup cannot be destroyed, so it's refcount must
>  		 * always be >= 1.
> 
