Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35146828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 10:06:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so53884566lfe.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:06:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e20si6648155wmd.54.2016.06.23.07.06.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 07:06:11 -0700 (PDT)
Subject: Re: [PATCH 19/27] mm: Move vmscan writes and file write accounting to
 the node
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-20-git-send-email-mgorman@techsingularity.net>
 <20160622144039.GG7527@dhcp22.suse.cz>
 <20160623135758.GY1868@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9a439cbd-6bdc-3c7b-0327-df3b60cdeff8@suse.cz>
Date: Thu, 23 Jun 2016 16:06:09 +0200
MIME-Version: 1.0
In-Reply-To: <20160623135758.GY1868@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/23/2016 03:57 PM, Mel Gorman wrote:
> On Wed, Jun 22, 2016 at 04:40:39PM +0200, Michal Hocko wrote:
>> On Tue 21-06-16 15:15:58, Mel Gorman wrote:
>>> As reclaim is now node-based, it follows that page write activity
>>> due to page reclaim should also be accounted for on the node. For
>>> consistency, also account page writes and page dirtying on a per-node
>>> basis.
>>>
>>> After this patch, there are a few remaining zone counters that may
>>> appear strange but are fine. NUMA stats are still per-zone as this is a
>>> user-space interface that tools consume. NR_MLOCK, NR_SLAB_*, NR_PAGETABLE,
>>> NR_KERNEL_STACK and NR_BOUNCE are all allocations that potentially pin
>>> low memory and cannot trivially be reclaimed on demand. This information
>>> is still useful for debugging a page allocation failure warning.
>>
>> As I've said in other patch. I think we will need to provide
>> /proc/nodeinfo to fill the gap.
>>
>
> I added a patch on top that prints the node stats in zoneinfo but only
> once for the first populated zone in a node. Doing this or creating a
> new file are both potentially surprising but extending zoneinfo means
> there is a greater chance that a user will spot the change.

BTW, there should already be /sys/devices/system/node/nodeX/vmstat 
providing the per-node stats, right?

Changing zoneinfo so that some zones have some stats that others don't 
seems to me like it can break some scripts...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
