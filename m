Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D91676B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 03:27:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so140904780pfz.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:27:44 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id xr4si4365030pab.53.2016.05.19.00.27.43
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 00:27:43 -0700 (PDT)
Date: Thu, 19 May 2016 16:27:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160519072751.GB16318@bbox>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
 <20160517075815.GC14453@dhcp22.suse.cz>
 <20160517090254.GE14453@dhcp22.suse.cz>
 <20160519050038.GA16318@bbox>
 <20160519070357.GB26110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519070357.GB26110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, May 19, 2016 at 09:03:57AM +0200, Michal Hocko wrote:
> On Thu 19-05-16 14:00:38, Minchan Kim wrote:
> > On Tue, May 17, 2016 at 11:02:54AM +0200, Michal Hocko wrote:
> > > On Tue 17-05-16 09:58:15, Michal Hocko wrote:
> > > > On Thu 28-04-16 17:19:21, Michal Hocko wrote:
> > > > > On Wed 27-04-16 14:17:20, Andrew Morton wrote:
> > > > > [...]
> > > > > > @@ -2484,7 +2485,14 @@ static void collapse_huge_page(struct mm
> > > > > >  		goto out;
> > > > > >  	}
> > > > > >  
> > > > > > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > > > > +	swap = get_mm_counter(mm, MM_SWAPENTS);
> > > > > > +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> > > > > > +	/*
> > > > > > +	 * When system under pressure, don't swapin readahead.
> > > > > > +	 * So that avoid unnecessary resource consuming.
> > > > > > +	 */
> > > > > > +	if (allocstall == curr_allocstall && swap != 0)
> > > > > > +		__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > > > >  
> > > > > >  	anon_vma_lock_write(vma->anon_vma);
> > > > > >  
> > > > > 
> > > > > I have mentioned that before already but this seems like a rather weak
> > > > > heuristic. Don't we really rather teach __collapse_huge_page_swapin
> > > > > (resp. do_swap_page) do to an optimistic GFP_NOWAIT allocations and
> > > > > back off under the memory pressure?
> > > > 
> > > > I gave it a try and it doesn't seem really bad. Untested and I might
> > > > have missed something really obvious but what do you think about this
> > > > approach rather than relying on ALLOCSTALL which is really weak
> > > > heuristic:
> > 
> > I like this approach rather than playing with allocstall diff of vmevent
> > which can be disabled in some configuration and it's not a good indicator
> > to represent current memory pressure situation.
> 
> Not only that it won't work for e.g. memcg configurations because we
> would end up reclaiming that memcg as the gfp mask tells us to do so and
> ALLOCSTALL would be quite about that.

Right you are. I didn't consider memcg. Thanks for pointing out.

> 
> > However, I agree with Rik's requirement which doesn't want to turn over
> > page cache for collapsing THP page via swapin. So, your suggestion cannot
> > prevent it because khugepaged can consume memory through this swapin
> > operation continuously while kswapd is doing aging of LRU list in parallel.
> > IOW, fluctuation between HIGH and LOW watermark.
> 
> I am not sure this is actually a problem. We have other sources of
> opportunistic allocations with some fallback and those wake up kswapd
> (they only clear __GFP_DIRECT_RECLAIM). Also this swapin should happen
> only when a certain portion of the huge page is already populated so

I can't find any logic you mentioned "a certain portion of the huge page
is already populated" in next-20160517. What am I missing now?

> it won't happen all the time and sounds like we would benefit from the
> reclaimed page cache in favor of the THP.

It depends on storage speed. If a page is swapped out, it means it's not a
workingset so we might read cold page at the cost of evciting warm page.
Additionally, if the huge page was swapped out, it is likely to swap out
again because it's not a hot * 512 page. For those pages, shouldn't we
evict page cache? I think it's not a good tradeoff.

> 
> > So, How about using waitqueue_active(&pgdat->kswapd_wait) to detect
> > current memory pressure? So if kswapd is active, we could avoid swapin
> > for THP collapsing.
> 
> Dunno, this sounds quite arbitrary. And I am even not sure this all
> optimistic swap in is a huge win to be honest. I just really hate the
> ALLOCSTALL heuristic because it simply doesn't work.

Agree.
 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
