Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A92AC6B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:37:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n6so115414220qtn.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 05:37:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a62si15108957wmc.78.2016.08.15.05.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 05:37:51 -0700 (PDT)
Date: Mon, 15 Aug 2016 08:34:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815123407.GA1153@cmpxchg.org>
References: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
 <1470995779-10064-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470995779-10064-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

Hi Michal, thanks for doing this. There is only one issue I can see:

On Fri, Aug 12, 2016 at 11:56:17AM +0200, Michal Hocko wrote:
> @@ -4171,17 +4211,27 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	if (!memcg)
>  		return NULL;
>  
> +	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
> +				 1, MEM_CGROUP_ID_MAX,
> +				 GFP_KERNEL);
> +	if (memcg->id.id < 0)
> +		goto out_free;
> +
>  	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!memcg->stat)
> -		goto out_free;
> +		goto out_idr;
>  
>  	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
>  		goto out_free_stat;
>  
> +	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);

This publishes the memcg object too early. Before 4.5, the memcg is
not fully initialized in mem_cgroup_alloc(). You have to move the
idr_replace() down to that function (and idr_remove() on free_out).

>  	return memcg;
>  
>  out_free_stat:
>  	free_percpu(memcg->stat);
> +out_idr:
> +	if (memcg->id.id > 0)
> +		idr_remove(&mem_cgroup_idr, memcg->id.id);

The > 0 check seems unnecessary, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
