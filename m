Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC9D6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 20:21:59 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id u5so184222665igk.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 17:21:59 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 186si1845914ith.8.2016.05.19.17.21.57
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 17:21:58 -0700 (PDT)
Date: Fri, 20 May 2016 09:21:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160520002155.GA2224@bbox>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
 <20160517075815.GC14453@dhcp22.suse.cz>
 <20160517090254.GE14453@dhcp22.suse.cz>
 <20160519050038.GA16318@bbox>
 <20160519070357.GB26110@dhcp22.suse.cz>
 <20160519072751.GB16318@bbox>
 <20160519073957.GE26110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519073957.GE26110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, May 19, 2016 at 09:39:57AM +0200, Michal Hocko wrote:
> On Thu 19-05-16 16:27:51, Minchan Kim wrote:
> > On Thu, May 19, 2016 at 09:03:57AM +0200, Michal Hocko wrote:
> > > On Thu 19-05-16 14:00:38, Minchan Kim wrote:
> > > > On Tue, May 17, 2016 at 11:02:54AM +0200, Michal Hocko wrote:
> > > > > On Tue 17-05-16 09:58:15, Michal Hocko wrote:
> > > > > > On Thu 28-04-16 17:19:21, Michal Hocko wrote:
> > > > > > > On Wed 27-04-16 14:17:20, Andrew Morton wrote:
> > > > > > > [...]
> > > > > > > > @@ -2484,7 +2485,14 @@ static void collapse_huge_page(struct mm
> > > > > > > >  		goto out;
> > > > > > > >  	}
> > > > > > > >  
> > > > > > > > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > > > > > > +	swap = get_mm_counter(mm, MM_SWAPENTS);
> > > > > > > > +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> > > > > > > > +	/*
> > > > > > > > +	 * When system under pressure, don't swapin readahead.
> > > > > > > > +	 * So that avoid unnecessary resource consuming.
> > > > > > > > +	 */
> > > > > > > > +	if (allocstall == curr_allocstall && swap != 0)
> > > > > > > > +		__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > > > > > >  
> > > > > > > >  	anon_vma_lock_write(vma->anon_vma);
> > > > > > > >  
> > > > > > > 
> > > > > > > I have mentioned that before already but this seems like a rather weak
> > > > > > > heuristic. Don't we really rather teach __collapse_huge_page_swapin
> > > > > > > (resp. do_swap_page) do to an optimistic GFP_NOWAIT allocations and
> > > > > > > back off under the memory pressure?
> > > > > > 
> > > > > > I gave it a try and it doesn't seem really bad. Untested and I might
> > > > > > have missed something really obvious but what do you think about this
> > > > > > approach rather than relying on ALLOCSTALL which is really weak
> > > > > > heuristic:
> > > > 
> > > > I like this approach rather than playing with allocstall diff of vmevent
> > > > which can be disabled in some configuration and it's not a good indicator
> > > > to represent current memory pressure situation.
> > > 
> > > Not only that it won't work for e.g. memcg configurations because we
> > > would end up reclaiming that memcg as the gfp mask tells us to do so and
> > > ALLOCSTALL would be quite about that.
> > 
> > Right you are. I didn't consider memcg. Thanks for pointing out.
> > 
> > > 
> > > > However, I agree with Rik's requirement which doesn't want to turn over
> > > > page cache for collapsing THP page via swapin. So, your suggestion cannot
> > > > prevent it because khugepaged can consume memory through this swapin
> > > > operation continuously while kswapd is doing aging of LRU list in parallel.
> > > > IOW, fluctuation between HIGH and LOW watermark.
> > > 
> > > I am not sure this is actually a problem. We have other sources of
> > > opportunistic allocations with some fallback and those wake up kswapd
> > > (they only clear __GFP_DIRECT_RECLAIM). Also this swapin should happen
> > > only when a certain portion of the huge page is already populated so
> > 
> > I can't find any logic you mentioned "a certain portion of the huge page
> > is already populated" in next-20160517. What am I missing now?
> 
> khugepaged_max_ptes_swap. I didn't look closer but from a quick glance
> this is the threshold for the optimistic swapin.

Thanks. I see it now.

> 
> > > it won't happen all the time and sounds like we would benefit from the
> > > reclaimed page cache in favor of the THP.
> > 
> > It depends on storage speed. If a page is swapped out, it means it's not a
> > workingset so we might read cold page at the cost of evciting warm page.
> > Additionally, if the huge page was swapped out, it is likely to swap out
> > again because it's not a hot * 512 page. For those pages, shouldn't we
> > evict page cache? I think it's not a good tradeoff.
> 
> This is exactly the problem of the optimistic THP swap in. We just do
> not know whether it is worth it. But I guess that a reasonable threshold
> would solve this. It is really ineffective to keep small pages when only
> few holes are swapped out (for what ever reasons). HPAGE_PMD_NR/8 which
> we use right now is not documented but I guess 64 pages sounds like a
> reasonable value which shouldn't cause way too much of reclaim.

I don't know what's the best defaut vaule. Anyway I agree we should introduce
the threshold to collapse THP through swapin IO operation.

I think other important thing we should consider is how the THP page is likely
to be hot without split in a short time like KSM is doing double checking to
merge stable page. Of course, it wouldn't be easyI to implement but I think
algorithm is based on such *hotness* basically and then consider the number
of max_swap_ptes. IOW, I think we should approach more conservative rather
than optimistic because a page I/O overhead by wrong choice could be bigger
than benefit of a few TLB hit.
If we approach that way, maybe we don't need to detect memory pressure.

For that way, how about raising bar for swapin allowance?
I mean now we allows swapin

from
        64 pages below swap ptes and 1 page young in 512 ptes 
to
        64 pages below swap ptes and 256 page young in 512 ptes 

> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
