Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 386736B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 22:58:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C61AC3EE0BB
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:58:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A6E9045DE5A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:58:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CEBD45DE55
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:58:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 802F91DB8054
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:58:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AFF71DB8046
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:58:06 +0900 (JST)
Message-ID: <4F66A059.20801@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 11:56:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 07/10] hugetlbfs: Add memcg control files for hugetlbfs
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331919570-2264-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/03/17 2:39), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add control files for hugetlbfs in memcg
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


I have a question. When a user does

	1. create memory cgroup as
		/cgroup/A
	2. insmod hugetlb.ko
	3. ls /cgroup/A

and then, files can be shown ? Don't we have any problem at rmdir A ?

I'm sorry if hugetlb never be used as module.

a comment below.

> ---
>  include/linux/hugetlb.h    |   17 +++++++++++++++
>  include/linux/memcontrol.h |    7 ++++++
>  mm/hugetlb.c               |   25 ++++++++++++++++++++++-
>  mm/memcontrol.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 96 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 1f70068..cbd8dc5 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -4,6 +4,7 @@
>  #include <linux/mm_types.h>
>  #include <linux/fs.h>
>  #include <linux/hugetlb_inline.h>
> +#include <linux/cgroup.h>
>  
>  struct ctl_table;
>  struct user_struct;
> @@ -220,6 +221,12 @@ struct hstate {
>  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
>  	unsigned int free_huge_pages_node[MAX_NUMNODES];
>  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> +	/* mem cgroup control files */
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +	struct cftype cgroup_limit_file;
> +	struct cftype cgroup_usage_file;
> +	struct cftype cgroup_max_usage_file;
> +#endif
>  	char name[HSTATE_NAME_LEN];
>  };
>  
> @@ -338,4 +345,14 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>  #define hstate_index(h) 0
>  #endif
>  
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +extern int register_hugetlb_memcg_files(struct cgroup *cgroup,
> +					struct cgroup_subsys *ss);
> +#else
> +static inline int register_hugetlb_memcg_files(struct cgroup *cgroup,
> +					       struct cgroup_subsys *ss)
> +{
> +	return 0;
> +}
> +#endif
>  #endif /* _LINUX_HUGETLB_H */
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 320dbad..73900b9 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -440,6 +440,7 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
>  					     struct page *page);
>  extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  					      struct mem_cgroup *memcg);
> +extern int mem_cgroup_hugetlb_file_init(int idx);
>  
>  #else
>  static inline int
> @@ -470,6 +471,12 @@ mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  {
>  	return;
>  }
> +
> +static inline int mem_cgroup_hugetlb_file_init(int idx)
> +{
> +	return 0;
> +}
> +
>  #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  #endif /* _LINUX_MEMCONTROL_H */
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 91361a0..684849a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1819,6 +1819,29 @@ static int __init hugetlb_init(void)
>  }
>  module_init(hugetlb_init);
>  
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +int register_hugetlb_memcg_files(struct cgroup *cgroup,
> +				 struct cgroup_subsys *ss)
> +{

> +	int ret = 0;
> +	struct hstate *h;
> +
> +	for_each_hstate(h) {
> +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_limit_file);
> +		if (ret)
> +			return ret;
> +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_usage_file);
> +		if (ret)
> +			return ret;
> +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_max_usage_file);
> +		if (ret)
> +			return ret;
> +
> +	}
> +	return ret;
> +}
> +#endif
> +
>  /* Should be called on processing a hugepagesz=... option */
>  void __init hugetlb_add_hstate(unsigned order)
>  {
> @@ -1842,7 +1865,7 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
>  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
>  					huge_page_size(h)/1024);
> -
> +	mem_cgroup_hugetlb_file_init(hugetlb_max_hstate - 1);
>  	parsed_hstate = h;
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d8b3513..4900b72 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5123,6 +5123,51 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  	mem_cgroup_put(memcg);
>  }
>  
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +static char *mem_fmt(char *buf, unsigned long n)
> +{
> +	if (n >= (1UL << 30))
> +		sprintf(buf, "%luGB", n >> 30);
> +	else if (n >= (1UL << 20))
> +		sprintf(buf, "%luMB", n >> 20);
> +	else
> +		sprintf(buf, "%luKB", n >> 10);
> +	return buf;
> +}
> +
> +int mem_cgroup_hugetlb_file_init(int idx)
> +{


__init ? And... do we have guarantee that this function is called before
creating root mem cgroup even if CONFIG_HUGETLBFS=y ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
