Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A00D6B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 23:20:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 82E003EE0BB
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:20:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6989745DE66
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:20:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 516D045DE62
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:20:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 433141DB803B
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:20:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D4851DB8037
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:20:30 +0900 (JST)
Message-ID: <4E1E6086.4060902@jp.fujitsu.com>
Date: Thu, 14 Jul 2011 12:20:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation
 after direct reclaim
References: <1310389274-13995-1-git-send-email-mgorman@suse.de> <1310389274-13995-4-git-send-email-mgorman@suse.de> <4E1CE9FF.3050707@jp.fujitsu.com> <20110713111017.GG7529@suse.de>
In-Reply-To: <20110713111017.GG7529@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/07/13 20:10), Mel Gorman wrote:
> On Wed, Jul 13, 2011 at 09:42:39AM +0900, KOSAKI Motohiro wrote:
>> (2011/07/11 22:01), Mel Gorman wrote:
>>> With zone_reclaim_mode enabled, it's possible for zones to be considered
>>> full in the zonelist_cache so they are skipped in the future. If the
>>> process enters direct reclaim, the ZLC may still consider zones to be
>>> full even after reclaiming pages. Reconsider all zones for allocation
>>> if direct reclaim returns successfully.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>
>> Hmmm...
>>
>> I like the concept, but I'm worry about a corner case a bit.
>>
>> If users are using cpusets/mempolicy, direct reclaim don't scan all zones.
>> Then, zlc_clear_zones_full() seems too aggressive operation.
> 
> As the system is likely to be running slow if it is in direct reclaim
> that the complexity of being careful about which zone was cleared was
> not worth it.
> 
>> Instead, couldn't we turn zlc->fullzones off from kswapd?
>>
> 
> Which zonelist should it clear (there are two) and when should it
> happen? If it clears it on each cycle around balance_pgdat(), there
> is no guarantee that it'll be cleared between when direct reclaim
> finishes and an attempt is made to allocate.

Hmm..

Probably I'm now missing the point of this patch. Why do we need
to guarantee tightly coupled zlc cache and direct reclaim? IIUC,
zlc cache mean "to avoid free list touch if they have no free mem".
So, any free page increasing point is acceptable good, I thought.
In the other hand, direct reclaim finishing has no guarantee to
zones of zonelist have enough free memory because it has bailing out logic.

So, I think we don't need to care zonelist, just kswapd turn off
their own node.

And, just curious, If we will have a proper zlc clear point, why
do we need to keep HZ timeout?









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
