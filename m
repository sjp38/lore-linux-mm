Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 648B36B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 15:13:29 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id l4so292904lbv.7
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 12:13:28 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x7si3034541lag.96.2013.12.14.12.13.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 12:13:27 -0800 (PST)
Message-ID: <52ACBBE5.1020806@parallels.com>
Date: Sun, 15 Dec 2013 00:13:25 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [Devel] [PATCH 2/2] memcg: do not use vmalloc for mem_cgroup
 allocations
References: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com> <ce02d52baac3730d659c046a181c2784c6cee2c4.1387007793.git.vdavydov@parallels.com>
In-Reply-To: <ce02d52baac3730d659c046a181c2784c6cee2c4.1387007793.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, devel@openvz.org

On 12/14/2013 12:15 PM, Vladimir Davydov wrote:
> The vmalloc was introduced by patch 333279 ("memcgroup: use vmalloc for
> mem_cgroup allocation"), because at that time MAX_NUMNODES was used for
> defining the per-node array in the mem_cgroup structure so that the
> structure could be huge even if the system had the only NUMA node.
>
> The situation was significantly improved by patch 45cf7e ("memcg: reduce
> the size of struct memcg 244-fold"), which made the size of the
> mem_cgroup structure calculated dynamically depending on the real number
> of NUMA nodes installed on the system (nr_node_ids), so now there is no
> point in using vmalloc here: the structure is allocated rarely and on
> most systems its size is about 1K.

After a bit of thinking I refused to use wait_on_bit() on
kmem_account_flags in the kmemcg shrinkers patchset I'm trying to
submit, so if this patch is going to be committed, it is better to
remove the paragraph below from the commit message :-)

However, I still think this patch is reasonable, because I haven't found
a place in the kernel source tree where we used vmalloc() for allocating
an array of nr_node_ids pointers. On the other hand, there are plenty of
places where we allocate per-node data using kmalloc. For instance, in
list_lru_init() we have

    size_t size = sizeof(struct list_lru_node) * nr_node_ids;
    lru->node = kzalloc(size, GFP_KERNEL);

where the list_lru_node structure is at least 4 words at size.

> Personally I'd like to remove this vmalloc, because I'm considering
> using wait_on_bit() on mem_cgroup::kmem_account_flags in the kmemcg
> shrinkers implementation, which is impossible on vmalloc'd areas.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   28 ++++++----------------------
>  1 file changed, 6 insertions(+), 22 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7f1a356..205eb7b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -48,7 +48,6 @@
>  #include <linux/sort.h>
>  #include <linux/fs.h>
>  #include <linux/seq_file.h>
> -#include <linux/vmalloc.h>
>  #include <linux/vmpressure.h>
>  #include <linux/mm_inline.h>
>  #include <linux/page_cgroup.h>
> @@ -335,12 +334,6 @@ struct mem_cgroup {
>  	/* WARNING: nodeinfo must be the last member here */
>  };
>  
> -static size_t memcg_size(void)
> -{
> -	return sizeof(struct mem_cgroup) +
> -		nr_node_ids * sizeof(struct mem_cgroup_per_node *);
> -}
> -
>  /* internal only representation about the status of kmem accounting. */
>  enum {
>  	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
> @@ -6139,14 +6132,12 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  static struct mem_cgroup *mem_cgroup_alloc(void)
>  {
>  	struct mem_cgroup *memcg;
> -	size_t size = memcg_size();
> +	size_t size;
>  
> -	/* Can be very big if nr_node_ids is very big */
> -	if (size < PAGE_SIZE)
> -		memcg = kzalloc(size, GFP_KERNEL);
> -	else
> -		memcg = vzalloc(size);
> +	size = sizeof(struct mem_cgroup);
> +	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
>  
> +	memcg = kzalloc(size, GFP_KERNEL);
>  	if (!memcg)
>  		return NULL;
>  
> @@ -6157,10 +6148,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	return memcg;
>  
>  out_free:
> -	if (size < PAGE_SIZE)
> -		kfree(memcg);
> -	else
> -		vfree(memcg);
> +	kfree(memcg);
>  	return NULL;
>  }
>  
> @@ -6178,7 +6166,6 @@ out_free:
>  static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  {
>  	int node;
> -	size_t size = memcg_size();
>  
>  	mem_cgroup_remove_from_trees(memcg);
>  
> @@ -6199,10 +6186,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  	 * the cgroup_lock.
>  	 */
>  	disarm_static_keys(memcg);
> -	if (size < PAGE_SIZE)
> -		kfree(memcg);
> -	else
> -		vfree(memcg);
> +	kfree(memcg);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
