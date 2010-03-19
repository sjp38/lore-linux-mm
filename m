Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B31F6B0089
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:21:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6Lsg7031271
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:21:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C911D45DE7A
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A13FC45DE60
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88618E18003
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 38F071DB8037
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/11] Memory compaction core
In-Reply-To: <20100318114302.GM12388@csn.ul.ie>
References: <20100318085741.8729.A69D9226@jp.fujitsu.com> <20100318114302.GM12388@csn.ul.ie>
Message-Id: <20100319152102.876C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Mar 2010 15:21:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > V1 did compaction per pageblock. but current patch doesn't.
> > > > so, Is COMPACTBLOCKS still good name?
> > > 
> > > It's not such a minor nit. I wondered about that myself but it's still a
> > > block - just not a pageblock. Would COMPACTCLUSTER be a better name as it's
> > > related to COMPACT_CLUSTER_MAX?
> > 
> > I've looked at this code again. honestly I'm a abit confusing even though both your
> > suggestions seems reasonable.  
> > 
> > now COMPACTBLOCKS is tracking #-of-called-migrate_pages. but I can't imazine
> > how to use it. can you please explain this ststics purpose? probably this is only useful
> > when conbination other stats, and the name should be consist with such combination one.
> > 
> 
> It is intended to count how many steps compaction took, the fewer the
> better so minimally, the lower this number is the better. Specifically, the
> "goodness" is related to the number of pages that were successfully allocated
> due to compaction. Assuming the only high-order allocation was huge pages,
> one possible calculation for "goodness" is;
> 
> hugepage_clusters = (1 << HUGE HUGETLB_PAGE_ORDER) / COMPACT_CLUSTER_MAX
> goodness = (compactclusters / hugepage_clusters) / compactsuccess
> 
> The value of goodness is undefined if "compactsuccess" is 0.
> 
> Otherwise, the closer the "goodness" is to 1, the better. A value of 1
> implies that compaction is selecting exactly the right blocks for migration
> and the minimum number of pages are being moved around. The greater the value,
> the more "useless" work compaction is doing.
> 
> If there are a mix of high-orders that are resulting in compaction, calculating
> the goodness is a lot harder and compactcluster is just a rule of thumb as
> to how much work compaction is doing.
> 
> Does that make sense?

Sure! then, now I fully agree with COMPACTCLUSTER.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
