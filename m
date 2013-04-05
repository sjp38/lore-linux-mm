Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 146706B0036
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 21:09:58 -0400 (EDT)
Received: by mail-oa0-f74.google.com with SMTP id k14so795850oag.5
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 18:09:57 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 06/28] mm: new shrinker API
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-7-git-send-email-glommer@parallels.com>
Date: Thu, 04 Apr 2013 18:09:55 -0700
Message-ID: <xr93k3ohkckc.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

On Fri, Mar 29 2013, Glauber Costa wrote:

> From: Dave Chinner <dchinner@redhat.com>
>
> The current shrinker callout API uses an a single shrinker call for
> multiple functions. To determine the function, a special magical
> value is passed in a parameter to change the behaviour. This
> complicates the implementation and return value specification for
> the different behaviours.
>
> Separate the two different behaviours into separate operations, one
> to return a count of freeable objects in the cache, and another to
> scan a certain number of objects in the cache for freeing. In
> defining these new operations, ensure the return values and
> resultant behaviours are clearly defined and documented.
>
> Modify shrink_slab() to use the new API and implement the callouts
> for all the existing shrinkers.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  include/linux/shrinker.h | 37 +++++++++++++++++++++++++----------
>  mm/vmscan.c              | 51 +++++++++++++++++++++++++++++++-----------------
>  2 files changed, 60 insertions(+), 28 deletions(-)
>
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index ac6b8ee..4f59615 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -4,31 +4,47 @@
>  /*
>   * This struct is used to pass information from page reclaim to the shrinkers.
>   * We consolidate the values for easier extention later.
> + *
> + * The 'gfpmask' refers to the allocation we are currently trying to
> + * fulfil.
> + *
> + * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
> + * querying the cache size, so a fastpath for that case is appropriate.
>   */
>  struct shrink_control {
>  	gfp_t gfp_mask;
>  
>  	/* How many slab objects shrinker() should scan and try to reclaim */
> -	unsigned long nr_to_scan;
> +	long nr_to_scan;

Why convert from unsigned?  What's a poor shrinker to do with a negative
to-scan request?

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
