Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 814486B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:02:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v78so8918329pfk.8
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 00:02:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q61si265342plb.218.2017.10.20.00.02.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 00:02:24 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:02:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171020070220.t4o573zymgto5kmi@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
 <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <20171020055922.x2mj6j66obmp52da@dhcp22.suse.cz>
 <20171020065014.GA11145@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020065014.GA11145@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 20-10-17 15:50:14, Joonsoo Kim wrote:
> On Fri, Oct 20, 2017 at 07:59:22AM +0200, Michal Hocko wrote:
> > On Fri 20-10-17 11:13:29, Joonsoo Kim wrote:
> > > On Thu, Oct 19, 2017 at 02:21:18PM +0200, Michal Hocko wrote:
> > > > On Thu 19-10-17 10:20:41, Michal Hocko wrote:
> > > > > On Thu 19-10-17 16:33:56, Joonsoo Kim wrote:
> > > > > > On Thu, Oct 19, 2017 at 09:15:03AM +0200, Michal Hocko wrote:
> > > > > > > On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
> > > > > [...]
> > > > > > > > Hello,
> > > > > > > > 
> > > > > > > > This patch will break the CMA user. As you mentioned, CMA allocation
> > > > > > > > itself isn't migrateable. So, after a single page is allocated through
> > > > > > > > CMA allocation, has_unmovable_pages() will return true for this
> > > > > > > > pageblock. Then, futher CMA allocation request to this pageblock will
> > > > > > > > fail because it requires isolating the pageblock.
> > > > > > > 
> > > > > > > Hmm, does this mean that the CMA allocation path depends on
> > > > > > > has_unmovable_pages to return false here even though the memory is not
> > > > > > > movable? This sounds really strange to me and kind of abuse of this
> > > > > > 
> > > > > > Your understanding is correct. Perhaps, abuse or wrong function name.
> > > > > >
> > > > > > > function. Which path is that? Can we do the migrate type test theres?
> > > > > > 
> > > > > > alloc_contig_range() -> start_isolate_page_range() ->
> > > > > > set_migratetype_isolate() -> has_unmovable_pages()
> > > > > 
> > > > > I see. It seems that the CMA and memory hotplug have a very different
> > > > > view on what should happen during isolation.
> > > > >  
> > > > > > We can add one argument, 'XXX' to set_migratetype_isolate() and change
> > > > > > it to check migrate type rather than has_unmovable_pages() if 'XXX' is
> > > > > > specified.
> > > > > 
> > > > > Can we use the migratetype argument and do the special thing for
> > > > > MIGRATE_CMA? Like the following diff?
> > > > 
> > > > And with the full changelog.
> > > > ---
> > > > >From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > Date: Thu, 19 Oct 2017 14:14:02 +0200
> > > > Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
> > > >  has_unmovable_pages
> > > > 
> > > > Joonsoo has noticed that "mm: drop migrate type checks from
> > > > has_unmovable_pages" would break CMA allocator because it relies on
> > > > has_unmovable_pages returning false even for CMA pageblocks which in
> > > > fact don't have to be movable:
> > > > alloc_contig_range
> > > >   start_isolate_page_range
> > > >     set_migratetype_isolate
> > > >       has_unmovable_pages
> > > > 
> > > > This is a result of the code sharing between CMA and memory hotplug
> > > > while each one has a different idea of what has_unmovable_pages should
> > > > return. This is unfortunate but fixing it properly would require a lot
> > > > of code duplication.
> > > > 
> > > > Fix the issue by introducing the requested migrate type argument
> > > > and special case MIGRATE_CMA case where CMA page blocks are handled
> > > > properly. This will work for memory hotplug because it requires
> > > > MIGRATE_MOVABLE.
> > > 
> > > Unfortunately, alloc_contig_range() can be called with
> > > MIGRATE_MOVABLE so this patch cannot perfectly fix the problem.
> > 
> > Yes, alloc_contig_range can be called with MIGRATE_MOVABLE but my
> > understanding is that only CMA allocator really depends on this weird
> > semantic and that does MIGRATE_CMA unconditionally.
> 
> alloc_contig_range() could be called for partial pages in the
> pageblock. With your patch, this case also fails unnecessarilly if the
> other pages in the pageblock is pinned.

Is this really the case for GB pages? Do we really want to mess those
with CMA blocks and make those blocks basically unusable because GB
pages are rarely (if at all migrateable)?

> Until now, there is no user calling alloc_contig_range() with partial
> pages except CMA allocator but API could support it.

I disagree. If this is a CMA thing it should stay that way. The semantic
is quite confusing already, please let's not make it even worse.

> > > I did a more thinking and found that it's strange to check if there is
> > > unmovable page in the pageblock during the set_migratetype_isolate().
> > > set_migratetype_isolate() should be just for setting the migratetype
> > > of the pageblock. Checking other things should be done by another
> > > place, for example, before calling the start_isolate_page_range() in
> > > __offline_pages().
> > 
> > How do we guarantee the atomicity?
> 
> What atomicity do you mean?

Currently we are checking and isolating pages under zone lock. If we
split that we are losing atomicity, aren't we.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
