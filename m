Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE746B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:10:59 -0400 (EDT)
Date: Thu, 10 Jun 2010 02:10:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100610011035.GG5650@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100609115211.435a45f7.kamezawa.hiroyu@jp.fujitsu.com> <20100609095200.GA5650@csn.ul.ie> <20100610093842.6a038ab0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100610093842.6a038ab0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 10, 2010 at 09:38:42AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 9 Jun 2010 10:52:00 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Wed, Jun 09, 2010 at 11:52:11AM +0900, KAMEZAWA Hiroyuki wrote:
>  
> > > > <SNIP>
> > > 
> > > My concern is how memcg should work. IOW, what changes will be necessary for
> > > memcg to work with the new vmscan logic as no-direct-writeback.
> > > 
> > 
> > At worst, memcg waits on background flushers to clean their pages but
> > obviously this could lead to stalls in containers if it happened to be full
> > of dirty pages.
> > 
>
> yes.
> 

I'd like to have a better intuitive idea of how bad this really is. My current
understanding is that we don't know how bad it really is but it "feels vaguely
bad". I am focusing on the global scenario right now but only because I know
it's important and that any complex IO or filesystem can overflow the stack.

> > Do you have test scenarios already setup for functional and performance
> > regression testing of containers? If so, can you run tests with this series
> > and see what sort of impact you find? I haven't done performance testing
> > with containers to date so I don't know what the expected values are.
> > 
> Maybe kernbench is enough.

