Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98BC56B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:33:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so6228543lfg.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 01:33:46 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id n3si3804715wjp.144.2016.07.12.01.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 01:33:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 795121C187B
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:33:44 +0100 (IST)
Date: Tue, 12 Jul 2016 09:33:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, vmscan: Give up balancing node for high order
 allocations earlier
Message-ID: <20160712083342.GC9806@techsingularity.net>
References: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com>
 <20160711152015.e3be8be7702fb0ca4625040d@linux-foundation.org>
 <013d01d1dc07$33896860$9a9c3920$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <013d01d1dc07$33896860$9a9c3920$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 12, 2016 at 02:32:45PM +0800, Hillf Danton wrote:
> > > To avoid excessive reclaim, we give up rebalancing for high order
> > > allocations right after reclaiming enough pages.
> > 
> > hm.  What are the observed runtime effects of this change?  Any testing
> > results?
> > 
> This work was based on Mel's work, Sir,
> "[PATCH 00/27] Move LRU page reclaim from zones to nodes v7".
> 

I believe Andrew understands that but the question is what is the
observed runtime effect of the patch?

> In "[PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes", 
> fragmentation detection is introduced to avoid excessive reclaim. We bail 
> out of balancing for high-order allocations if the pages reclaimed at the 
> __current__ reclaim priority are two times more than required.
> 
> In this work we give up reclaiming for high-order allocations if the 
> __total__ number of pages reclaimed, from the first priority to the 
> current priority, is more than needed, and in net result we reclaim less 
> pages.
> 

While it's clear what it does, it is not clear if it is an improvement. I had
read the patch, considered merging it and decided against it. This decision
was based on the fact the series did not appear to be over-reclaiming for
high-order pages when compared with zone-lru.

Did you test this patch with a workload that requires a lot of high-order
pages and see if kswapd was over-reclaiming and that this patch addressed
the issue?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
