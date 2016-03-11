Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 412AC828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:55:18 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so7045419wmp.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:55:18 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id b71si1271464wmd.66.2016.03.10.23.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 23:55:17 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id l68so7151893wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:55:17 -0800 (PST)
Date: Fri, 11 Mar 2016 08:55:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311075514.GB27701@dhcp22.suse.cz>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 10-03-16 15:50:13, Johannes Weiner wrote:
> When setting memory.high below usage, nothing happens until the next
> charge comes along, and then it will only reclaim its own charge and
> not the now potentially huge excess of the new memory.high. This can
> cause groups to stay in excess of their memory.high indefinitely.
> 
> To fix that, when shrinking memory.high, kick off a reclaim cycle that
> goes after the delta.

This has been the case since the knob was introduce but I wouldn't
bother with the CC: stable # 4.0+ as this was still in experimental
mode. I guess we want to have it in 4.5 or put it to 4.5 stable.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8615b066b642..f7c9b4cbdf01 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4992,6 +4992,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
>  				 char *buf, size_t nbytes, loff_t off)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	unsigned long nr_pages;
>  	unsigned long high;
>  	int err;
>  
> @@ -5002,6 +5003,11 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
>  
>  	memcg->high = high;
>  
> +	nr_pages = page_counter_read(&memcg->memory);
> +	if (nr_pages > high)
> +		try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
> +					     GFP_KERNEL, true);
> +
>  	memcg_wb_domain_size_changed(memcg);
>  	return nbytes;
>  }
> -- 
> 2.7.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
