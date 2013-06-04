Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 928CC6B003A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 09:03:39 -0400 (EDT)
Date: Tue, 4 Jun 2013 15:03:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] memcg: fix subtle memory barrier bug in
 mem_cgroup_iter()
Message-ID: <20130604130336.GE31242@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-2-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370306679-13129-2-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Mon 03-06-13 17:44:37, Tejun Heo wrote:
[...]
> @@ -1218,9 +1218,18 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			 * is alive.
>  			 */
>  			dead_count = atomic_read(&root->dead_count);
> -			smp_rmb();
> +
>  			last_visited = iter->last_visited;
>  			if (last_visited) {
> +				/*
> +				 * Paired with smp_wmb() below in this
> +				 * function.  The pair guarantee that
> +				 * last_visited is more current than
> +				 * last_dead_count, which may lead to
> +				 * spurious iteration resets but guarantees
> +				 * reliable detection of dead condition.
> +				 */
> +				smp_rmb();
>  				if ((dead_count != iter->last_dead_count) ||
>  					!css_tryget(&last_visited->css)) {
>  					last_visited = NULL;

I originally had the barrier this way but Johannes pointed out it is not
correct https://lkml.org/lkml/2013/2/11/411
"
!> +			/*
!> +			 * last_visited might be invalid if some of the group
!> +			 * downwards was removed. As we do not know which one
!> +			 * disappeared we have to start all over again from the
!> +			 * root.
!> +			 * css ref count then makes sure that css won't
!> +			 * disappear while we iterate to the next memcg
!> +			 */
!> +			last_visited = iter->last_visited;
!> +			dead_count = atomic_read(&root->dead_count);
!> +			smp_rmb();
!
!Confused about this barrier, see below.
!
!As per above, if you remove the iter lock, those lines are mixed up.
!You need to read the dead count first because the writer updates the
!dead count after it sets the new position.  That way, if the dead
!count gives the go-ahead, you KNOW that the position cache is valid,
!because it has been updated first.  If either the two reads or the two
!writes get reordered, you risk seeing a matching dead count while the
!position cache is stale.
"

I think that explanation makes sense but I will leave
further explanation to Mr "I do not like mutual exclusion" :P
(https://lkml.org/lkml/2013/2/11/501 "My bumper sticker reads "I don't
believe in mutual exclusion" (the kernel hacker's version of smile for
the red light camera)")

> @@ -1235,6 +1244,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  				css_put(&last_visited->css);
>  
>  			iter->last_visited = memcg;
> +			/* paired with smp_rmb() above in this function */
>  			smp_wmb();
>  			iter->last_dead_count = dead_count;
>  
> -- 
> 1.8.2.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
