Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7566F6B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 17:42:35 -0400 (EDT)
Date: Tue, 13 Mar 2012 14:42:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 5/8] hugetlbfs: Add memcg control files for
 hugetlbfs
Message-Id: <20120313144233.49026e6a.akpm@linux-foundation.org>
In-Reply-To: <1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 12:37:09 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add control files for hugetlbfs in memcg
> 
> ...
>
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -220,6 +221,10 @@ struct hstate {
>  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
>  	unsigned int free_huge_pages_node[MAX_NUMNODES];
>  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> +	/* cgroup control files */
> +	struct cftype cgroup_limit_file;
> +	struct cftype cgroup_usage_file;
> +	struct cftype cgroup_max_usage_file;
>  	char name[HSTATE_NAME_LEN];
>  };

We don't need all these in here if, for example, cgroups is disabled?

> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1817,6 +1817,36 @@ static int __init hugetlb_init(void)
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
> +/* mm/memcontrol.c because mem_cgroup_read/write is not availabel outside */

Comment has a spelling mistake.

> +int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);


No, please put it in a header file.  Always.  Where both callers and
the implementation see the same propotype.

> +#else
> +static int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
> +{
> +	return 0;
> +}
> +#endif

So this will go into the same header file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
