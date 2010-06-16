Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 744B56B01B7
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 20:22:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G0MPN6007483
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 09:22:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B30D45DE50
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:22:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F0B745DE4F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:22:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DE46E38002
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:22:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB2901DB8012
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:22:24 +0900 (JST)
Date: Wed, 16 Jun 2010 09:17:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100615141601.GL26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615135928.GK26788@csn.ul.ie>
	<4C178868.2010002@redhat.com>
	<20100615141601.GL26788@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 15:16:01 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Jun 15, 2010 at 10:04:24AM -0400, Rik van Riel wrote:
> > On 06/15/2010 09:59 AM, Mel Gorman wrote:
> >> On Tue, Jun 15, 2010 at 09:34:18AM -0400, Rik van Riel wrote:
> >>> On 06/15/2010 07:45 AM, Mel Gorman wrote:
> >
> >>>>>>
> >>>>>> +/* kswapd and memcg can writeback as they are unlikely to overflow stack */
> >>>>>> +static inline bool reclaim_can_writeback(struct scan_control *sc)
> >>>>>> +{
> >>>>>> +	return current_is_kswapd() || sc->mem_cgroup != NULL;
> >>>>>> +}
> >
> >>> If direct reclaim can overflow the stack, so can direct
> >>> memcg reclaim.  That means this patch does not solve the
> >>> stack overflow, while admitting that we do need the
> >>> ability to get specific pages flushed to disk from the
> >>> pageout code.
> >>>
> >>
> >> What path is taken with memcg != NULL that could overflow the stack? I
> >> couldn't spot one but mm/memcontrol.c is a bit tangled so finding all
> >> its use cases is tricky. The critical path I had in mind though was
> >> direct reclaim and for that path, memcg == NULL or did I miss something?
> >
> > mem_cgroup_hierarchical_reclaim -> try_to_free_mem_cgroup_pages
> >
> 
> But in turn, where is mem_cgroup_hierarchical_reclaim called from direct
> reclaim? It appears to be only called from the fault path or as a result
> of the memcg changing size.
> 
yes. It's only called from 
	- page fault
	- add_to_page_cache()

I think we'll see no stack problem. Now, memcg doesn't wakeup kswapd for
reclaiming memory, it needs direct writeback.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
