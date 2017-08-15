Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A28F6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:30:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e204so2991798wma.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:30:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n186si1870221wmn.214.2017.08.15.15.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:30:13 -0700 (PDT)
Date: Tue, 15 Aug 2017 15:30:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Reward slab shrinkers that reclaim more than they
 were asked
Message-Id: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
In-Reply-To: <20170812113437.7397-1-chris@chris-wilson.co.uk>
References: <20170812113437.7397-1-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

On Sat, 12 Aug 2017 12:34:37 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> Some shrinkers may only be able to free a bunch of objects at a time, and
> so free more than the requested nr_to_scan in one pass. Account for the
> extra freed objects against the total number of objects we intend to
> free, otherwise we may end up penalising the slab far more than intended.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -398,6 +398,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  			break;
>  		freed += ret;
>  
> +		nr_to_scan = max(nr_to_scan, ret);
>  		count_vm_events(SLABS_SCANNED, nr_to_scan);
>  		total_scan -= nr_to_scan;
>  		scanned += nr_to_scan;

Well...  kinda.  But what happens if the shrinker scanned more objects
than requested but failed to free many of them?  Of if the shrinker
scanned less than requested?

We really want to return nr_scanned from the shrinker invocation. 
Could we add a field to shrink_control for this?

--- a/mm/vmscan.c~a
+++ a/mm/vmscan.c
@@ -393,14 +393,15 @@ static unsigned long do_shrink_slab(stru
 		unsigned long nr_to_scan = min(batch_size, total_scan);
 
 		shrinkctl->nr_to_scan = nr_to_scan;
+		shrinkctl->nr_scanned = nr_to_scan;
 		ret = shrinker->scan_objects(shrinker, shrinkctl);
 		if (ret == SHRINK_STOP)
 			break;
 		freed += ret;
 
-		count_vm_events(SLABS_SCANNED, nr_to_scan);
-		total_scan -= nr_to_scan;
-		scanned += nr_to_scan;
+		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
+		total_scan -= shrinkctl->nr_scanned;
+		scanned += shrinkctl->nr_scanned;
 
 		cond_resched();
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
