Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 07551900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:23:22 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 618C43EE0C0
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C6245DE60
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AA8F45DE5B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 177B1E38006
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBFAAE38003
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:17 +0900 (JST)
Date: Fri, 15 Apr 2011 09:16:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 02/10] Add per memcg reclaim watermarks
Message-Id: <20110415091640.5876f737.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-3-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:21 -0700
Ying Han <yinghan@google.com> wrote:

> There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
> The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
> is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
> until the usage is lower than the high_wmark.
> 
> Each watermark is calculated based on the hard_limit(limit_in_bytes) for each
> memcg. Each time the hard_limit is changed, the corresponding wmarks are
> re-calculated. Since memory controller charges only user pages, there is
> no need for a "min_wmark". The current calculation of wmarks is based on
> individual tunable low/high_wmark_distance, which are set to 0 by default.
> 
> changelog v4..v3:
> 1. remove legacy comments
> 2. rename the res_counter_check_under_high_wmark_limit
> 3. replace the wmark_ratio per-memcg by individual tunable for both wmarks.
> 4. add comments on low/high_wmark
> 5. add individual tunables for low/high_wmarks and remove wmark_ratio
> 6. replace the mem_cgroup_get_limit() call by res_count_read_u64(). The first
> one returns large value w/ swapon.
> 
> changelog v3..v2:
> 1. Add VM_BUG_ON() on couple of places.
> 2. Remove the spinlock on the min_free_kbytes since the consequence of reading
> stale data.
> 3. Remove the "min_free_kbytes" API and replace it with wmark_ratio based on
> hard_limit.
> 
> changelog v2..v1:
> 1. Remove the res_counter_charge on wmark due to performance concern.
> 2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate commit.
> 3. Calculate the min_free_kbytes automatically based on the limit_in_bytes.
> 4. make the wmark to be consistant with core VM which checks the free pages
> instead of usage.
> 5. changed wmark to be boolean
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

some nitpick below.



> ---
>  include/linux/memcontrol.h  |    1 +
>  include/linux/res_counter.h |   78 +++++++++++++++++++++++++++++++++++++++++++
>  kernel/res_counter.c        |    6 +++
>  mm/memcontrol.c             |   48 ++++++++++++++++++++++++++
>  4 files changed, 133 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5a5ce70..3ece36d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -82,6 +82,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
>  
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index c9d625c..77eaaa9 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -39,6 +39,14 @@ struct res_counter {
>  	 */
>  	unsigned long long soft_limit;
>  	/*
> +	 * the limit that reclaim triggers.
> +	 */
> +	unsigned long long low_wmark_limit;
> +	/*
> +	 * the limit that reclaim stops.
> +	 */
> +	unsigned long long high_wmark_limit;
> +	/*
>  	 * the number of unsuccessful attempts to consume the resource
>  	 */
>  	unsigned long long failcnt;
> @@ -55,6 +63,9 @@ struct res_counter {
>  
>  #define RESOURCE_MAX (unsigned long long)LLONG_MAX
>  
> +#define CHARGE_WMARK_LOW	0x01
> +#define CHARGE_WMARK_HIGH	0x02
> +
>  /**
>   * Helpers to interact with userspace
>   * res_counter_read_u64() - returns the value of the specified member.
> @@ -92,6 +103,8 @@ enum {
>  	RES_LIMIT,
>  	RES_FAILCNT,
>  	RES_SOFT_LIMIT,
> +	RES_LOW_WMARK_LIMIT,
> +	RES_HIGH_WMARK_LIMIT
>  };
>  
>  /*
> @@ -147,6 +160,24 @@ static inline unsigned long long res_counter_margin(struct res_counter *cnt)
>  	return margin;
>  }
>  
> +static inline bool
> +res_counter_high_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +	if (cnt->usage < cnt->high_wmark_limit)
> +		return true;
> +
> +	return false;
> +}
> +
> +static inline bool
> +res_counter_low_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +	if (cnt->usage < cnt->low_wmark_limit)
> +		return true;
> +
> +	return false;
> +}

I like res_counter_under_low_wmark_limit_locked() rather than this name.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
