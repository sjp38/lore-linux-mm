Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D5A608D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:45:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 21E213EE0CF
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:45:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0546C45DEB5
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:45:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AB345DEBE
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:45:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C58621DB803E
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:45:44 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4939EE08004
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:45:44 +0900 (JST)
Message-ID: <50DCF9AB.3060503@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 10:45:15 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 7/8] memcg: disable memcg page stat accounting code
 when not in use
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456477-14780-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356456477-14780-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

(2012/12/26 2:27), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> It's inspired by a similar optimization from Glauber Costa
> (memcg: make it suck faster; https://lkml.org/lkml/2012/9/25/154).
> Here we use jump label to patch the memcg page stat accounting code
> in or out when not used. when the first non-root memcg comes to
> life the code is patching in otherwise it is out.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>   include/linux/memcontrol.h |    9 +++++++++
>   mm/memcontrol.c            |    8 ++++++++
>   2 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1d22b81..3c4430c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -56,6 +56,9 @@ struct mem_cgroup_reclaim_cookie {
>   };
>   
>   #ifdef CONFIG_MEMCG
> +
> +extern struct static_key memcg_in_use_key;
> +
>   /*
>    * All "charge" functions with gfp_mask should use GFP_KERNEL or
>    * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> @@ -158,6 +161,9 @@ extern atomic_t memcg_moving;
>   static inline void mem_cgroup_begin_update_page_stat(struct page *page,
>   					bool *locked, unsigned long *flags)
>   {
> +	if (!static_key_false(&memcg_in_use_key))
> +		return;
> +
>   	if (mem_cgroup_disabled())
>   		return;
>   	rcu_read_lock();
> @@ -171,6 +177,9 @@ void __mem_cgroup_end_update_page_stat(struct page *page,
>   static inline void mem_cgroup_end_update_page_stat(struct page *page,
>   					bool *locked, unsigned long *flags)
>   {
> +	if (!static_key_false(&memcg_in_use_key))
> +		return;
> +
>   	if (mem_cgroup_disabled())
>   		return;
>   	if (*locked)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0cb5187..a2f73d7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -531,6 +531,8 @@ enum res_type {
>   #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>   #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
>   
> +struct static_key memcg_in_use_key;
> +
>   static void mem_cgroup_get(struct mem_cgroup *memcg);
>   static void mem_cgroup_put(struct mem_cgroup *memcg);
>   
> @@ -2226,6 +2228,9 @@ void mem_cgroup_update_page_stat(struct page *page,
>   	struct page_cgroup *pc = lookup_page_cgroup(page);
>   	unsigned long uninitialized_var(flags);
>   
> +	if (!static_key_false(&memcg_in_use_key))
> +		return;
> +
>   	if (mem_cgroup_disabled())
>   		return;
>   
> @@ -6340,6 +6345,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>   		parent = mem_cgroup_from_cont(cont->parent);
>   		memcg->use_hierarchy = parent->use_hierarchy;
>   		memcg->oom_kill_disable = parent->oom_kill_disable;
> +
> +		static_key_slow_inc(&memcg_in_use_key);
>   	}
>   
>   	if (parent && parent->use_hierarchy) {
> @@ -6407,6 +6414,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>   	kmem_cgroup_destroy(memcg);
>   
>   	memcg_dangling_add(memcg);
> +	static_key_slow_dec(&memcg_in_use_key);

Hmm. I think this part should be folded into disarm_static_keys().

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
