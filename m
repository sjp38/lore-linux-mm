Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 482B36B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 13:13:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so118237532pfw.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 10:13:08 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id p67si5707689pfi.167.2016.05.04.10.13.07
        for <linux-mm@kvack.org>;
        Wed, 04 May 2016 10:13:07 -0700 (PDT)
Message-ID: <1462381986.30611.28.camel@linux.intel.com>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 04 May 2016 10:13:06 -0700
In-Reply-To: <20160504124535.GJ29978@dhcp22.suse.cz>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
	 <1462309239.21143.6.camel@linux.intel.com>
	 <20160504124535.GJ29978@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, 2016-05-04 at 14:45 +0200, Michal Hocko wrote:
> On Tue 03-05-16 14:00:39, Tim Chen wrote:
> [...]
> > 
> > A include/linux/swap.h |A A 29 ++-
> > A mm/swap_state.cA A A A A A | 253 +++++++++++++-----
> > A mm/swapfile.cA A A A A A A A | 215 +++++++++++++--
> > A mm/vmscan.cA A A A A A A A A A | 725 ++++++++++++++++++++++++++++++++++++++-
> > ------------
> > A 4 files changed, 945 insertions(+), 277 deletions(-)
> This is rather large change for a normally rare path. We have been
> trying to preserve the anonymous memory as much as possible and
> rather
> push the page cache out. In fact swappiness is ignored most of the
> time for the vast majority of workloads.
> 
> So this would help anonymous mostly workloads and I am really
> wondering
> whether this is something worth bothering without further and deeper
> rethinking of our current reclaim strategy. I fully realize that the
> swap out sucks and that the new storage technologies might change the
> way how we think about anonymous memory being so "special" wrt. disk
> based caches but I would like to see a stronger use case than "we
> have
> been playing with some artificial use case and it scales better"

With non-volatile ram based block devices, swap device could be very
fast, approaching RAM speed and can potentially be used as a secondary
memory. Just configuring these NVRAM as swap will be
an easy way for apps to make use of them without doing any heavy
lifting to change the apps. A But the swap path is soA 
un-scalable today that such use case
is unfeasible, even more so for multi-threaded server machines.

I understand that the patch set is a little large. Any better
ideas for achieving similar ends will be appreciated. A I put
out these patches in the hope that it will spur solutions
to improve swap.

Perhaps the first two patches to make shrink_page_list into
smaller components can be considered first, as a first stepA 
to make any changes to the reclaim code easier.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
