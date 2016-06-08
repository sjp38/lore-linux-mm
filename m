Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E612A6B026C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:16:12 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so5695760lbb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:16:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id it8si2278121wjb.140.2016.06.08.09.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 09:16:11 -0700 (PDT)
Date: Wed, 8 Jun 2016 12:16:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160608161605.GF6727@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
 <20160608125137.GH22570@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608125137.GH22570@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Wed, Jun 08, 2016 at 02:51:37PM +0200, Michal Hocko wrote:
> On Mon 06-06-16 15:48:33, Johannes Weiner wrote:
> > Rename struct zone_reclaim_stat to struct lru_cost, and move from two
> > separate value ratios for the LRU lists to a relative LRU cost metric
> > with a shared denominator.
> 
> I just do not like the too generic `number'. I guess cost or price would
> fit better and look better in the code as well. Up you though...

Yeah, I picked it as a pair, numerator and denominator. But as Minchan
points out, denom is superfluous in the final version of the patch, so
I'm going to remove it and give the numerators better names.

anon_cost and file_cost?

> > Then make everything that affects the cost go through a new
> > lru_note_cost() function.
> 
> Just curious, have you tried to measure just the effect of this change
> without the rest of the series? I do not expect it would show large
> differences because we are not doing SCAN_FRACT most of the time...

Yes, we default to use-once cache and do fractional scanning when that
runs out and we have to go after workingset, which might potentially
cause refault IO. So you need a workload that has little streaming IO.

I haven't tested this patch in isolation, but it shouldn't make much
of a difference, since we continue to balance based on the same input.

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
