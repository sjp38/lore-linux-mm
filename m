Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7D15A6B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 10:26:48 -0500 (EST)
Date: Wed, 28 Nov 2012 10:26:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121128152631.GT24381@cmpxchg.org>
References: <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
 <20121127205944.GB2433@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127205944.GB2433@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Tue, Nov 27, 2012 at 09:59:44PM +0100, Michal Hocko wrote:
> @@ -3863,7 +3862,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		return 0;
>  
>  	if (!PageSwapCache(page))
> -		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> +		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type, oom);
>  	else { /* page is swapcache/shmem */
>  		ret = __mem_cgroup_try_charge_swapin(mm, page,
>  						     gfp_mask, &memcg);

I think you need to pass it down the swapcache path too, as that is
what happens when the shmem page written to is in swap and has been
read into swapcache by the time of charging.

> @@ -1152,8 +1152,16 @@ repeat:
>  				goto failed;
>  		}
>  
> +		 /*
> +                  * Cannot trigger OOM even if gfp_mask would allow that
> +                  * normally because we might be called from a locked
> +                  * context (i_mutex held) if this is a write lock or
> +                  * fallocate and that could lead to deadlocks if the
> +                  * killed process is waiting for the same lock.
> +		  */

Indentation broken?

>  		error = mem_cgroup_cache_charge(page, current->mm,
> -						gfp & GFP_RECLAIM_MASK);
> +						gfp & GFP_RECLAIM_MASK,
> +						sgp < SGP_WRITE);

The code tests for read-only paths a bunch of times using

	sgp != SGP_WRITE && sgp != SGP_FALLOC

Would probably be more consistent and more robust to use this here as
well?

> @@ -1209,7 +1217,8 @@ repeat:
>  		SetPageSwapBacked(page);
>  		__set_page_locked(page);
>  		error = mem_cgroup_cache_charge(page, current->mm,
> -						gfp & GFP_RECLAIM_MASK);
> +						gfp & GFP_RECLAIM_MASK,
> +						sgp < SGP_WRITE);

Same.

Otherwise, the patch looks good to me, thanks for persisting :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
