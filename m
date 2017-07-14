Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4B5440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:36:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b11so8389378wmh.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:36:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si1823549wmc.171.2017.07.14.02.36.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 02:36:53 -0700 (PDT)
Date: Fri, 14 Jul 2017 10:36:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170714093650.l67vbem2g4typkta@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714080006.7250-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-api@vger.kernel.org

On Fri, Jul 14, 2017 at 09:59:58AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Supporting zone ordered zonelists costs us just a lot of code while
> the usefulness is arguable if existent at all. Mel has already made
> node ordering default on 64b systems. 32b systems are still using
> ZONELIST_ORDER_ZONE because it is considered better to fallback to
> a different NUMA node rather than consume precious lowmem zones.
> 
> This argument is, however, weaken by the fact that the memory reclaim
> has been reworked to be node rather than zone oriented. This means
> that lowmem requests have to skip over all highmem pages on LRUs already
> and so zone ordering doesn't save the reclaim time much. So the only
> advantage of the zone ordering is under a light memory pressure when
> highmem requests do not ever hit into lowmem zones and the lowmem
> pressure doesn't need to reclaim.
> 
> Considering that 32b NUMA systems are rather suboptimal already and
> it is generally advisable to use 64b kernel on such a HW I believe we
> should rather care about the code maintainability and just get rid of
> ZONELIST_ORDER_ZONE altogether. Keep systcl in place and warn if
> somebody tries to set zone ordering either from kernel command line
> or the sysctl.
> 
> Cc: <linux-api@vger.kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> index 80e4adb4c360..d9f4ea057e74 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4864,40 +4824,22 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
>  		void __user *buffer, size_t *length,
>  		loff_t *ppos)
>  {
> -	char saved_string[NUMA_ZONELIST_ORDER_LEN];
> +	char *str;
>  	int ret;
> -	static DEFINE_MUTEX(zl_order_mutex);
>  
> -	mutex_lock(&zl_order_mutex);
> -	if (write) {
> -		if (strlen((char *)table->data) >= NUMA_ZONELIST_ORDER_LEN) {
> -			ret = -EINVAL;
> -			goto out;
> -		}
> -		strcpy(saved_string, (char *)table->data);
> +	if (!write) {
> +		int len = sizeof("Default");
> +		if (copy_to_user(buffer, "Default", len))
> +			return -EFAULT;
> +		return len;
>  	}

That should to be "default" because the original code would have the proc
entry display "default" unless it was set at runtime. Pretty weird I
know but it's always possible someone is parsing the original default
and not handling it properly.

Otherwise I think we're way past the point where large memory 32-bit
NUMA machines are a thing so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
