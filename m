Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id ACDDE6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 02:52:26 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so2974044pdj.9
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 23:52:26 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pc3si13331794pdb.206.2014.10.21.23.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 23:52:25 -0700 (PDT)
Date: Wed, 22 Oct 2014 10:52:17 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/4] mm: memcontrol: don't pass a NULL memcg to
 mem_cgroup_end_move()
Message-ID: <20141022065217.GS16496@esperanza>
References: <1413922896-29042-1-git-send-email-hannes@cmpxchg.org>
 <1413922896-29042-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413922896-29042-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 21, 2014 at 04:21:34PM -0400, Johannes Weiner wrote:
> mem_cgroup_end_move() checks if the passed memcg is NULL, along with a
> lengthy comment to explain why this seemingly non-sensical situation
> is even possible.
> 
> Check in cancel_attach() itself whether can_attach() set up the move
> context or not, it's a lot more obvious from there.  Then remove the
> check and comment in mem_cgroup_end_move().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

> ---
>  mm/memcontrol.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1ff125d2a427..c1fe774d712a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1452,14 +1452,8 @@ static void mem_cgroup_start_move(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>  {
> -	/*
> -	 * Now, mem_cgroup_clear_mc() may call this function with NULL.
> -	 * We check NULL in callee rather than caller.
> -	 */
> -	if (memcg) {
> -		atomic_dec(&memcg_moving);
> -		atomic_dec(&memcg->moving_account);
> -	}
> +	atomic_dec(&memcg_moving);
> +	atomic_dec(&memcg->moving_account);
>  }
>  
>  /*
> @@ -5383,7 +5377,8 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
>  				     struct cgroup_taskset *tset)
>  {
> -	mem_cgroup_clear_mc();
> +	if (mc.to)
> +		mem_cgroup_clear_mc();
>  }
>  
>  static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
> -- 
> 2.1.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
