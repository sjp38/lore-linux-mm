Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 551426B0253
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 07:17:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n85so50265308pfi.7
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 04:17:37 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id t25si2292555pge.118.2016.10.21.04.17.35
        for <linux-mm@kvack.org>;
        Fri, 21 Oct 2016 04:17:36 -0700 (PDT)
Date: Fri, 21 Oct 2016 22:17:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
Message-ID: <20161021111732.GR14023@dastard>
References: <20161020121149.9935-1-vbabka@suse.cz>
 <20161020133358.GN14609@dhcp22.suse.cz>
 <20161020225929.GP23194@dastard>
 <70fe5da3-c739-58ce-0531-299b48e0ca9e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70fe5da3-c739-58ce-0531-299b48e0ca9e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Fri, Oct 21, 2016 at 09:25:10AM +0200, Vlastimil Babka wrote:
> On 10/21/2016 12:59 AM, Dave Chinner wrote:
> >On Thu, Oct 20, 2016 at 03:33:58PM +0200, Michal Hocko wrote:
> >>On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
> >>[...]
> >>> Hi, I'm wondering if people would find this useful. If you think it is, and
> >>> to not make performance worse, I could also make sure in proper submission
> >>> that values are not read via global_page_state() multiple times etc...
> >>
> >>I definitely find this information useful and hate to do the math all
> >>the time but on the other hand this is quite fragile and I can imagine
> >>we can easily forget to add something there and provide a misleading
> >>information to the userspace. So I would be worried with a long term
> >>maintainability of this.
> >
> >This will result in valid memory usage by subsystems like the XFS
> >buffer cache being reported as "unaccounted". Given this cache
> >(whose size is shrinker controlled) can grow to gigabytes in size
> >under various metadata intensive workloads, there's every chance
> >that such reporting will make users incorrectly think they have a
> >massive memory leak....
> 
> Is the XFS buffer cache accounted (and visible) somewhere then? I'd
> say getting such large consumers to become visible on the same level
> as others would be another advantage...

It's handles are visible via the xfs_buf slab cache. By the time
you've got enough memory in the buffer cache for it to be noticed,
the xfs_buf slab is near the top of the list in slabtop.

Of course, because of the crazy way slub names caches, this can be
impossible to find because there isn't a "xfs_buf" slab cache that
shows up in slabtop. It'll end being called something like
"mnt_cache"....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
