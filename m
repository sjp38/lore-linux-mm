Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A10AE6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 12:38:29 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c200so281292170wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 09:38:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h62si47057975wme.86.2016.02.24.09.38.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 09:38:28 -0800 (PST)
Date: Wed, 24 Feb 2016 18:38:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] vmstat: Optimize refresh_cpu_vmstat()
Message-ID: <20160224173825.GC4678@dhcp22.suse.cz>
References: <20160222181040.553533936@linux.com>
 <20160222181049.844884425@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222181049.844884425@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

On Mon 22-02-16 12:10:41, Christoph Lameter wrote:
> Create a new function zone_needs_update() that uses a memchr to check
> all diffs for being nonzero first.
> 
> If we use this function in refresh_cpu_vm_stat() then we can avoid the
> this_cpu_xchg() loop over all differentials. This becomes in particular
> important as the number of counters keeps on increasing.
> 
> This also avoids modifying the cachelines with the differentials
> unnecessarily.
> 
> Also add some likely()s to ensure that the icache requirements
> are low when we do not have any updates to process.

Do you have any numbers? Can you actually measure an interference of
refresh_cpu_vmstat?

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c	2016-02-22 11:54:02.179095030 -0600
> +++ linux/mm/vmstat.c	2016-02-22 11:54:24.338528277 -0600
> @@ -444,6 +444,18 @@ static int fold_diff(int *diff)
>  	return changes;
>  }
>  
> +bool zone_needs_update(struct per_cpu_pageset *p)

static bool ....

> +{
> +
> +	BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
> +	/*
> +	 * The fast way of checking if there are any vmstat diffs.
> +	 * This works because the diffs are byte sized items.
> +	 */
> +	return memchr_inv(p->vm_stat_diff, 0,
> +			NR_VM_ZONE_STAT_ITEMS) != NULL;
> +}
> +
>  /*
>   * Update the zone counters for the current cpu.
>   *
> @@ -470,18 +482,20 @@ static int refresh_cpu_vm_stats(bool do_
>  	for_each_populated_zone(zone) {
>  		struct per_cpu_pageset __percpu *p = zone->pageset;
>  
> -		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
> -			int v;
> +		if (unlikely(zone_needs_update(this_cpu_ptr(p)))) {

why unlikely? The generated code looks exactly same with or without it
(same for the other likely annotation added by this patch).

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
