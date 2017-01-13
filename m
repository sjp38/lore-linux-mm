Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3AD6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:57:38 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so52102202itb.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:57:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a7si12103533pll.172.2017.01.13.00.57.37
        for <linux-mm@kvack.org>;
        Fri, 13 Jan 2017 00:57:37 -0800 (PST)
Date: Fri, 13 Jan 2017 17:57:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170113085734.GC8018@bbox>
References: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
 <20170110235250.GA7130@bbox>
 <20170111155239.GD16365@dhcp22.suse.cz>
 <20170112051247.GA8387@bbox>
 <20170112081554.GB2264@dhcp22.suse.cz>
 <20170112084813.GA24030@bbox>
 <20170112091016.GE2264@dhcp22.suse.cz>
 <20170113013724.GA23494@bbox>
 <20170113074705.GA21784@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113074705.GA21784@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 13, 2017 at 08:47:07AM +0100, Michal Hocko wrote:
> On Fri 13-01-17 10:37:24, Minchan Kim wrote:
> > Hello,
> > 
> > On Thu, Jan 12, 2017 at 10:10:17AM +0100, Michal Hocko wrote:
> > > On Thu 12-01-17 17:48:13, Minchan Kim wrote:
> > > > On Thu, Jan 12, 2017 at 09:15:54AM +0100, Michal Hocko wrote:
> > > > > On Thu 12-01-17 14:12:47, Minchan Kim wrote:
> > > > > > Hello,
> > > > > > 
> > > > > > On Wed, Jan 11, 2017 at 04:52:39PM +0100, Michal Hocko wrote:
> > > > > > > On Wed 11-01-17 08:52:50, Minchan Kim wrote:
> > > > > > > [...]
> > > > > > > > > @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
> > > > > > > > >  	if (!file && !total_swap_pages)
> > > > > > > > >  		return false;
> > > > > > > > >  
> > > > > > > > > -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > > -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > > > +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > > +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > > >  
> > > > > > > > 
> > > > > > > > the decision of deactivating is based on eligible zone's LRU size,
> > > > > > > > not whole zone so why should we need to get a trace of all zones's LRU?
> > > > > > > 
> > > > > > > Strictly speaking, the total_ counters are not necessary for making the
> > > > > > > decision. I found reporting those numbers useful regardless because this
> > > > > > > will give us also an information how large is the eligible portion of
> > > > > > > the LRU list. We do not have any other tracepoint which would report
> > > > > > > that.
> > > > > > 
> > > > > > The patch doesn't say anything why it's useful. Could you tell why it's
> > > > > > useful and inactive_list_is_low should be right place?
> > > > > > 
> > > > > > Don't get me wrong, please. I don't want to bother you.
> > > > > > I really don't want to add random stuff although it's tracepoint for
> > > > > > debugging.
> > > > > 
> > > > > This doesn't sounds random to me. We simply do not have a full picture
> > > > > on 32b systems without this information. Especially when memcgs are
> > > > > involved and global numbers spread over different LRUs.
> > > > 
> > > > Could you elaborate it?
> > > 
> > > The problem with 32b systems is that you only can consider a part of the
> > > LRU for the lowmem requests. While we have global counters to see how
> > > much lowmem inactive/active pages we have, those get distributed to
> > > memcg LRUs. And that distribution is impossible to guess. So my thinking
> > > is that it can become a real head scratcher to realize why certain
> > > active LRUs are aged while others are not. This was the case when I was
> > > debugging the last issue which triggered all this. All of the sudden I
> > > have seen many invocations when inactive and active were zero which
> > > sounded weird, until I realized that those are memcg's lruvec which is
> > > what total numbers told me...
> > 
> > Hmm, it seems I miss something. AFAIU, what you need is just memcg
> > identifier, not all lru size. If it isn't, please tell more detail
> > usecase of all lru size in that particular tracepoint.
> 
> Having memcg id would be definitely helpful but that alone wouldn't tell
> us how is the lowmem distributed. To be honest I really fail to see why
> this bothers you all that much.

Because I fail to understand why you want to need additional all zone's
LRU stat in inactive_list_is_low. With clear understanding, we can think
over that it's really needed and right place to achieve the goal.

Could you say with a example you can think? It's really helpful to
understand why it's needed.

>  
> [...]
> > > > > I am not sure I am following. Why is the additional parameter a problem?
> > > > 
> > > > Well, to me, it's not a elegance. Is it? If we need such boolean variable
> > > > to control show the trace, it means it's not a good place or think
> > > > refactoring.
> > > 
> > > But, even when you refactor the code there will be other callers of
> > > inactive_list_is_low outside of shrink_active_list...
> > 
> > Yes, that's why I said "it's okay if you love your version". However,
> > we can do refactoring to remove "bool trace" and even, it makes code
> > more readable, I believe.
> > 
> > >From 06eb7201d781155a8dee7e72fbb8423ec8175223 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 13 Jan 2017 10:13:36 +0900
> > Subject: [PATCH] mm: refactoring inactive_list_is_low
> > 
> > Recently, Michal Hocko added tracepoint into inactive_list_is_low
> > for catching why VM decided to age the active list to know
> > active/inacive balancing problem. With that, unfortunately, it
> > added "bool trace" to inactlive_list_is_low to control some place
> > should be prohibited tracing. It is not elegant to me so this patch
> > try to clean it up.
> > 
> > Normally, most inactive_list_is_low is used for deciding active list
> > demotion but one site(i.e., get_scan_count) uses for other purpose
> > which reclaim file LRU forcefully. Sites for deactivation calls it
> > with shrink_active_list. It means inactive_list_is_low could be
> > located in shrink_active_list.
> > 
> > One more thing this patch does is to remove "ratio" in the tracepoint
> > because we can get it by post processing in script via simple math.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/trace/events/vmscan.h |  9 +++-----
> >  mm/vmscan.c                   | 51 ++++++++++++++++++++++++-------------------
> >  2 files changed, 31 insertions(+), 29 deletions(-)
> 
> this cleanup adds more lines than it removes. I think reporting the

It's just marginal because the function names are really long and I want to
keep a 80 column rule.
Anyway, I'm not insisting on pushing this patch although I still think
it's not nice to add "boolean variable" to control tracing or not.
It's not a main interest.

> ratio is helpful because it doesn't cost us anything while calculating
> it by later is just a bit annoying.

I really cannot imagine when inactive_ratio value is helpful for debugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
