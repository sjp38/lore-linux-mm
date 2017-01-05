Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 915326B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:27:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so87842450wmu.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:27:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 80si81173438wmy.107.2017.01.05.02.27.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:27:25 -0800 (PST)
Date: Thu, 5 Jan 2017 11:27:22 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
Message-ID: <20170105102722.GH21618@dhcp22.suse.cz>
References: <20161230131412.GI13301@dhcp22.suse.cz>
 <20161230140651.nud2ozpmvmziqyx4@suse.de>
 <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 05-01-17 10:53:59, Vlastimil Babka wrote:
> [CC Joonsoo and Johannes]
> 
> On 12/30/2016 03:06 PM, Mel Gorman wrote:
> > On Fri, Dec 30, 2016 at 02:14:12PM +0100, Michal Hocko wrote:
> >> Hi,
> >> I didn't originally want to send this proposal because Vlastimil is
> >> planning to do some work in this area so I've expected him to send
> >> something similar. But the recent discussion about the THP defrag
> >> options pushed me to send out my thoughts.
> 
> No problem.
> 
> >> So what is the problem? The demand for high order pages is growing and
> >> that seems to be the general trend. The problem is that while they can
> >> bring performance benefit they can get be really expensive to allocate
> >> especially when we enter the direct compaction. So we really want to
> >> prevent from expensive path and defer as much as possible to the
> >> background. A huge step forward was kcompactd introduced by Vlastimil.
> >> We are still not there yet though, because it might be already quite
> >> late when we wakeup_kcompactd(). The memory might be already fragmented
> >> when we hit there.
> 
> Right.
> 
> >> Moreover we do not have any way to actually tell
> >> which orders we do care about.
> 
> Who is "we" here? The system admin?

yes

> >> Therefore I believe we need a watermark based pro-active compaction
> >> which would keep the background compaction busy as long as we have
> >> less pages of the configured order.
> 
> Again, configured by what, admin? I would rather try to avoid tunables
> here, if possible. While THP is quite well known example with stable
> order, the pressure for other orders is rather implementation specific
> (drivers, SLAB/SLUB) and may change with kernel versions (e.g. virtually
> mapped stacks, although that example is about non-costly order). Would
> the admin be expected to study the implementation to know which orders
> are needed, or react to page allocation failure reports? Neither sounds
> nice.

That is a good question but I expect that there are more users than THP
which use stable orders. E.g. networking stack tends to depend on the
packet size. A tracepoint with some histogram output would tell us what
is the requested orders distribution.

> >> kcompactd should wake up
> >> periodically, I think, and check for the status so that we can catch
> >> the fragmentation before we get low on memory.
> >> The interface could look something like:
> >> /proc/sys/vm/compact_wmark
> >> time_period order count
> 
> IMHO it would be better if the system could auto-tune this, e.g. by
> counting high-order alloc failures/needs for direct compaction per order
> between wakeups, and trying to bring them to zero.

auto-tunning is usually preferable I am just wondering how the admin can
tell what is still the system load price he is willing to pay. I suspect
we will see growing number of opportunistic high order requests over
time and  auto tunning shouldn't try to accomodate with it without
any bounds. There is still some cost/benefit to be evaluated from the
system level point of view which I am afraid is hard to achive from the
kcompactd POV.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
