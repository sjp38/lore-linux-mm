Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 627E16B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 02:02:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ECC713EE0BB
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:02:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D9E45DE58
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:02:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 90C6545DE5A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:02:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56A14E08005
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:02:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 018831DB8047
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:02:15 +0900 (JST)
Message-ID: <4F827AF8.9070204@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 15:00:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 10/14] hugetlbfs: Add memcg control files for hugetlbfs
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/07 3:50), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add control files for hugetlbfs in memcg
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


seems ok. This uses Tejun's new interface...right ?

It might be better to explain "this patch depends on "cgroup: implement
cgroup_add_cftypes() and friends" patch via cgroup development tree.

Anyway,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  include/linux/hugetlb.h    |    5 +++++
>  include/linux/memcontrol.h |    7 ++++++
>  mm/hugetlb.c               |    2 +-
>  mm/memcontrol.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 64 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 995c238..d008342 100644
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
> @@ -203,6 +204,10 @@ struct hstate {
>  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
>  	unsigned int free_huge_pages_node[MAX_NUMNODES];
>  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +	/* mem cgroup control files */
> +	struct cftype mem_cgroup_files[4];
> +#endif
>  	char name[HSTATE_NAME_LEN];
>  };
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1d07e14..4f17574 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -459,6 +459,7 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
>  					     struct page *page);
>  extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  					      struct mem_cgroup *memcg);
> +extern int mem_cgroup_hugetlb_file_init(int idx) __init;
>  
>  #else
>  static inline int
> @@ -489,6 +490,12 @@ mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
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
> index dd00087..340e575 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1931,7 +1931,7 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
>  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
>  					huge_page_size(h)/1024);
> -
> +	mem_cgroup_hugetlb_file_init(hugetlb_max_hstate - 1);
>  	parsed_hstate = h;
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3bb3b42..7d3330e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5191,6 +5191,57 @@ static void mem_cgroup_destroy(struct cgroup *cont)
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
> +int __init mem_cgroup_hugetlb_file_init(int idx)
> +{
> +	char buf[32];
> +	struct cftype *cft;
> +	struct hstate *h = &hstates[idx];
> +
> +	/* format the size */
> +	mem_fmt(buf, huge_page_size(h));
> +
> +	/* Add the limit file */
> +	cft = &h->mem_cgroup_files[0];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.limit_in_bytes", buf);
> +	cft->private = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_LIMIT);
> +	cft->read = mem_cgroup_read;
> +	cft->write_string = mem_cgroup_write;
> +
> +	/* Add the usage file */
> +	cft = &h->mem_cgroup_files[1];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.usage_in_bytes", buf);
> +	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_USAGE);
> +	cft->read = mem_cgroup_read;
> +
> +	/* Add the MAX usage file */
> +	cft = &h->mem_cgroup_files[2];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.max_usage_in_bytes", buf);
> +	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_MAX_USAGE);
> +	cft->trigger  = mem_cgroup_reset;
> +	cft->read = mem_cgroup_read;
> +
> +	/* NULL terminate the last cft */
> +	cft = &h->mem_cgroup_files[3];
> +	memset(cft, 0, sizeof(*cft));
> +
> +	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, h->mem_cgroup_files));
> +
> +	return 0;
> +}
> +#endif
> +
>  static int mem_cgroup_populate(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
