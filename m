Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3165F6B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:32:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t26-v6so3877606pfh.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:32:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3-v6si5445634pla.418.2018.07.19.03.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 03:32:33 -0700 (PDT)
Date: Thu, 19 Jul 2018 12:32:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Message-ID: <20180719103229.GT7193@dhcp22.suse.cz>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
 <20180718085032.GS7193@dhcp22.suse.cz>
 <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
 <20180719071516.GK7193@dhcp22.suse.cz>
 <20180719080804.GA32756@hori1.linux.bs1.fc.nec.co.jp>
 <20180719082743.GN7193@dhcp22.suse.cz>
 <20180719092247.GB32756@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719092247.GB32756@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 19-07-18 09:22:47, Naoya Horiguchi wrote:
> On Thu, Jul 19, 2018 at 10:27:43AM +0200, Michal Hocko wrote:
> > On Thu 19-07-18 08:08:05, Naoya Horiguchi wrote:
> > > On Thu, Jul 19, 2018 at 09:15:16AM +0200, Michal Hocko wrote:
> > > > On Thu 19-07-18 06:19:45, Naoya Horiguchi wrote:
> > > > > On Wed, Jul 18, 2018 at 10:50:32AM +0200, Michal Hocko wrote:
> > [...]
> > > > > > Why do we even need HWPoison flag here? Everything can be completely
> > > > > > transparent to the application. It shouldn't fail from what I
> > > > > > understood.
> > > > > 
> > > > > PageHWPoison flag is used to the 'remove from the allocator' part
> > > > > which is like below:
> > > > > 
> > > > >   static inline
> > > > >   struct page *rmqueue(
> > > > >           ...
> > > > >           do {
> > > > >                   page = NULL;
> > > > >                   if (alloc_flags & ALLOC_HARDER) {
> > > > >                           page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> > > > >                           if (page)
> > > > >                                   trace_mm_page_alloc_zone_locked(page, order, migratetype);
> > > > >                   }
> > > > >                   if (!page)
> > > > >                           page = __rmqueue(zone, order, migratetype);
> > > > >           } while (page && check_new_pages(page, order));
> > > > > 
> > > > > check_new_pages() returns true if the page taken from free list has
> > > > > a hwpoison page so that the allocator iterates another round to get
> > > > > another page.
> > > > > 
> > > > > There's no function that can be called from outside allocator to remove
> > > > > a page in allocator.  So actual page removal is done at allocation time,
> > > > > not at error handling time. That's the reason why we need PageHWPoison.
> > > > 
> > > > hwpoison is an internal mm functionality so why cannot we simply add a
> > > > function that would do that?
> > > 
> > > That's one possible solution.
> > 
> > I would prefer that much more than add an overhead (albeit small) into
> > the page allocator directly. HWPoison should be a really rare event so
> > why should everybody pay the price? I would much rather see that the
> > poison path pays the additional price.
> 
> Yes, that's more maintainable.
> 
> > 
> > > I know about another downside in current implementation.
> > > If a hwpoison page is found during high order page allocation,
> > > all 2^order pages (not only hwpoison page) are removed from
> > > buddy because of the above quoted code. And these leaked pages
> > > are never returned to freelist even with unpoison_memory().
> > > If we have a page removal function which properly splits high order
> > > free pages into lower order pages, this problem is avoided.
> > 
> > Even more reason to move to a new scheme.
> > 
> > > OTOH PageHWPoison still has a role to report error to userspace.
> > > Without it unpoison_memory() doesn't work.
> > 
> > Sure but we do not really need a special page flag for that. We know the
> > page is not reachable other than via pfn walkers. If you make the page
> > reserved and note the fact it has been poisoned in the past then you can
> > emulate the missing functionality.
> > 
> > Btw. do we really need unpoisoning functionality? Who is really using
> > it, other than some tests?
> 
> None, as long as I know.

Then why do we keep it?

> > How does the memory become OK again?
> 
> For hard-offlined in-use pages which are assumed to be pinned,
> we clear the PageHWPoison flag and unpin the page to return it to buddy.
> For other cases, we simply clear the PageHWPoison flag.
> Unless the page is checked by check_new_pages() before unpoison,
> the page is reusable.

No I mean how does the memory becomes OK again. Is there any in place
repair technique?

> Sometimes error handling fails and the error page might turn into
> unexpected state (like additional refcount/mapcount).
> Unpoison just fails on such pages.
> 
> > Don't we
> > really need to go through physical hotremove & hotadd to clean the
> > poison status?
> 
> hotremove/hotadd can be a user of unpoison, but I think simply
> reinitializing struct pages is easiler.

Sure, that is what I meant actually. I do not really see any way to make
the memory OK again other than to replace the faulty dimm and put it
back online. The state is not really preserved for that so having a
sticky struct page state doesn't make much sense.

So from what I understood, we only need to track the poison state just
allow to hotremove that memory and do not stumble over an unexpected
page or try to do something with it. All other actions can be done
synchronously (migrate vs. kill users).
-- 
Michal Hocko
SUSE Labs
