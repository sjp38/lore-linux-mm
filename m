Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA7016B025E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 09:47:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so30871647lfz.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:47:50 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id l135si14714384wmb.48.2016.06.10.06.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 06:47:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id A12081C2495
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 14:47:48 +0100 (IST)
Date: Fri, 10 Jun 2016 14:47:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 01/27] mm, vmstat: Add infrastructure for per-node vmstats
Message-ID: <20160610134746.GL2527@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
 <575AC13D.2010104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <575AC13D.2010104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 10, 2016 at 03:31:41PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> > References: bnc#969297 PM performance -- intel_pstate
> > Patch-mainline: No, expected 4.7 and queued in linux-mm
> > Patch-name: patches.suse/mm-vmstat-Add-infrastructure-for-per-node-vmstats.patch
> 
> Remove?
> 

Yes. Clearly I fat-fingers a cherry pick and used the wrong command that
added distro-specific metadata. Sorry.

> > VM statistic counters for reclaim decisions are zone-based. If the kernel
> > is to reclaim on a per-node basis then we need to track per-node statistics
> > but there is no infrastructure for that. The most notable change is that
> > the old node_page_state is renamed to sum_zone_node_page_state.  The new
> > node_page_state takes a pglist_data and uses per-node stats but none exist
> > yet. There is some renaming such as vm_stat to vm_zone_stat and the addition
> > of vm_node_stat and the renaming of mod_state to mod_zone_state. Otherwise,
> > this is mostly a mechanical patch with no functional change. There is a
> > lot of similarity between the node and zone helpers which is unfortunate
> > but there was no obvious way of reusing the code and maintaining type safety.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Mel Gorman <mgorman@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Some nitpicks below.
> 
> > @@ -237,12 +286,26 @@ static inline void __inc_zone_page_state(struct page *page,
> >  	__inc_zone_state(page_zone(page), item);
> >  }
> >  
> > +static inline void __inc_node_page_state(struct page *page,
> > +			enum node_stat_item item)
> > +{
> > +	__inc_node_state(page_zone(page)->zone_pgdat, item);
> 
> This page -> node translation looks needlessly ineffective. How about
> using NODE_DATA(page_to_nid(page)).
> 

Yes, I will. I won't answer the individual feedbacks. They all seem
reasonable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
