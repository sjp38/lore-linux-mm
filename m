Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0A43C6B01C1
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 20:44:28 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G0iQ2N019843
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 09:44:26 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 518DE45DE62
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:44:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7197D45DE5E
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:44:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 56A981DB8060
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:44:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D926E1DB803C
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:44:24 +0900 (JST)
Date: Wed, 16 Jun 2010 09:39:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100616093958.00673123.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C181AFD.5060503@redhat.com>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615135928.GK26788@csn.ul.ie>
	<4C178868.2010002@redhat.com>
	<20100615141601.GL26788@csn.ul.ie>
	<20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
	<4C181AFD.5060503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 20:29:49 -0400
Rik van Riel <riel@redhat.com> wrote:

> On 06/15/2010 08:17 PM, KAMEZAWA Hiroyuki wrote:
> > On Tue, 15 Jun 2010 15:16:01 +0100
> > Mel Gorman<mel@csn.ul.ie>  wrote:
> 
> >> But in turn, where is mem_cgroup_hierarchical_reclaim called from direct
> >> reclaim? It appears to be only called from the fault path or as a result
> >> of the memcg changing size.
> >>
> > yes. It's only called from
> > 	- page fault
> > 	- add_to_page_cache()
> >
> > I think we'll see no stack problem. Now, memcg doesn't wakeup kswapd for
> > reclaiming memory, it needs direct writeback.
> 
> Of course, a memcg page fault could still be triggered
> from copy_to_user or copy_from_user, with a fairly
> arbitrary stack frame above...
> 

Hmm. But I don't expect copy_from/to_user is called in very deep stack.

Should I prepare a thread for reclaiming memcg pages ?
Because we shouldn't limit kswapd's cpu time by CFS cgroup, waking up
kswapd just because "a memcg hit limits" isn't fun. 

Hmm, or do you recommend no-dirty-page-writeback when a memcg hits limit ?
Maybe we'll see much swaps.

I want to go with this for a while, changing memcg's behavior will took
some amounts of time, there are only a few developpers.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