I think kernbench only stresses reclaim in very specific scenarios. I wouldn't
think it is reliable for this sort of evaluation. I've been using sysbench
and the high-order stress allocation to evaulate IO and lumpy reclaim. I'm
missing a test on stack-usage because I lack a test situation with complex
IO (I lack the resources to setup such a thing) or a complex FS (because I
haven't set up one).

> I think it does enough write and malloc.
> 'Limit' size for test depends on your host. I sometimes does this on
> 8cpu SMP box.
>   
>   # mount -t cgroup none /cgroups -o memory
>   # mkdir /cgroups/A
>   # echo $$ > /cgroups/A
>   # echo 300M > /cgroups/memory.limit_in_bytes
>   # make -j 8 or make -j 16
> 

That sort of scenario would be barely pushed by kernbench. For a single
kernel build, it's about 250-400M depending on the .config but it's still
a bit unreliable. Critically, it's not the sort of workload that would have
lots of long-lived mappings that would hurt a workload a lot if it was being
paged out.

> Comparing size of swap and speed will be interesting.
> (Above 300M is enough small because my test machine has 24G memory.)
> 
> Or 
>   # mount -t cgroup none /cgroups -o memory
>   # mkdir /cgroups/A
>   # echo $$ > /cgroups/A
>   # echo 50M > /cgroups/memory.limit_in_bytes
>   # dd if=/dev/zero of=./tmpfile bs=65536 count=100000
> 

That would push it more, but you're still talking about short-lived
processes with a lowish footprint that might not hurt in an obvious
manner in a writeback situation.

A more reliable measure would be sysbench sized to the size of the container
I imagined.

> or some. When I tested the original patch for "avoiding writeback" by
> Dave Chinner, I saw 2 ooms in 10 tests.
> If not patched, I never see OOM.
> 

My patches build on Dave's approach somewhat by waiting in lumpy reclaim
for the IO to happen and in the general case by batching the dirty pages
together for kswapd.

> > > Maybe an ideal solution will be
> > >  - support buffered I/O tracking in I/O cgroup.
> > >  - flusher threads should work with I/O cgroup.
> > >  - memcg itself should support dirty ratio. and add a trigger to kick flusher
> > >    threads for dirty pages in a memcg.
> > > But I know it's a long way.
> > > 
> > 
> > I'm not very familiar with memcg I'm afraid or its requirements so I am
> > having trouble guessing which of these would behave the best. You could take
> > a gamble on having memcg doing writeback in direct reclaim but you may run
> > into the same problem of overflowing stacks.
> > 
>
> maybe.
> 

Maybe it would be reasonable as a starting point but we'd have to be
very careful of the stack usage figures? I'm leaning towards this
approach to start with.

I'm preparing another release that takes my two most important patches
about reclaim but also reduces usage in page relcaim (a combination of
two previously released series). In combination, it might be ok for the
memcg paths to reclaim pages from a stack perspective although the IO
pattern might still blow.

> > I'm not sure how a flusher thread would work just within a cgroup. It
> > would have to do a lot of searching to find the pages it needs
> > considering that it's looking at inodes rather than pages.
> > 
>
> yes. So, I(we) need some way for coloring inode for selectable writeback.
> But people in this area are very nervous about performance (me too ;), I've
> not found the answer yet.
> 

I worry that too much targetting of writing back a specific inode would
have other consequences.

> 
> > One possibility I guess would be to create a flusher-like thread if a direct
> > reclaimer finds that the dirty pages in the container are above the dirty
> > ratio. It would scan and clean all dirty pages in the container LRU on behalf
> > of dirty reclaimers.
> > 
>
> Yes, that's possible. But Andrew recommends not to do add more threads. So,
> I'll use workqueue if necessary.
> 

I also was not happy with adding more threads unless we had to. In a
sense, I preferred adding logic to kswapd that switched between
reclaiming for global and containers but too much of how it behaves
depends on "how many containers are there"

In this sense, I would lean more torwards letting containers write back
pages in reclaim and see what the stack usage looks like.

> > Another possibility would be to have kswapd work in containers.
> > Specifically, if wakeup_kswapd() is called with a cgroup that it's added
> > to a list. kswapd gives priority to global reclaim but would
> > occasionally check if there is a container that needs kswapd on a
> > pending list and if so, work within the container. Is there a good
> > reason why kswapd does not work within container groups?
> > 
>
> One reason is node v.s. memcg.
> Because memcg doesn't limit memory placement, a container can contain pages
> from the all nodes. So,it's a bit problem which node's kswapd we should run .
> (but yes, maybe small problem.)

I would hope it's small. I would expect a correlation between containers
and the nodes they have access to.

> Another is memory-reclaim-prioirty between memcg.
> (I don't want to add such a knob...)
> 
> Maybe it's time to consider about that.
> Now, we're using kswapd for softlimit. I think similar hints for kswapd
> should work. yes.
> 
> > Finally, you could just allow reclaim within a memcg do writeback. Right
> > now, the check is based on current_is_kswapd() but I could create a helper
> > function that also checked for sc->mem_cgroup. Direct reclaim from the
> > page allocator never appears to work within a container group (which
> > raises questions in itself such as why a process in a container would
> > reclaim pages outside the container?) so it would remain safe.
> > 
>
> isolate_lru_pages() for memcg finds only pages in a memcg ;) 
> 

Ok.

> 
> > > How the new logic works with memcg ? Because memcg doesn't trigger kswapd,
> > > memcg has to wait for a flusher thread make pages clean ?
> > 
> > Right now, memcg has to wait for a flusher thread to make pages clean.
> > 
>
> ok.
> 
> 
> > > Or memcg should have kswapd-for-memcg ?
> > > 
> > > Is it okay to call writeback directly when !scanning_global_lru() ?
> > > memcg's reclaim routine is only called from specific positions, so, I guess
> > > no stack problem.
> > 
> > It's a judgement call from you really. I see that direct reclaimers do
> > not set mem_cgroup so it's down to - are you reasonably sure that all
> > the paths that reclaim based on a container are not deep?
> 
> One concerns is add_to_page_cache(). If it's called in deep stack, my assumption
> is wrong.
> 

But I wouldn't expect that in general to be very deep. Maybe I'm wrong.

> > I looked
> > around for a while and the bulk appeared to be in the fault path so I
> > would guess "yes" but as I'm not familiar with the memcg implementation
> > I'll have missed a lot.
> > 
> > > But we just have I/O pattern problem.
> > 
> > True.
> > 
> 
> Okay, I'll consider about how to kick kswapd via memcg or flusher-for-memcg.
> Please go ahead as you want. I love good I/O pattern, too.
> 

For the moment, I'm strongly leaning towards allowing memcg to write
back pages. The IO pattern might not be great, but it would be in line
with current behaviour. The critical question is really "is it possible
to overflow the stack?".

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
