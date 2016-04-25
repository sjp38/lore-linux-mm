Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA896B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:31:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so279779559pfy.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:31:04 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id z62si162567pfi.48.2016.04.25.14.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:30:58 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id 206so22463116pfu.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:30:58 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:30:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, hugetlb_cgroup: round limit_in_bytes down to
 hugepage size
In-Reply-To: <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1604251430280.14793@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com> <5704BA37.2080508@kyup.com> <5704BBBF.8040302@kyup.com> <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Nikolay Borisov <kernel@kyup.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Apr 2016, David Rientjes wrote:

> The page_counter rounds limits down to page size values.  This makes
> sense, except in the case of hugetlb_cgroup where it's not possible to
> charge partial hugepages.
> 
> Round the hugetlb_cgroup limit down to hugepage size.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

May this be merged into -mm?

> ---
>  mm/hugetlb_cgroup.c | 35 ++++++++++++++++++++++++++---------
>  1 file changed, 26 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -67,26 +67,42 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
>  	return false;
>  }
>  
> +static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
> +				struct hugetlb_cgroup *parent_h_cgroup)
> +{
> +	int idx;
> +
> +	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
> +		struct page_counter *counter = &h_cgroup->hugepage[idx];
> +		struct page_counter *parent = NULL;
> +		unsigned long limit;
> +		int ret;
> +
> +		if (parent_h_cgroup)
> +			parent = &parent_h_cgroup->hugepage[idx];
> +		page_counter_init(counter, parent);
> +
> +		limit = round_down(PAGE_COUNTER_MAX,
> +				   1 << huge_page_order(&hstates[idx]));
> +		ret = page_counter_limit(counter, limit);
> +		VM_BUG_ON(ret);
> +	}
> +}
> +
>  static struct cgroup_subsys_state *
>  hugetlb_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  {
>  	struct hugetlb_cgroup *parent_h_cgroup = hugetlb_cgroup_from_css(parent_css);
>  	struct hugetlb_cgroup *h_cgroup;
> -	int idx;
>  
>  	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
>  	if (!h_cgroup)
>  		return ERR_PTR(-ENOMEM);
>  
> -	if (parent_h_cgroup) {
> -		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> -			page_counter_init(&h_cgroup->hugepage[idx],
> -					  &parent_h_cgroup->hugepage[idx]);
> -	} else {
> +	if (!parent_h_cgroup)
>  		root_h_cgroup = h_cgroup;
> -		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> -			page_counter_init(&h_cgroup->hugepage[idx], NULL);
> -	}
> +
> +	hugetlb_cgroup_init(h_cgroup, parent_h_cgroup);
>  	return &h_cgroup->css;
>  }
>  
> @@ -285,6 +301,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  		return ret;
>  
>  	idx = MEMFILE_IDX(of_cft(of)->private);
> +	nr_pages = round_down(nr_pages, 1 << huge_page_order(&hstates[idx]));
>  
>  	switch (MEMFILE_ATTR(of_cft(of)->private)) {
>  	case RES_LIMIT:
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
