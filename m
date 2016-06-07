Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D60226B025E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 10:11:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k184so34329858wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 07:11:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kt6si33605201wjb.75.2016.06.07.07.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 07:11:28 -0700 (PDT)
Date: Tue, 7 Jun 2016 10:11:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/10] mm: remove unnecessary use-once cache bias from
 LRU balancing
Message-ID: <20160607141124.GC9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-7-hannes@cmpxchg.org>
 <1465266031.16365.153.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465266031.16365.153.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 10:20:31PM -0400, Rik van Riel wrote:
> On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > When the splitlru patches divided page cache and swap-backed pages
> > into separate LRU lists, the pressure balance between the lists was
> > biased to account for the fact that streaming IO can cause memory
> > pressure with a flood of pages that are used only once. New page
> > cache
> > additions would tip the balance toward the file LRU, and repeat
> > access
> > would neutralize that bias again. This ensured that page reclaim
> > would
> > always go for used-once cache first.
> > 
> > Since e9868505987a ("mm,vmscan: only evict file pages when we have
> > plenty"), page reclaim generally skips over swap-backed memory
> > entirely as long as there is used-once cache present, and will apply
> > the LRU balancing when only repeatedly accessed cache pages are left
> > -
> > at which point the previous use-once bias will have been neutralized.
> > 
> > This makes the use-once cache balancing bias unnecessary. Remove it.
> > 
> 
> The code in get_scan_count() still seems to use the statistics
> of which you just removed the updating.
> 
> What am I overlooking?

As I mentioned in 5/10, page reclaim still does updates for each
scanned page and rotated page at this point in the series.

This merely removes the pre-reclaim bias for cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
