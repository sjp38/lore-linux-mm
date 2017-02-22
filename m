Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52D1F6B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 12:11:36 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q39so3409123wrb.3
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:11:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m19si2842002wmg.107.2017.02.22.09.11.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 09:11:34 -0800 (PST)
Date: Wed, 22 Feb 2017 18:11:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/cgroup: delay soft limit data allocation
Message-ID: <20170222171132.GB26472@dhcp22.suse.cz>
References: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-02-17 16:58:11, Laurent Dufour wrote:
[...]
>  static struct mem_cgroup_tree_per_node *
>  soft_limit_tree_node(int nid)
>  {
> @@ -465,6 +497,8 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>  	struct mem_cgroup_tree_per_node *mctz;
>  
>  	mctz = soft_limit_tree_from_page(page);
> +	if (!mctz)
> +		return;
>  	/*
>  	 * Necessary to update all ancestors when hierarchy is used.
>  	 * because their event counter is not touched.
> @@ -502,7 +536,8 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>  	for_each_node(nid) {
>  		mz = mem_cgroup_nodeinfo(memcg, nid);
>  		mctz = soft_limit_tree_node(nid);
> -		mem_cgroup_remove_exceeded(mz, mctz);
> +		if (mctz)
> +			mem_cgroup_remove_exceeded(mz, mctz);
>  	}
>  }
>  

this belongs to the previous patch, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
