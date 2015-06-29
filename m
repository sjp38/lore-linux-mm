Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA2F6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:03:14 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so6134306wid.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:03:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si13547990wie.78.2015.06.29.08.03.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 08:03:12 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:03:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
Message-ID: <20150629150311.GC4612@dhcp22.suse.cz>
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435587233-27976-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-06-15 10:13:53, Nicholas Krause wrote:
[...]
> -static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
> +static bool alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  {
>  	struct mem_cgroup_per_node *pn;
>  	struct mem_cgroup_per_zone *mz;
> @@ -4442,7 +4442,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  		tmp = -1;
>  	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
>  	if (!pn)
> -		return 1;
> +		return true;

Have you tried to think about the semantic of the function? The function
has returned 0 to signal the success which is pretty common. It could have
returned -ENOMEM for the allocation failure which would be much more
nicer than 1.

After your change we have bool semantic where the success is reported by
false while failure is true. Doest this make any sense to you? Because
it doesn't make to me and it only shows that this is a mechanical
conversion without deeper thinking about consequences.

Nacked-by: Michal Hocko <mhocko@suse.cz>

Btw. I can see your other patches which trying to do similar. I would
strongly discourage you from this path. Try to understand the code and
focus on changes which would actually make any improvements to the code
base. Doing stylist changes which do not help readability and neither
help compiler to generate a better code is simply waste of your and
reviewers time.

>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  		mz = &pn->zoneinfo[zone];
> @@ -4452,7 +4452,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  		mz->memcg = memcg;
>  	}
>  	memcg->nodeinfo[node] = pn;
> -	return 0;
> +	return false;
>  }
>  
>  static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
