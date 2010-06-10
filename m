Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DD616B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 20:43:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5A0h8gN003746
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Jun 2010 09:43:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1187145DE7D
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:43:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5D0D45DE6F
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:43:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E19AE3800B
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:43:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E350AE38006
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:43:06 +0900 (JST)
Date: Thu, 10 Jun 2010 09:38:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-Id: <20100610093842.6a038ab0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100609095200.GA5650@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
	<20100609115211.435a45f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609095200.GA5650@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010 10:52:00 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Jun 09, 2010 at 11:52:11AM +0900, KAMEZAWA Hiroyuki wrote:
 
> > > <SNIP>
> > 
> > My concern is how memcg should work. IOW, what changes will be necessary for
> > memcg to work with the new vmscan logic as no-direct-writeback.
> > 
> 
> At worst, memcg waits on background flushers to clean their pages but
> obviously this could lead to stalls in containers if it happened to be full
> of dirty pages.
> 
yes.

> Do you have test scenarios already setup for functional and performance
> regression testing of containers? If so, can you run tests with this series
> and see what sort of impact you find? I haven't done performance testing
> with containers to date so I don't know what the expected values are.
> 
Maybe kernbench is enough. I think it does enough write and malloc.
'Limit' size for test depends on your host. I sometimes does this on
8cpu SMP box.
  
  # mount -t cgroup none /cgroups -o memory
  # mkdir /cgroups/A
  # echo $$ > /cgroups/A
  # echo 300M > /cgroups/memory.limit_in_bytes
  # make -j 8 or make -j 16

Comparing size of swap and speed will be interesting.
(Above 300M is enough small because my test machine has 24G memory.)

Or 
  # mount -t cgroup none /cgroups -o memory
  # mkdir /cgroups/A
  # echo $$ > /cgroups/A
  # echo 50M > /cgroups/memory.limit_in_bytes
  # dd if=/dev/zero of=./tmpfile bs=65536 count=100000

or some. When I tested the original patch for "avoiding writeback" by
Dave Chinner, I saw 2 ooms in 10 tests.
If not patched, I never see OOM.



> > Maybe an ideal solution will be
> >  - support buffered I/O tracking in I/O cgroup.
> >  - flusher threads should work with I/O cgroup.
> >  - memcg itself should support dirty ratio. and add a trigger to kick flusher
> >    threads for dirty pages in a memcg.
> > But I know it's a long way.
> > 
> 
> I'm not very familiar with memcg I'm afraid or its requirements so I am
> having trouble guessing which of these would behave the best. You could take
> a gamble on having memcg doing writeback in direct reclaim but you may run
> into the same problem of overflowing stacks.
> 
maybe.

> I'm not sure how a flusher thread would work just within a cgroup. It
> would have to do a lot of searching to find the pages it needs
> considering that it's looking at inodes rather than pages.
> 
yes. So, I(we) need some way for coloring inode for selectable writeback.
But people in this area are very nervous about performance (me too ;), I've
not found the answer yet.


> One possibility I guess would be to create a flusher-like thread if a direct
> reclaimer finds that the dirty pages in the container are above the dirty
> ratio. It would scan and clean all dirty pages in the container LRU on behalf
> of dirty reclaimers.
> 
Yes, that's possible. But Andrew recommends not to do add more threads. So,
I'll use workqueue if necessary.

> Another possibility would be to have kswapd work in containers.
> Specifically, if wakeup_kswapd() is called with a cgroup that it's added
> to a list. kswapd gives priority to global reclaim but would
> occasionally check if there is a container that needs kswapd on a
> pending list and if so, work within the container. Is there a good
> reason why kswapd does not work within container groups?
> 
One reason is node v.s. memcg.
Because memcg doesn't limit memory placement, a container can contain pages
from the all nodes. So,it's a bit problem which node's kswapd we should run .
(but yes, maybe small problem.)
Another is memory-reclaim-prioirty between memcg.
(I don't want to add such a knob...)

Maybe it's time to consider about that.
Now, we're using kswapd for softlimit. I think similar hints for kswapd
should work. yes.

> Finally, you could just allow reclaim within a memcg do writeback. Right
> now, the check is based on current_is_kswapd() but I could create a helper
> function that also checked for sc->mem_cgroup. Direct reclaim from the
> page allocator never appears to work within a container group (which
> raises questions in itself such as why a process in a container would
> reclaim pages outside the container?) so it would remain safe.
> 
isolate_lru_pages() for memcg finds only pages in a memcg ;) 


> > How the new logic works with memcg ? Because memcg doesn't trigger kswapd,
> > memcg has to wait for a flusher thread make pages clean ?
> 
> Right now, memcg has to wait for a flusher thread to make pages clean.
> 
ok.


> > Or memcg should have kswapd-for-memcg ?
> > 
> > Is it okay to call writeback directly when !scanning_global_lru() ?
> > memcg's reclaim routine is only called from specific positions, so, I guess
> > no stack problem.
> 
> It's a judgement call from you really. I see that direct reclaimers do
> not set mem_cgroup so it's down to - are you reasonably sure that all
> the paths that reclaim based on a container are not deep?

One concerns is add_to_page_cache(). If it's called in deep stack, my assumption
is wrong.

> I looked
> around for a while and the bulk appeared to be in the fault path so I
> would guess "yes" but as I'm not familiar with the memcg implementation
> I'll have missed a lot.
> 
> > But we just have I/O pattern problem.
> 
> True.
> 

Okay, I'll consider about how to kick kswapd via memcg or flusher-for-memcg.
Please go ahead as you want. I love good I/O pattern, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
