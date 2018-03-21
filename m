Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A57A26B0006
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:51:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p10so1920170pfl.22
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:51:20 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o33-v6si2781271plb.429.2018.03.20.18.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 18:51:19 -0700 (PDT)
Date: Wed, 21 Mar 2018 09:52:23 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 3/4] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20180321015223.GA28705@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-4-aaron.lu@intel.com>
 <CAF7GXvpzgc0vsJemUYQPhPFte8b8a4nBFo=iwZBTdM1Y2eoHYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF7GXvpzgc0vsJemUYQPhPFte8b8a4nBFo=iwZBTdM1Y2eoHYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Tue, Mar 20, 2018 at 03:29:33PM -0700, Figo.zhang wrote:
> 2018-03-20 1:54 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:
> 
> > Profile on Intel Skylake server shows the most time consuming part
> > under zone->lock on allocation path is accessing those to-be-returned
> > page's "struct page" on the free_list inside zone->lock. One explanation
> > is, different CPUs are releasing pages to the head of free_list and
> > those page's 'struct page' may very well be cache cold for the allocating
> > CPU when it grabs these pages from free_list' head. The purpose here
> > is to avoid touching these pages one by one inside zone->lock.
> >
> > One idea is, we just take the requested number of pages off free_list
> > with something like list_cut_position() and then adjust nr_free of
> > free_area accordingly inside zone->lock and other operations like
> > clearing PageBuddy flag for these pages are done outside of zone->lock.
> >
> 
> sounds good!
> your idea is reducing the lock contention in rmqueue_bulk() function by

Right, the idea is to reduce the lock held time.

> split the order-0
> freelist into two list, one is without zone->lock, other is need zone->lock?

But not by splitting freelist into two lists, I didn't do that.
I moved part of the things done previously inside the lock outside, i.e.
clearing PageBuddy flag etc. is now done outside so that we do not need
to take the penalty of cache miss on those "struct page"s inside the
lock and have all other CPUs waiting.

> 
> it seems that it is a big lock granularity holding the zone->lock in
> rmqueue_bulk() ,
> why not we change like it?

It is believed frequently taking and dropping lock is worse than taking
it and do all needed things and then drop.

> 
> static int rmqueue_bulk(struct zone *zone, unsigned int order,
>             unsigned long count, struct list_head *list,
>             int migratetype, bool cold)
> {
> 
>     for (i = 0; i < count; ++i) {
>         spin_lock(&zone->lock);
>         struct page *page = __rmqueue(zone, order, migratetype);
>        spin_unlock(&zone->lock);
>        ...
>     }

In this case, spin_lock() and spin_unlock() should be outside the loop.

>     __mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> 
>     return i;
> }
