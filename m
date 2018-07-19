Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C39096B0266
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:27:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21-v6so2978294eds.2
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:27:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11-v6si5719061edk.204.2018.07.19.01.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:27:45 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:27:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Message-ID: <20180719082743.GN7193@dhcp22.suse.cz>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
 <20180718085032.GS7193@dhcp22.suse.cz>
 <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
 <20180719071516.GK7193@dhcp22.suse.cz>
 <20180719080804.GA32756@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719080804.GA32756@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 19-07-18 08:08:05, Naoya Horiguchi wrote:
> On Thu, Jul 19, 2018 at 09:15:16AM +0200, Michal Hocko wrote:
> > On Thu 19-07-18 06:19:45, Naoya Horiguchi wrote:
> > > On Wed, Jul 18, 2018 at 10:50:32AM +0200, Michal Hocko wrote:
[...]
> > > > Why do we even need HWPoison flag here? Everything can be completely
> > > > transparent to the application. It shouldn't fail from what I
> > > > understood.
> > > 
> > > PageHWPoison flag is used to the 'remove from the allocator' part
> > > which is like below:
> > > 
> > >   static inline
> > >   struct page *rmqueue(
> > >           ...
> > >           do {
> > >                   page = NULL;
> > >                   if (alloc_flags & ALLOC_HARDER) {
> > >                           page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> > >                           if (page)
> > >                                   trace_mm_page_alloc_zone_locked(page, order, migratetype);
> > >                   }
> > >                   if (!page)
> > >                           page = __rmqueue(zone, order, migratetype);
> > >           } while (page && check_new_pages(page, order));
> > > 
> > > check_new_pages() returns true if the page taken from free list has
> > > a hwpoison page so that the allocator iterates another round to get
> > > another page.
> > > 
> > > There's no function that can be called from outside allocator to remove
> > > a page in allocator.  So actual page removal is done at allocation time,
> > > not at error handling time. That's the reason why we need PageHWPoison.
> > 
> > hwpoison is an internal mm functionality so why cannot we simply add a
> > function that would do that?
> 
> That's one possible solution.

I would prefer that much more than add an overhead (albeit small) into
the page allocator directly. HWPoison should be a really rare event so
why should everybody pay the price? I would much rather see that the
poison path pays the additional price.

> I know about another downside in current implementation.
> If a hwpoison page is found during high order page allocation,
> all 2^order pages (not only hwpoison page) are removed from
> buddy because of the above quoted code. And these leaked pages
> are never returned to freelist even with unpoison_memory().
> If we have a page removal function which properly splits high order
> free pages into lower order pages, this problem is avoided.

Even more reason to move to a new scheme.

> OTOH PageHWPoison still has a role to report error to userspace.
> Without it unpoison_memory() doesn't work.

Sure but we do not really need a special page flag for that. We know the
page is not reachable other than via pfn walkers. If you make the page
reserved and note the fact it has been poisoned in the past then you can
emulate the missing functionality.

Btw. do we really need unpoisoning functionality? Who is really using
it, other than some tests? How does the memory become OK again? Don't we
really need to go through physical hotremove & hotadd to clean the
poison status?

Thanks!
-- 
Michal Hocko
SUSE Labs
