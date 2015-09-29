Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 329996B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 19:07:30 -0400 (EDT)
Received: by qgev79 with SMTP id v79so20579783qge.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 16:07:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v45si23604276qgd.56.2015.09.29.16.07.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 16:07:29 -0700 (PDT)
Date: Tue, 29 Sep 2015 16:07:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: fix declarations of nr, delta and
 nr_pagecache_reclaimable
Message-Id: <20150929160727.ef70acf2e44575e9470a4025@linux-foundation.org>
In-Reply-To: <20150927210425.GA20155@gmail.com>
References: <20150927210425.GA20155@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: vdavydov@parallels.com, mhocko@suse.cz, hannes@cmpxchg.org, tj@kernel.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 27 Sep 2015 21:04:25 +0000 Alexandru Moise <00moses.alexander00@gmail.com> wrote:

> The nr variable is meant to be returned by a function which is
> declared as returning "unsigned long", so declare nr as such.
> 
> Lower down we should also declare delta and nr_pagecache_reclaimable
> as being unsigned longs because they're used to store the values
> returned by zone_page_state() and zone_unmapped_file_pages() which
> also happen to return unsigned integers.

I rewrote the changelog rather a lot:



Subject: mm/vmscan.c: fix types of some locals

In zone_reclaimable_pages(), `nr' is returned by a function which is
declared as returning "unsigned long", so declare it such.  Negative
values are meaningless here.

In zone_pagecache_reclaimable() we should also declare `delta' and
`nr_pagecache_reclaimable' as being unsigned longs because they're used to
store the values returned by zone_page_state() and
zone_unmapped_file_pages() which also happen to return unsigned integers.



> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -194,7 +194,7 @@ static bool sane_reclaim(struct scan_control *sc)
>  
>  static unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
> -	int nr;
> +	unsigned long nr;
>  
>  	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
>  	     zone_page_state(zone, NR_INACTIVE_FILE);

OK.

> @@ -3698,8 +3698,8 @@ static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
>  /* Work out how many page cache pages we can reclaim in this reclaim_mode */
>  static long zone_pagecache_reclaimable(struct zone *zone)
>  {
> -	long nr_pagecache_reclaimable;
> -	long delta = 0;
> +	unsigned long nr_pagecache_reclaimable;
> +	unsigned long delta = 0;
>  
>  	/*
>  	 * If RECLAIM_UNMAP is set, then all file pages are considered

Also OK, because zone_pagecache_reclaimable() takes care to avoid
returning any negative values.


In fact I believe we should also do this:

--- a/mm/vmscan.c~mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable-fix
+++ a/mm/vmscan.c
@@ -3693,7 +3693,7 @@ static inline unsigned long zone_unmappe
 }
 
 /* Work out how many page cache pages we can reclaim in this reclaim_mode */
-static long zone_pagecache_reclaimable(struct zone *zone)
+static unsigned long zone_pagecache_reclaimable(struct zone *zone)
 {
 	unsigned long nr_pagecache_reclaimable;
 	unsigned long delta = 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
