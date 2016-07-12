Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC6E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:06:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so17496811lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:06:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f197si17554079wmf.73.2016.07.12.12.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 12:06:19 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:06:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 32/34] mm: vmstat: account per-zone stalls and pages
 skipped during reclaim
Message-ID: <20160712190606.GB8629@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-33-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-33-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:08AM +0100, Mel Gorman wrote:
> The vmstat allocstall was fairly useful in the general sense but
> node-based LRUs change that.  It's important to know if a stall was for an
> address-limited allocation request as this will require skipping pages
> from other zones.  This patch adds pgstall_* counters to replace
> allocstall.  The sum of the counters will equal the old allocstall so it
> can be trivially recalculated.  A high number of address-limited
> allocation requests may result in a lot of useless LRU scanning for
> suitable pages.
> 
> As address-limited allocations require pages to be skipped, it's important
> to know how much useless LRU scanning took place so this patch adds
> pgskip* counters.  This yields the following model
> 
> 1. The number of address-space limited stalls can be accounted for (pgstall)
> 2. The amount of useless work required to reclaim the data is accounted (pgskip)
> 3. The total number of scans is available from pgscan_kswapd and pgscan_direct
>    so from that the ratio of useful to useless scans can be calculated.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

These statistics should be quite helpful, so:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

But I have one nitpick:

> @@ -23,6 +23,8 @@
>  
>  enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGALLOC),
> +		FOR_ALL_ZONES(PGSTALL),
> +		FOR_ALL_ZONES(PGSCAN_SKIP),
>  		PGFREE, PGACTIVATE, PGDEACTIVATE,
>  		PGFAULT, PGMAJFAULT,
>  		PGLAZYFREED,

The PG prefix seems to stand for page, and all stat names that contain
it represent some per-page event. PGSTALL is not a page event, though.
Would you mind sticking with allocstall? allocstall_dma32 etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
