Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05FB96B0010
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:30:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x7-v6so12278773wrn.13
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:30:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11-v6si959474edr.278.2018.05.04.07.30.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 07:30:12 -0700 (PDT)
Date: Fri, 4 May 2018 16:30:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm, vmpressure: Convert to use match_string() helper
Message-ID: <20180504143011.GW4535@dhcp22.suse.cz>
References: <20180503203206.44046-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503203206.44046-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu 03-05-18 23:32:06, Andy Shevchenko wrote:
> The new helper returns index of the matching string in an array.
> We are going to use it here.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmpressure.c | 32 ++++++--------------------------
>  1 file changed, 6 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 7142207224d3..4854584ec436 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -342,26 +342,6 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
>  	vmpressure(gfp, memcg, true, vmpressure_win, 0);
>  }
>  
> -static enum vmpressure_levels str_to_level(const char *arg)
> -{
> -	enum vmpressure_levels level;
> -
> -	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++)
> -		if (!strcmp(vmpressure_str_levels[level], arg))
> -			return level;
> -	return -1;
> -}
> -
> -static enum vmpressure_modes str_to_mode(const char *arg)
> -{
> -	enum vmpressure_modes mode;
> -
> -	for (mode = 0; mode < VMPRESSURE_NUM_MODES; mode++)
> -		if (!strcmp(vmpressure_str_modes[mode], arg))
> -			return mode;
> -	return -1;
> -}
> -
>  #define MAX_VMPRESSURE_ARGS_LEN	(strlen("critical") + strlen("hierarchy") + 2)
>  
>  /**
> @@ -398,18 +378,18 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
>  
>  	/* Find required level */
>  	token = strsep(&spec, ",");
> -	level = str_to_level(token);
> -	if (level == -1) {
> -		ret = -EINVAL;
> +	level = match_string(vmpressure_str_levels, VMPRESSURE_NUM_LEVELS, token);
> +	if (level < 0) {
> +		ret = level;
>  		goto out;
>  	}
>  
>  	/* Find optional mode */
>  	token = strsep(&spec, ",");
>  	if (token) {
> -		mode = str_to_mode(token);
> -		if (mode == -1) {
> -			ret = -EINVAL;
> +		mode = match_string(vmpressure_str_modes, VMPRESSURE_NUM_MODES, token);
> +		if (mode < 0) {
> +			ret = mode;
>  			goto out;
>  		}
>  	}
> -- 
> 2.17.0

-- 
Michal Hocko
SUSE Labs
