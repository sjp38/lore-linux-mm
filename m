Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC7486B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:39:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c5so4956113wmi.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:39:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a143si4280188wme.44.2017.03.17.11.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:39:42 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:39:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170317183928.GA12281@cmpxchg.org>
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed, Mar 15, 2017 at 07:36:48PM +0800, Yisheng Xie wrote:
> @@ -100,6 +100,9 @@ struct scan_control {
>  	/* Can cgroups be reclaimed below their normal consumption range? */
>  	unsigned int may_thrash:1;
>  
> +	/* Did we have any memcg protected by the low limit */
> +	unsigned int memcg_low_protection:1;

These are both bad names. How about the following pair?

	/*
	 * Cgroups are not reclaimed below their configured memory.low,
	 * unless we threaten to OOM. If any cgroups are skipped due to
	 * memory.low and nothing was reclaimed, go back for memory.low.
	 */
	unsigned int memcg_low_skipped:1
	unsigned int memcg_low_reclaim:1;

> @@ -2557,6 +2560,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			unsigned long scanned;
>  
>  			if (mem_cgroup_low(root, memcg)) {
> +				sc->memcg_low_protection = 1;
> +
>  				if (!sc->may_thrash)
>  					continue;

				if (!sc->memcg_low_reclaim) {
					sc->memcg_low_skipped = 1;
					continue;
				}

>  				mem_cgroup_events(memcg, MEMCG_LOW, 1);
> @@ -2808,7 +2813,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		return 1;
>  
>  	/* Untapped cgroup reserves?  Don't OOM, retry. */
> -	if (!sc->may_thrash) {
> +	if (sc->memcg_low_protection && !sc->may_thrash) {

	if (sc->memcg_low_skipped) {
		[...]
		sc->memcg_low_reclaim = 1;
		goto retry;
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
