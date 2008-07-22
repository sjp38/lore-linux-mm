Date: Tue, 22 Jul 2008 01:45:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2][-mm][resend] memcg limit change shrink usage.
Message-Id: <20080722014517.04e88306.akpm@linux-foundation.org>
In-Reply-To: <20080714171522.d1cd50e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080714171154.e1cc9943.kamezawa.hiroyu@jp.fujitsu.com>
	<20080714171522.d1cd50e9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jul 2008 17:15:22 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Shrinking memory usage at limit change.

The above six words are all we really have as a changelog.  It is not
adequate.

> This is an enhancement (in TODO list).
> based on res_counter-limit-change-ebusy.patch
> 
> Changelog: v2 -> v3
>   - supported interrupt by signal. (A user can stop limit change by Ctrl-C.)
> Changelog: v1 -> v2
>   - adjusted to be based on write_string() patch set
>   - removed backword goto.
>   - removed unneccesary cond_resched().
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  Documentation/controllers/memory.txt |    3 --
>  mm/memcontrol.c                      |   48 ++++++++++++++++++++++++++++++++---
>  2 files changed, 45 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6.26-rc8-mm1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.26-rc8-mm1.orig/mm/memcontrol.c
> +++ linux-2.6.26-rc8-mm1/mm/memcontrol.c
> @@ -836,6 +836,30 @@ int mem_cgroup_shrink_usage(struct mm_st
>  	return 0;
>  }
>  
> +int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
> +{
> +
> +	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> +	int progress;
> +	int ret = 0;
> +
> +	while (res_counter_set_limit(&memcg->res, val)) {
> +		if (signal_pending(current)) {
> +			ret = -EINTR;
> +			break;
> +		}
> +		if (!retry_count) {
> +			ret = -EBUSY;
> +			break;
> +		}
> +		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
> +		if (!progress)
> +			retry_count--;
> +	}
> +	return ret;
> +}

We could perhaps get away with a basically-unchanglogged patch if the
code was adequately commented.  But it is not.

What the heck does this function *do*?  Why does it exist?

Guys, this is core Linux kernel, not some weekend hack project.  Please
work to make it as comprehensible and as maintainable as we possibly
can.

Also, it is frequently a mistake for a callee to assume that the caller
can use GFP_KERNEL.  Often when we do this we end having to change the
interface so that the caller passes in the gfp_t.  As there's only one
caller I guess we can get away with it this time.  For now.

> +
>  /*
>   * This routine traverse page_cgroup in given list and drop them all.
>   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> @@ -916,13 +940,29 @@ static u64 mem_cgroup_read(struct cgroup
>  	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
>  				    cft->private);
>  }
> -
> +/*
> + * The user of this function is...
> + * RES_LIMIT.
> + */
>  static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  			    const char *buffer)
>  {
> -	return res_counter_write(&mem_cgroup_from_cont(cont)->res,
> -				 cft->private, buffer,
> -				 res_counter_memparse_write_strategy);
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	unsigned long long val;
> +	int ret;
> +
> +        switch (cft->private) {
> +	case RES_LIMIT:
> +		/* This function does all necessary parse...reuse it */
> +		ret = res_counter_memparse_write_strategy(buffer, &val);
> +		if (!ret)
> +			ret = mem_cgroup_resize_limit(memcg, val);
> +		break;
> +	default:
> +		ret = -EINVAL; /* should be BUG() ? */
> +		break;
> +	}
> +	return ret;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
