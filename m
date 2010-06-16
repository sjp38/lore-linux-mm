Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B683A6B01B9
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 20:35:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G0ZQvx012854
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 09:35:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAB6B45DE64
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:35:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFF7145DE4E
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:35:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C65D1DB803F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:35:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 328841DB803B
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:35:25 +0900 (JST)
Date: Wed, 16 Jun 2010 09:30:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100616093059.7765574f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100615135408.GJ26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615133727.GA27980@infradead.org>
	<20100615135408.GJ26788@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 14:54:08 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Jun 15, 2010 at 09:37:27AM -0400, Christoph Hellwig wrote:
> > On Tue, Jun 15, 2010 at 09:34:18AM -0400, Rik van Riel wrote:
> > > If direct reclaim can overflow the stack, so can direct
> > > memcg reclaim.  That means this patch does not solve the
> > > stack overflow, while admitting that we do need the
> > > ability to get specific pages flushed to disk from the
> > > pageout code.
> > 
> > Can you explain what the hell memcg reclaim is and why it needs
> > to reclaim from random contexts?
> 
> Kamezawa Hiroyuki has the full story here but here is a summary.
> 
Thank you.

> memcg is the Memory Controller cgroup
> (Documentation/cgroups/memory.txt). It's intended for the control of the
> amount of memory usable by a group of processes but its behaviour in
> terms of reclaim differs from global reclaim. It has its own LRU lists
> and kswapd operates on them.

No, we don't use kswapd. But we have some hooks in kswapd for implementing
soft-limit. Soft-limit is for giving a hint for kswapd "please reclaim memory
from this memcg" when global memory exhausts and kswapd runs.

What a memcg use when it his limit is just direct reclaim.
(*) Justfing using a cpu by a kswapd because a memcg hits limit is difficult 
    for me. So, I don't use kswapd until now.
    When direct-reclaim is used, cost-of-reclaim will be charged against
    a cpu cgroup which a thread belongs to.


> What is surprising is that direct reclaim
> for a process in the control group also does not operate within the
> cgroup.
Sorry, I can't understand ....

> 
> Reclaim from a cgroup happens from the fault path. The new page is
> "charged" to the cgroup. If it exceeds its allocated resources, some
> pages within the group are reclaimed in a path that is similar to direct
> reclaim except for its entry point.
> 
yes.

> So, memcg is not reclaiming from a random context, there is a limited
> number of cases where a memcg is reclaiming and it is not expected to
> overflow the stack.
> 

I think so. Especially, we'll never see 1k stack use of select().

> > It seems everything that has a cg in it's name that I stumbled over
> > lately seems to be some ugly wart..
> > 
> 
> The wart in this case is that the behaviour of page reclaim within a
> memcg and globally differ a fair bit.
> 

Sorry. But there has been very long story to reach current implementations.
But don't worry, of memcg is not activated (not mounted), it doesn't affect
the behavior of processes ;)

But Hmm..

>[kamezawa@bluextal mmotm-2.6.35-0611]$ wc -l mm/memcontrol.c
>4705 mm/memcontrol.c

may need some diet :(


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
