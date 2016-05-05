Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD5CD6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 03:49:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so8148028wme.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:49:24 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id wn5si9888965wjb.196.2016.05.05.00.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 00:49:23 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so1981809wme.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:49:23 -0700 (PDT)
Date: Thu, 5 May 2016 09:49:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
Message-ID: <20160505074922.GB4386@dhcp22.suse.cz>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
 <1462309239.21143.6.camel@linux.intel.com>
 <20160504124535.GJ29978@dhcp22.suse.cz>
 <1462381986.30611.28.camel@linux.intel.com>
 <20160504194901.GG21490@dhcp22.suse.cz>
 <20160504212506.GA1364@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160504212506.GA1364@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed 04-05-16 17:25:06, Johannes Weiner wrote:
> On Wed, May 04, 2016 at 09:49:02PM +0200, Michal Hocko wrote:
> > On Wed 04-05-16 10:13:06, Tim Chen wrote:
> > In order this to work other quite intrusive changes to the current
> > reclaim decisions would have to be made though. This is what I tried to
> > say. Look at get_scan_count() on how we are making many steps to ignore
> > swappiness or prefer the page cache. Even when we make swapout scale it
> > won't help much if we do not swap out that often. That's why I claim
> > that we really should think more long term and maybe reconsider these
> > decisions which were based on the rotating rust for the swap devices.
> 
> While I agree that such balancing rework is necessary to make swap
> perform optimally, I don't see why this would be a dependency for
> making the mechanical swapout paths a lot leaner.

Ohh, I didn't say this would be a dependency. I am all for preparing
the code for a better scaling I just felt that the patch is quite large
with a small benefit at this moment and the initial description was not
very clear about the motivation and changes seemed to be shaped by an
artificial test case.

> I'm actually working on improving the LRU balancing decisions for fast
> random IO swap devices, and hope to have something to submit soon.

That is really good to hear!

> > > I understand that the patch set is a little large. Any better
> > > ideas for achieving similar ends will be appreciated.  I put
> > > out these patches in the hope that it will spur solutions
> > > to improve swap.
> > > 
> > > Perhaps the first two patches to make shrink_page_list into
> > > smaller components can be considered first, as a first step 
> > > to make any changes to the reclaim code easier.
> 
> It makes sense that we need to batch swap allocation and swap cache
> operations. Unfortunately, the patches as they stand turn
> shrink_page_list() into an unreadable mess. This would need better
> refactoring before considering them for upstream merging. The swap
> allocation batching should not obfuscate the main sequence of events
> that is happening for both file-backed and anonymous pages.

That was my first impression as well but to be fair I only skimmed
through the patch so I might be just biased by the size.

> It'd also be great if the remove_mapping() batching could be done
> universally for all pages, given that in many cases file pages from
> the same inode also cluster together on the LRU.

Agreed!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
