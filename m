Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA26B83096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:07:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u81so14404940wmu.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 05:07:31 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id xv2si11257458wjc.175.2016.08.30.05.07.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 05:07:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D6AE398D53
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:07:29 +0000 (UTC)
Date: Tue, 30 Aug 2016 13:07:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Message-ID: <20160830120728.GV8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160829093844.GA2592@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

On Mon, Aug 29, 2016 at 03:08:44PM +0530, Srikar Dronamraju wrote:
> > Patch "mm: vmscan: Begin reclaiming pages on a per-node basis" started
> > thinking of reclaim in terms of nodes but kswapd is still zone-centric. This
> > patch gets rid of many of the node-based versus zone-based decisions.
> > 
> > o A node is considered balanced when any eligible lower zone is balanced.
> >   This eliminates one class of age-inversion problem because we avoid
> >   reclaiming a newer page just because it's in the wrong zone
> > o pgdat_balanced disappears because we now only care about one zone being
> >   balanced.
> > o Some anomalies related to writeback and congestion tracking being based on
> >   zones disappear.
> > o kswapd no longer has to take care to reclaim zones in the reverse order
> >   that the page allocator uses.
> > o Most importantly of all, reclaim from node 0 with multiple zones will
> >   have similar aging and reclaiming characteristics as every
> >   other node.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> This patch seems to hurt FA_DUMP functionality. This behaviour is not
> seen on v4.7 but only after this patch.
> 
> So when a kernel on a multinode machine with memblock_reserve() such
> that most of the nodes have zero available memory, kswapd seems to be
> consuming 100% of the time.
> 

Why is FA_DUMP specifically the trigger? If the nodes have zero available
memory then is the zone_populated() check failing when FA_DUMP is enabled? If
so, that would both allow kswapd to wake and stay awake.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
