Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 889D9828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:58:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so24595298wme.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:58:22 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id h204si1141165wmh.97.2016.06.23.06.58.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 06:58:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 21F16989FF
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 13:58:21 +0000 (UTC)
Date: Thu, 23 Jun 2016 14:57:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 19/27] mm: Move vmscan writes and file write accounting
 to the node
Message-ID: <20160623135758.GY1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-20-git-send-email-mgorman@techsingularity.net>
 <20160622144039.GG7527@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160622144039.GG7527@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 22, 2016 at 04:40:39PM +0200, Michal Hocko wrote:
> On Tue 21-06-16 15:15:58, Mel Gorman wrote:
> > As reclaim is now node-based, it follows that page write activity
> > due to page reclaim should also be accounted for on the node. For
> > consistency, also account page writes and page dirtying on a per-node
> > basis.
> > 
> > After this patch, there are a few remaining zone counters that may
> > appear strange but are fine. NUMA stats are still per-zone as this is a
> > user-space interface that tools consume. NR_MLOCK, NR_SLAB_*, NR_PAGETABLE,
> > NR_KERNEL_STACK and NR_BOUNCE are all allocations that potentially pin
> > low memory and cannot trivially be reclaimed on demand. This information
> > is still useful for debugging a page allocation failure warning.
> 
> As I've said in other patch. I think we will need to provide
> /proc/nodeinfo to fill the gap.
> 

I added a patch on top that prints the node stats in zoneinfo but only
once for the first populated zone in a node. Doing this or creating a
new file are both potentially surprising but extending zoneinfo means
there is a greater chance that a user will spot the change.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
