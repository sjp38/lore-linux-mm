Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B0DC66B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:09:45 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so22379279wiw.1
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 08:09:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i5si42444620wjf.162.2015.01.13.08.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 08:09:44 -0800 (PST)
Date: Tue, 13 Jan 2015 11:09:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150113160940.GD8180@phnom.home.cmpxchg.org>
References: <1421147247-10870-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421147247-10870-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org

On Tue, Jan 13, 2015 at 04:37:27PM +0530, Vinayak Menon wrote:
> @@ -1392,6 +1392,44 @@ int isolate_lru_page(struct page *page)
>  	return ret;
>  }
>  
> +static int __too_many_isolated(struct zone *zone, int file,
> +	struct scan_control *sc, int safe)
> +{
> +	unsigned long inactive, isolated;
> +
> +	if (file) {
> +		if (safe) {
> +			inactive = zone_page_state_snapshot(zone,
> +					NR_INACTIVE_FILE);
> +			isolated = zone_page_state_snapshot(zone,
> +					NR_ISOLATED_FILE);
> +		} else {
> +			inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> +			isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> +		}
> +	} else {
> +		if (safe) {
> +			inactive = zone_page_state_snapshot(zone,
> +					NR_INACTIVE_ANON);
> +			isolated = zone_page_state_snapshot(zone,
> +					NR_ISOLATED_ANON);
> +		} else {
> +			inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> +			isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> +		}
> +	}

	if (safe) {
		inactive = zone_page_state_snapshot(zone, NR_INACTIVE_ANON + 2*file)
		isolated = zone_page_state_snapshot(zone, NR_ISOLATED_ANON + file)
	} else {
		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2*file)
		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file)
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
