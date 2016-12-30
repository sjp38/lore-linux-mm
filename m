Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDAEB6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 11:37:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so99236804wjc.2
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 08:37:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 186si59180980wmu.126.2016.12.30.08.37.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 08:37:46 -0800 (PST)
Date: Fri, 30 Dec 2016 17:37:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161230163742.GK13301@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230160456.GA7267@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Sat 31-12-16 01:04:56, Minchan Kim wrote:
[...]
> > From 5f1bc22ad1e54050b4da3228d68945e70342ebb6 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 27 Dec 2016 13:18:20 +0100
> > Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> > 
> > Our reclaim process has several tracepoints to tell us more about how
> > things are progressing. We are, however, missing a tracepoint to track
> > active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> 
> I agree this part.
> 
> > the number of
> > 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> > 	  effectiveness.
> 
> I agree nr_taken for knowing shrinking effectiveness but don't
> agree nr_scanned. If we want to know LRU isolation effectiveness
> with nr_scanned and nr_taken, isolate_lru_pages will do.

Yes it will. On the other hand the number is there and there is no
additional overhead, maintenance or otherwise, to provide that number.
The inactive counterpart does that for quite some time already. So why
exactly does that matter? Don't take me wrong but isn't this more on a
nit picking side than necessary? Or do I just misunderstand your
concenrs? It is not like we are providing a stable user API as the
tracepoint is clearly implementation specific and not something to be
used for anything other than debugging.

> > 	- nr_rotated pages which tells us that we are hitting referenced
> > 	  pages which are deactivated. If this is a large part of the
> > 	  reported nr_deactivated pages then the active list is too small
> 
> It might be but not exactly. If your goal is to know LRU size, it can be
> done in get_scan_count. I tend to agree LRU size is helpful for
> performance analysis because decreased LRU size signals memory shortage
> then performance drop.

No, I am not really interested in the exact size but rather to allow to
find whether we are aging the active list too early...

> 
> > 	- nr_activated pages which tells us how many pages are keept on the
>                                                                kept

fixed

> 
> > 	  active list - mostly exec pages. A high number can indicate
> 
>                                file-based exec pages

OK, fixed

> 
> > 	  that we might be trashing on executables.
> 
> And welcome to drop nr_unevictable, nr_freed.
> 
> I will be off until next week monday so please understand if my response
> is slow.

There is no reason to hurry...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
