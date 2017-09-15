Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B59E06B0069
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:50:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m127so2918579wmm.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:50:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si1097437edj.541.2017.09.15.04.50.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 04:50:52 -0700 (PDT)
Date: Fri, 15 Sep 2017 13:50:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: Handle numa statistics distinctively based-on
 different VM stats modes
Message-ID: <20170915115049.vqthfawg3y4r6ogh@dhcp22.suse.cz>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505467406-9945-3-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 15-09-17 17:23:25, Kemi Wang wrote:
[...]
> @@ -2743,6 +2745,17 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  #ifdef CONFIG_NUMA
>  	enum numa_stat_item local_stat = NUMA_LOCAL;
>  
> +	/*
> +	 * skip zone_statistics() if vmstat is a coarse mode or zone statistics
> +	 * is inactive in auto vmstat mode
> +	 */
> +
> +	if (vmstat_mode) {
> +		if (vmstat_mode == VMSTAT_COARSE_MODE)
> +			return;
> +	} else if (disable_zone_statistics)
> +		return;
> +
>  	if (z->node != numa_node_id())
>  		local_stat = NUMA_OTHER;

A jump label could make this completely out of the way for the case
where every single cycle matters.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
