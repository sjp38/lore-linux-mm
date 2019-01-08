Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF688E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:52:48 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so1678957edm.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:52:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 24si29696edu.308.2019.01.08.06.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:52:47 -0800 (PST)
Date: Tue, 8 Jan 2019 15:52:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: use struct_size() in kmalloc()
Message-ID: <20190108145245.GW31793@dhcp22.suse.cz>
References: <20190104183726.GA6374@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190104183726.GA6374@embeddedor>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Cc Andrew (original patch is here http://lkml.kernel.org/r/20190104183726.GA6374@embeddedor)

On Fri 04-01-19 12:37:26, Gustavo A. R. Silva wrote:
> One of the more common cases of allocation size calculations is finding
> the size of a structure that has a zero-sized array at the end, along
> with memory for some number of elements for that array. For example:
> 
> struct foo {
>     int stuff;
>     void *entry[];
> };
> 
> instance = kmalloc(sizeof(struct foo) + sizeof(void *) * count, GFP_KERNEL);
> 
> Instead of leaving these open-coded and prone to type mistakes, we can
> now use the new struct_size() helper:
> 
> instance = kmalloc(struct_size(instance, entry, count), GFP_KERNEL);

This looks indeed neater

> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks

> ---
>  mm/memcontrol.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af7f18b32389..ad256cf7da47 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3626,8 +3626,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	size = thresholds->primary ? thresholds->primary->size + 1 : 1;
>  
>  	/* Allocate memory for new array of thresholds */
> -	new = kmalloc(sizeof(*new) + size * sizeof(struct mem_cgroup_threshold),
> -			GFP_KERNEL);
> +	new = kmalloc(struct_size(new, entries, size), GFP_KERNEL);
>  	if (!new) {
>  		ret = -ENOMEM;
>  		goto unlock;
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs
