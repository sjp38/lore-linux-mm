Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6953E6B00F7
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:24:27 -0400 (EDT)
Date: Mon, 11 Jun 2012 11:24:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 15/16] hugetlb/cgroup: migrate hugetlb cgroup info
 from oldpage to new page during migration
Message-ID: <20120611092424.GJ12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat 09-06-12 14:30:00, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> With HugeTLB pages, hugetlb cgroup is uncharged in compound page
> destructor.  Since we are holding a hugepage reference,

Who is holding that reference? I do not see anybody calling get_page in
this patch...

> we can be sure that old page won't get uncharged till the last
> put_page().
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb_cgroup.h |    8 ++++++++
>  mm/hugetlb_cgroup.c            |   21 +++++++++++++++++++++
>  mm/migrate.c                   |    5 +++++
>  3 files changed, 34 insertions(+)
> 
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> index ba4836f..b64d067 100644
> --- a/include/linux/hugetlb_cgroup.h
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -63,6 +63,8 @@ extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
>  extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  					   struct hugetlb_cgroup *h_cg);
>  extern int hugetlb_cgroup_file_init(int idx) __init;
> +extern void hugetlb_cgroup_migrate(struct page *oldhpage,
> +				   struct page *newhpage);
>  #else
>  static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
>  {
> @@ -112,5 +114,11 @@ static inline int __init hugetlb_cgroup_file_init(int idx)
>  {
>  	return 0;
>  }
> +
> +static inline void hugetlb_cgroup_migrate(struct page *oldhpage,
> +					  struct page *newhpage)
> +{
> +	return;
> +}
>  #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  #endif
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index c2b7b8e..2d384fe 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -394,6 +394,27 @@ int __init hugetlb_cgroup_file_init(int idx)
>  	return 0;
>  }
>  
> +void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
> +{
> +	struct hugetlb_cgroup *h_cg;
> +
> +	VM_BUG_ON(!PageHuge(oldhpage));
> +
> +	if (hugetlb_cgroup_disabled())
> +		return;
> +
> +	spin_lock(&hugetlb_lock);
> +	h_cg = hugetlb_cgroup_from_page(oldhpage);
> +	set_hugetlb_cgroup(oldhpage, NULL);
> +	cgroup_exclude_rmdir(&h_cg->css);
> +
> +	/* move the h_cg details to new cgroup */
> +	set_hugetlb_cgroup(newhpage, h_cg);
> +	spin_unlock(&hugetlb_lock);
> +	cgroup_release_and_wakeup_rmdir(&h_cg->css);
> +	return;
> +}
> +
>  struct cgroup_subsys hugetlb_subsys = {
>  	.name = "hugetlb",
>  	.create     = hugetlb_cgroup_create,
> diff --git a/mm/migrate.c b/mm/migrate.c
> index fdce3a2..6c37c51 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -33,6 +33,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/syscalls.h>
>  #include <linux/hugetlb.h>
> +#include <linux/hugetlb_cgroup.h>
>  #include <linux/gfp.h>
>  
>  #include <asm/tlbflush.h>
> @@ -931,6 +932,10 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
> +
> +	if (!rc)
> +		hugetlb_cgroup_migrate(hpage, new_hpage);
> +
>  	unlock_page(hpage);
>  out:
>  	put_page(new_hpage);
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
