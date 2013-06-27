Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E44DE6B0036
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 12:11:07 -0400 (EDT)
Date: Thu, 27 Jun 2013 18:11:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130627161103.GA25165@dhcp22.suse.cz>
References: <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz>
 <20130627153528.GA5006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627153528.GA5006@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Fri 28-06-13 00:35:28, Minchan Kim wrote:
> Hi Michal,
> 
> On Thu, Jun 27, 2013 at 11:37:21AM +0200, Michal Hocko wrote:
> > On Thu 27-06-13 15:12:10, Hyunhee Kim wrote:
> > > In vmpressure, the pressure level is calculated based on the ratio
> > > of how many pages were scanned vs. reclaimed in a given time window.
> > > However, there is a possibility that "scanned < reclaimed" in such a
> > > case, when reclaiming ends by fatal signal in shrink_inactive_list.
> > > So, with this patch, we just return "low" level when "scanned < reclaimed"
> > > happens not to have userland miss reclaim activity.
> > 
> > Hmm, fatal signal pending on kswapd doesn't make sense to me so it has
> > to be a direct reclaim path. Does it really make sense to signal LOW
> > when there is probably a big memory pressure and somebody is killing the
> > current allocator?
> 
> So, do you want to trigger critical instead of low?
> 
> Now, current is going to die so we can expect shortly we can get a amount
> of memory, normally. 

And also consider that this is per-memcg interface. And so it is even
more complicated. If a task dies then there is _no_ guarantee that there
will be an uncharge in that group (task could have been migrated to that
group so the memory belongs to somebody else).

> but yeah, we cannot sure it happens within a bounded time since it
> couldn't use reserved memory pool unlike process killed by OOM.

The situation should be detected (I am not entirely sure how - e.g.
checking for fatal_signals in vmpressure directly) but we shouldn't
assume that scanned < reclaimed has any impact on the freed memory.

> If we send critical but there isn't big memory pressure, maybe
> critical handler would kill some process and the result is that
> killing another process unnecessary. That's really thing we should
> avoid.
> 
> If we send low but there is a big memory pressure, at least, userland
> could be notified and it has a chance to release small memory, which will
> help to exit current process so that it could prevent OOM kill and killing
> another process unnecessary.
> 
> If we send low but there isn't big memory pressure, totally, we will save
> a process.
> 
> > 
> > The THP case made sense because nr_scanned is in LRU elements units
> > while nr_reclaimed is in page units which are different so nr_reclaim
> > might be higher than nr_scanned (so nr_taken would be more approapriate
> > for vmpressure).
> 
> In case of THP, 512 page is equal to vmpressure_win so if we change
> nr_scanned with nr_taken, it could easily make vmpressure notifier

Wasn't 512 selected for vmpressure_win exactly for this reason?
Shouldn't we rather fix that assumption? Comparing scanned to reclaimed
when they operate on different units just sounds strange to me.

> level critical even if VM encounter a recent referenced THP page from
> LRU tail so I'd like to ignore THP page effect in vmpressure level
> calculation.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
