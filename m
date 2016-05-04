Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 012286B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 17:27:17 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so53049357lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 14:27:16 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u188si7622659wmb.4.2016.05.04.14.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 14:27:15 -0700 (PDT)
Date: Wed, 4 May 2016 17:25:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
Message-ID: <20160504212506.GA1364@cmpxchg.org>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
 <1462309239.21143.6.camel@linux.intel.com>
 <20160504124535.GJ29978@dhcp22.suse.cz>
 <1462381986.30611.28.camel@linux.intel.com>
 <20160504194901.GG21490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160504194901.GG21490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, May 04, 2016 at 09:49:02PM +0200, Michal Hocko wrote:
> On Wed 04-05-16 10:13:06, Tim Chen wrote:
> In order this to work other quite intrusive changes to the current
> reclaim decisions would have to be made though. This is what I tried to
> say. Look at get_scan_count() on how we are making many steps to ignore
> swappiness or prefer the page cache. Even when we make swapout scale it
> won't help much if we do not swap out that often. That's why I claim
> that we really should think more long term and maybe reconsider these
> decisions which were based on the rotating rust for the swap devices.

While I agree that such balancing rework is necessary to make swap
perform optimally, I don't see why this would be a dependency for
making the mechanical swapout paths a lot leaner.

I'm actually working on improving the LRU balancing decisions for fast
random IO swap devices, and hope to have something to submit soon.

> > I understand that the patch set is a little large. Any better
> > ideas for achieving similar ends will be appreciated.  I put
> > out these patches in the hope that it will spur solutions
> > to improve swap.
> > 
> > Perhaps the first two patches to make shrink_page_list into
> > smaller components can be considered first, as a first step 
> > to make any changes to the reclaim code easier.

It makes sense that we need to batch swap allocation and swap cache
operations. Unfortunately, the patches as they stand turn
shrink_page_list() into an unreadable mess. This would need better
refactoring before considering them for upstream merging. The swap
allocation batching should not obfuscate the main sequence of events
that is happening for both file-backed and anonymous pages.

It'd also be great if the remove_mapping() batching could be done
universally for all pages, given that in many cases file pages from
the same inode also cluster together on the LRU.

I realize this is fairly vague feedback; I'll try to take a closer
look at the patches. But I do think this work is going in the right
direction and there is plenty of justification for making these paths
more efficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
