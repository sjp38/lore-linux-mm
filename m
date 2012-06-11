Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A94D06B00D6
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 04:53:01 -0400 (EDT)
Date: Mon, 11 Jun 2012 10:52:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 12/16] hugetlb/cgroup: Add support for cgroup removal
Message-ID: <20120611085258.GD12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat 09-06-12 14:29:57, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch add support for cgroup removal. If we don't have parent
> cgroup, the charges are moved to root cgroup.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb_cgroup.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 79 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 48efd5a..9458fe3 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -99,10 +99,87 @@ static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
>  	kfree(h_cgroup);
>  }
>  
> +
> +static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
> +				      struct page *page)

deserves a comment about the locking (needs to be called with
hugetlb_lock).

> +{
> +	int csize;
> +	struct res_counter *counter;
> +	struct res_counter *fail_res;
> +	struct hugetlb_cgroup *page_hcg;
> +	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
> +	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
> +
> +	if (!get_page_unless_zero(page))
> +		goto out;
> +
> +	page_hcg = hugetlb_cgroup_from_page(page);
> +	/*
> +	 * We can have pages in active list without any cgroup
> +	 * ie, hugepage with less than 3 pages. We can safely
> +	 * ignore those pages.
> +	 */
> +	if (!page_hcg || page_hcg != h_cg)
> +		goto err_out;

How can we have page_hcg != NULL && page_hcg != h_cg?

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
