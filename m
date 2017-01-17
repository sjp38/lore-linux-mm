Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3E96B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:45:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so279489245pfy.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:45:35 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n29si8092527pfi.246.2017.01.16.22.45.33
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 22:45:34 -0800 (PST)
Date: Tue, 17 Jan 2017 15:45:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170117064531.GA9812@blaptop>
References: <20170110235250.GA7130@bbox>
 <20170111155239.GD16365@dhcp22.suse.cz>
 <20170112051247.GA8387@bbox>
 <20170112081554.GB2264@dhcp22.suse.cz>
 <20170112084813.GA24030@bbox>
 <20170112091016.GE2264@dhcp22.suse.cz>
 <20170113013724.GA23494@bbox>
 <20170113074705.GA21784@dhcp22.suse.cz>
 <20170113085734.GC8018@bbox>
 <20170113091009.GD25212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113091009.GD25212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

Hello,

On Fri, Jan 13, 2017 at 10:10:09AM +0100, Michal Hocko wrote:
> On Fri 13-01-17 17:57:34, Minchan Kim wrote:
> > On Fri, Jan 13, 2017 at 08:47:07AM +0100, Michal Hocko wrote:
> > > On Fri 13-01-17 10:37:24, Minchan Kim wrote:
> > > > Hello,
> > > > 
> > > > On Thu, Jan 12, 2017 at 10:10:17AM +0100, Michal Hocko wrote:
> > > > > On Thu 12-01-17 17:48:13, Minchan Kim wrote:
> > > > > > On Thu, Jan 12, 2017 at 09:15:54AM +0100, Michal Hocko wrote:
> > > > > > > On Thu 12-01-17 14:12:47, Minchan Kim wrote:
> > > > > > > > Hello,
> > > > > > > > 
> > > > > > > > On Wed, Jan 11, 2017 at 04:52:39PM +0100, Michal Hocko wrote:
> > > > > > > > > On Wed 11-01-17 08:52:50, Minchan Kim wrote:
> > > > > > > > > [...]
> > > > > > > > > > > @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
> > > > > > > > > > >  	if (!file && !total_swap_pages)
> > > > > > > > > > >  		return false;
> > > > > > > > > > >  
> > > > > > > > > > > -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > > > > -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > > > > > +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > > > > +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > > > > >  
> > > > > > > > > > 
> > > > > > > > > > the decision of deactivating is based on eligible zone's LRU size,
> > > > > > > > > > not whole zone so why should we need to get a trace of all zones's LRU?
> > > > > > > > > 
> > > > > > > > > Strictly speaking, the total_ counters are not necessary for making the
> > > > > > > > > decision. I found reporting those numbers useful regardless because this
> > > > > > > > > will give us also an information how large is the eligible portion of
> > > > > > > > > the LRU list. We do not have any other tracepoint which would report
> > > > > > > > > that.
> > > > > > > > 
> > > > > > > > The patch doesn't say anything why it's useful. Could you tell why it's
> > > > > > > > useful and inactive_list_is_low should be right place?
> > > > > > > > 
> > > > > > > > Don't get me wrong, please. I don't want to bother you.
> > > > > > > > I really don't want to add random stuff although it's tracepoint for
> > > > > > > > debugging.
> > > > > > > 
> > > > > > > This doesn't sounds random to me. We simply do not have a full picture
> > > > > > > on 32b systems without this information. Especially when memcgs are
> > > > > > > involved and global numbers spread over different LRUs.
> > > > > > 
> > > > > > Could you elaborate it?
> > > > > 
> > > > > The problem with 32b systems is that you only can consider a part of the
> > > > > LRU for the lowmem requests. While we have global counters to see how
> > > > > much lowmem inactive/active pages we have, those get distributed to
> > > > > memcg LRUs. And that distribution is impossible to guess. So my thinking
> > > > > is that it can become a real head scratcher to realize why certain
> > > > > active LRUs are aged while others are not. This was the case when I was
> > > > > debugging the last issue which triggered all this. All of the sudden I
> > > > > have seen many invocations when inactive and active were zero which
> > > > > sounded weird, until I realized that those are memcg's lruvec which is
> > > > > what total numbers told me...
> > > > 
> > > > Hmm, it seems I miss something. AFAIU, what you need is just memcg
> > > > identifier, not all lru size. If it isn't, please tell more detail
> > > > usecase of all lru size in that particular tracepoint.
> > > 
> > > Having memcg id would be definitely helpful but that alone wouldn't tell
> > > us how is the lowmem distributed. To be honest I really fail to see why
> > > this bothers you all that much.
> > 
> > Because I fail to understand why you want to need additional all zone's
> > LRU stat in inactive_list_is_low. With clear understanding, we can think
> > over that it's really needed and right place to achieve the goal.
> > 
> > Could you say with a example you can think? It's really helpful to
> > understand why it's needed.
> 
> OK, I feel I am repeating myself but let me try again. Without the
> total_ numbers we really do not know how is the lowmem distributed over
> lruvecs. There is simply no way to get this information from existing
> counters if memcg is enabled.

I can't understand clearly why you need to know distribution.
Anyway, if we need it, why do you think such particular inactive_list_is_low
is right place?

Actually, IMO, there is no need to insert any tracepoint in inactive_list_is_low.
Instead, if we add tracepint in get_scan_count to record each LRU list size and
nr[LRU_{INACTIVE,ACTIVE}_{ANON|FILE}], it could be general and more helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
