Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBBDE828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:03:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so28663773wma.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:03:14 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 202si1759125wmt.105.2016.06.23.09.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 09:03:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 421811C1F5F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 17:03:13 +0100 (IST)
Date: Thu, 23 Jun 2016 17:03:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 19/27] mm: Move vmscan writes and file write accounting
 to the node
Message-ID: <20160623160311.GA1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-20-git-send-email-mgorman@techsingularity.net>
 <20160622144039.GG7527@dhcp22.suse.cz>
 <20160623135758.GY1868@techsingularity.net>
 <9a439cbd-6bdc-3c7b-0327-df3b60cdeff8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9a439cbd-6bdc-3c7b-0327-df3b60cdeff8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 23, 2016 at 04:06:09PM +0200, Vlastimil Babka wrote:
> On 06/23/2016 03:57 PM, Mel Gorman wrote:
> >On Wed, Jun 22, 2016 at 04:40:39PM +0200, Michal Hocko wrote:
> >>On Tue 21-06-16 15:15:58, Mel Gorman wrote:
> >>>As reclaim is now node-based, it follows that page write activity
> >>>due to page reclaim should also be accounted for on the node. For
> >>>consistency, also account page writes and page dirtying on a per-node
> >>>basis.
> >>>
> >>>After this patch, there are a few remaining zone counters that may
> >>>appear strange but are fine. NUMA stats are still per-zone as this is a
> >>>user-space interface that tools consume. NR_MLOCK, NR_SLAB_*, NR_PAGETABLE,
> >>>NR_KERNEL_STACK and NR_BOUNCE are all allocations that potentially pin
> >>>low memory and cannot trivially be reclaimed on demand. This information
> >>>is still useful for debugging a page allocation failure warning.
> >>
> >>As I've said in other patch. I think we will need to provide
> >>/proc/nodeinfo to fill the gap.
> >>
> >
> >I added a patch on top that prints the node stats in zoneinfo but only
> >once for the first populated zone in a node. Doing this or creating a
> >new file are both potentially surprising but extending zoneinfo means
> >there is a greater chance that a user will spot the change.
> 
> BTW, there should already be /sys/devices/system/node/nodeX/vmstat providing
> the per-node stats, right?
> 
> Changing zoneinfo so that some zones have some stats that others don't seems
> to me like it can break some scripts...
> 

I suspect a lot of scripts that read zoneinfo just blindly record it.
Similarly, there is no guarantee that a smart script knows to look in
the per-node vmstat files either. This is a question of "wait see what
breaks".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
