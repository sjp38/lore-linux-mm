Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA74bFxO015112
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Nov 2008 13:37:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA3D545DE3E
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 13:37:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D36445DE51
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 13:37:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BDEA1DB8040
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 13:37:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B9541E08003
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 13:37:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
In-Reply-To: <20081106164644.GA14012@csn.ul.ie>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081106164644.GA14012@csn.ul.ie>
Message-Id: <20081107093127.F84A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  7 Nov 2008 13:37:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Mel, Cristoph,

Thank you for interesting comment!


> > MIGRATE_RESERVE mean that the page is for emergency.
> > So it shouldn't be cached in pcp.
> 
> It doesn't necessarily mean it's for emergencys. MIGRATE_RESERVE is one
> or more pageblocks at the beginning of the zone. While it's possible
> that the minimum page reserve for GFP_ATOMIC is located here, it's not
> mandatory.
> 
> What MIGRATE_RESERVE can help is high-order atomic allocations used by
> some network drivers (a wireless one is what led to MIGRATE_RESERVE). As
> they are high-order allocations, they would be returned to the buddy
> allocator anyway.

yup.
my patch is meaningless for high order allocation because high order allocation
don't use pcp.


> What your patch may help is the situation where the system is under intense
> memory pressure, is dipping routinely into the lowmem reserves and mixing
> with high-order atomic allocations. This seems a bit extreme.

not so extreame.

The linux page reclaim can't process in interrupt context.
Sl network subsystem and driver often use MIGRATE_RESERVE memory although
system have many reclaimable memory.

At that time, any task in process context can use high order allocation.


> > otherwise, the system have unnecessary memory starvation risk
> > because other cpu can't use this emergency pages.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Mel Gorman <mel@csn.ul.ie>
> > CC: Christoph Lameter <cl@linux-foundation.org>
> > 
> 
> This patch seems functionally sound but as Christoph points out, this
> adds another branch to the fast path. Now, I ran some tests and those that
> completed didn't show any problems but adding branches in the fast path can
> eventually lead to hard-to-detect performance problems.
> 
> Do you have a situation in mind that this patch fixes up?

Ah, sorry for my description is too poor.
This isn't real workload issue, it is jsut 

Actually, I plan to rework to pcp because following pcp list searching 
in fast path is NOT fast.

In general, list searching often cause L1 cache miss, therefore it shouldn't be
used in fast path.


static struct page *buffered_rmqueue(struct zone *preferred_zone,
                        struct zone *zone, int order, gfp_t gfp_flags)
{
(snip)
                /* Find a page of the appropriate migrate type */
                if (cold) {
                        list_for_each_entry_reverse(page, &pcp->list, lru)
                                if (page_private(page) == migratetype)
                                        break;
                } else {
                        list_for_each_entry(page, &pcp->list, lru)
                                if (page_private(page) == migratetype)
                                        break;
                }


Therefore, I'd like to make per migratetype pcp list.
However, MIGRATETYPE_RESEVE list isn't useful because caller never need reserve type.
it is only internal attribute.

So I thought "dropping reserve type page in pcp" patch is useful although it is sololy used.
Then, I posted it sololy for hear other developer opinion.

Actually, current pcp is NOT fast, therefore the discussion of the 
number of branches isn't meaningful.
the discussion of the number of branches is only meaningful when the fast path can
process at N*branches level time, but current pcp is more slow.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
