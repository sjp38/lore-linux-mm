Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 329A26B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:24:12 -0400 (EDT)
Date: Thu, 14 Jun 2012 10:24:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 09/15] mm/hugetlb: Add new HugeTLB cgroup
Message-ID: <20120614082406.GG27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339583254-895-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 15:57:28, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch implements a new controller that allows us to control HugeTLB
> allocations. The extension allows to limit the HugeTLB usage per control
> group and enforces the controller limit during page fault.  Since HugeTLB
> doesn't support page reclaim, enforcing the limit at page fault time implies
> that, the application will get SIGBUS signal if it tries to access HugeTLB
> pages beyond its limit. This requires the application to know beforehand
> how much HugeTLB pages it would require for its use.
> 
> The charge/uncharge calls will be added to HugeTLB code in later patch.
> Support for cgroup removal will be added in later patches.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Looks good
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/cgroup_subsys.h  |    6 ++
>  include/linux/hugetlb_cgroup.h |   37 ++++++++++++
>  init/Kconfig                   |   15 +++++
>  mm/Makefile                    |    1 +
>  mm/hugetlb_cgroup.c            |  122 ++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 181 insertions(+)
>  create mode 100644 include/linux/hugetlb_cgroup.h
>  create mode 100644 mm/hugetlb_cgroup.c
> 
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index 0bd390c..895923a 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -72,3 +72,9 @@ SUBSYS(net_prio)
>  #endif
>  
>  /* */
> +
> +#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> +SUBSYS(hugetlb)
> +#endif
> +
> +/* */
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> new file mode 100644
> index 0000000..e9944b4
> --- /dev/null
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -0,0 +1,37 @@
> +/*
> + * Copyright IBM Corporation, 2012
> + * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of version 2.1 of the GNU Lesser General Public License
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */
> +
> +#ifndef _LINUX_HUGETLB_CGROUP_H
> +#define _LINUX_HUGETLB_CGROUP_H
> +
> +#include <linux/res_counter.h>
> +
> +struct hugetlb_cgroup;
> +
> +#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> +static inline bool hugetlb_cgroup_disabled(void)
> +{
> +	if (hugetlb_subsys.disabled)
> +		return true;
> +	return false;
> +}
> +
> +#else
> +static inline bool hugetlb_cgroup_disabled(void)
> +{
> +	return true;
> +}
> +
> +#endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
> +#endif
> diff --git a/init/Kconfig b/init/Kconfig
> index d07dcf9..da05fae 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -751,6 +751,21 @@ config CGROUP_MEM_RES_CTLR_KMEM
>  	  the kmem extension can use it to guarantee that no group of processes
>  	  will ever exhaust kernel resources alone.
>  
> +config CGROUP_HUGETLB_RES_CTLR
> +	bool "HugeTLB Resource Controller for Control Groups"
> +	depends on RESOURCE_COUNTERS && HUGETLB_PAGE && EXPERIMENTAL
> +	default n
> +	help
> +	  Provides a cgroup Resource Controller for HugeTLB pages.
> +	  When you enable this, you can put a per cgroup limit on HugeTLB usage.
> +	  The limit is enforced during page fault. Since HugeTLB doesn't
> +	  support page reclaim, enforcing the limit at page fault time implies
> +	  that, the application will get SIGBUS signal if it tries to access
> +	  HugeTLB pages beyond its limit. This requires the application to know
> +	  beforehand how much HugeTLB pages it would require for its use. The
> +	  control group is tracked in the third page lru pointer. This means
> +	  that we cannot use the controller with huge page less than 3 pages.
> +
>  config CGROUP_PERF
>  	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
>  	depends on PERF_EVENTS && CGROUPS
> diff --git a/mm/Makefile b/mm/Makefile
> index 2e2fbbe..25e8002 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -49,6 +49,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>  obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
> +obj-$(CONFIG_CGROUP_HUGETLB_RES_CTLR) += hugetlb_cgroup.o
>  obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> new file mode 100644
> index 0000000..5a4e71c
> --- /dev/null
> +++ b/mm/hugetlb_cgroup.c
> @@ -0,0 +1,122 @@
> +/*
> + *
> + * Copyright IBM Corporation, 2012
> + * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of version 2.1 of the GNU Lesser General Public License
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */
> +
> +#include <linux/cgroup.h>
> +#include <linux/slab.h>
> +#include <linux/hugetlb.h>
> +#include <linux/hugetlb_cgroup.h>
> +
> +struct hugetlb_cgroup {
> +	struct cgroup_subsys_state css;
> +	/*
> +	 * the counter to account for hugepages from hugetlb.
> +	 */
> +	struct res_counter hugepage[HUGE_MAX_HSTATE];
> +};
> +
> +struct cgroup_subsys hugetlb_subsys __read_mostly;
> +struct hugetlb_cgroup *root_h_cgroup __read_mostly;
> +
> +static inline
> +struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
> +{
> +	if (s)
> +		return container_of(s, struct hugetlb_cgroup, css);
> +	return NULL;
> +}
> +
> +static inline
> +struct hugetlb_cgroup *hugetlb_cgroup_from_cgroup(struct cgroup *cgroup)
> +{
> +	return hugetlb_cgroup_from_css(cgroup_subsys_state(cgroup,
> +							   hugetlb_subsys_id));
> +}
> +
> +static inline
> +struct hugetlb_cgroup *hugetlb_cgroup_from_task(struct task_struct *task)
> +{
> +	return hugetlb_cgroup_from_css(task_subsys_state(task,
> +							 hugetlb_subsys_id));
> +}
> +
> +static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
> +{
> +	return (h_cg == root_h_cgroup);
> +}
> +
> +static inline struct hugetlb_cgroup *parent_hugetlb_cgroup(struct cgroup *cg)
> +{
> +	if (!cg->parent)
> +		return NULL;
> +	return hugetlb_cgroup_from_cgroup(cg->parent);
> +}
> +
> +static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
> +{
> +	int idx;
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
> +
> +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> +		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
> +			return true;
> +	}
> +	return false;
> +}
> +
> +static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
> +{
> +	int idx;
> +	struct cgroup *parent_cgroup;
> +	struct hugetlb_cgroup *h_cgroup, *parent_h_cgroup;
> +
> +	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
> +	if (!h_cgroup)
> +		return ERR_PTR(-ENOMEM);
> +
> +	parent_cgroup = cgroup->parent;
> +	if (parent_cgroup) {
> +		parent_h_cgroup = hugetlb_cgroup_from_cgroup(parent_cgroup);
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&h_cgroup->hugepage[idx],
> +					 &parent_h_cgroup->hugepage[idx]);
> +	} else {
> +		root_h_cgroup = h_cgroup;
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&h_cgroup->hugepage[idx], NULL);
> +	}
> +	return &h_cgroup->css;
> +}
> +
> +static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
> +{
> +	struct hugetlb_cgroup *h_cgroup;
> +
> +	h_cgroup = hugetlb_cgroup_from_cgroup(cgroup);
> +	kfree(h_cgroup);
> +}
> +
> +static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
> +{
> +	/* We will add the cgroup removal support in later patches */
> +	   return -EBUSY;
> +}
> +
> +struct cgroup_subsys hugetlb_subsys = {
> +	.name = "hugetlb",
> +	.create     = hugetlb_cgroup_create,
> +	.pre_destroy = hugetlb_cgroup_pre_destroy,
> +	.destroy    = hugetlb_cgroup_destroy,
> +	.subsys_id  = hugetlb_subsys_id,
> +};
> -- 
> 1.7.10
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
