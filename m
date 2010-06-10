Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1DE326B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:34:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5A1YOBi028988
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Jun 2010 10:34:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF88845DE51
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:34:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83EB845DE4D
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:34:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A51E1DB804F
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:34:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 10CD61DB8041
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:34:24 +0900 (JST)
Date: Thu, 10 Jun 2010 10:29:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-Id: <20100610102959.ccbcfb32.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100610011035.GG5650@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
	<20100609115211.435a45f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609095200.GA5650@csn.ul.ie>
	<20100610093842.6a038ab0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100610011035.GG5650@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 02:10:35 +0100
Mel Gorman <mel@csn.ul.ie> wrote:
> >   # mount -t cgroup none /cgroups -o memory
> >   # mkdir /cgroups/A
> >   # echo $$ > /cgroups/A
> >   # echo 300M > /cgroups/memory.limit_in_bytes
> >   # make -j 8 or make -j 16
> > 
> 
> That sort of scenario would be barely pushed by kernbench. For a single
> kernel build, it's about 250-400M depending on the .config but it's still
> a bit unreliable. Critically, it's not the sort of workload that would have
> lots of long-lived mappings that would hurt a workload a lot if it was being
> paged out.

You're right. An excuse for me is that my concern is usually the amount of
swap-out and OOM at rapid/heavy pressure comes because it's visible to
users easily. So, I use short-lived process test.

> Maybe it would be reasonable as a starting point but we'd have to be
> very careful of the stack usage figures? I'm leaning towards this
> approach to start with.
> 
> I'm preparing another release that takes my two most important patches
> about reclaim but also reduces usage in page relcaim (a combination of
> two previously released series). In combination, it might be ok for the
> memcg paths to reclaim pages from a stack perspective although the IO
> pattern might still blow.

sounds nice.

> > > I'm not sure how a flusher thread would work just within a cgroup. It
> > > would have to do a lot of searching to find the pages it needs
> > > considering that it's looking at inodes rather than pages.
> > > 
> >
> > yes. So, I(we) need some way for coloring inode for selectable writeback.
> > But people in this area are very nervous about performance (me too ;), I've
> > not found the answer yet.
> > 
> 
> I worry that too much targetting of writing back a specific inode would
> have other consequences.

I personally think this(writeback scheduling) is a job for I/O cgroup.
So, I guess what memcg can do is dirty-ratio-limiting, at most. The user has to
set well-balanced combination of memory+I/O cgroup.
Sorry for wrong mixture of story.


> > Okay, I'll consider about how to kick kswapd via memcg or flusher-for-memcg.
> > Please go ahead as you want. I love good I/O pattern, too.
> > 
> 
> For the moment, I'm strongly leaning towards allowing memcg to write
> back pages. The IO pattern might not be great, but it would be in line
> with current behaviour. The critical question is really "is it possible
> to overflow the stack?".
> 

Because I don't use XFS, I don't have relaiable answer, now. But, at least,
memcg's memory reclaim will never be called as top of do_select(), which
uses 1000 bytes. 

We have to consider long-term fix for I/O patterns under memmcg but
please global-reclaim-update-first. We did in that way when splitting LRU
to ANON and FILE. I don't want to make memcg as a burden for updating
vmscan.c better. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
