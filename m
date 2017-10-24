Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4716C6B025F
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 00:40:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so13351347pgu.22
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 21:40:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e8si6399483pfd.331.2017.10.23.21.40.27
        for <linux-mm@kvack.org>;
        Mon, 23 Oct 2017 21:40:29 -0700 (PDT)
Date: Tue, 24 Oct 2017 13:44:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171024044423.GA31424@js1304-P5Q-DELUXE>
References: <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <20171020055922.x2mj6j66obmp52da@dhcp22.suse.cz>
 <20171020065014.GA11145@js1304-P5Q-DELUXE>
 <20171020070220.t4o573zymgto5kmi@dhcp22.suse.cz>
 <20171023052309.GB23082@js1304-P5Q-DELUXE>
 <20171023081009.7fyz3gfrmurvj635@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023081009.7fyz3gfrmurvj635@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 23, 2017 at 10:10:09AM +0200, Michal Hocko wrote:
> On Mon 23-10-17 14:23:09, Joonsoo Kim wrote:
> > On Fri, Oct 20, 2017 at 09:02:20AM +0200, Michal Hocko wrote:
> > > On Fri 20-10-17 15:50:14, Joonsoo Kim wrote:
> > > > On Fri, Oct 20, 2017 at 07:59:22AM +0200, Michal Hocko wrote:
> > > > > On Fri 20-10-17 11:13:29, Joonsoo Kim wrote:
> > > > > > On Thu, Oct 19, 2017 at 02:21:18PM +0200, Michal Hocko wrote:
> > > > > > > On Thu 19-10-17 10:20:41, Michal Hocko wrote:
> > > > > > > > On Thu 19-10-17 16:33:56, Joonsoo Kim wrote:
> > > > > > > > > On Thu, Oct 19, 2017 at 09:15:03AM +0200, Michal Hocko wrote:
> > > > > > > > > > On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
> > > > > > > > [...]
> > > > > > > > > > > Hello,
> > > > > > > > > > > 
> > > > > > > > > > > This patch will break the CMA user. As you mentioned, CMA allocation
> > > > > > > > > > > itself isn't migrateable. So, after a single page is allocated through
> > > > > > > > > > > CMA allocation, has_unmovable_pages() will return true for this
> > > > > > > > > > > pageblock. Then, futher CMA allocation request to this pageblock will
> > > > > > > > > > > fail because it requires isolating the pageblock.
> > > > > > > > > > 
> > > > > > > > > > Hmm, does this mean that the CMA allocation path depends on
> > > > > > > > > > has_unmovable_pages to return false here even though the memory is not
> > > > > > > > > > movable? This sounds really strange to me and kind of abuse of this
> > > > > > > > > 
> > > > > > > > > Your understanding is correct. Perhaps, abuse or wrong function name.
> > > > > > > > >
> > > > > > > > > > function. Which path is that? Can we do the migrate type test theres?
> > > > > > > > > 
> > > > > > > > > alloc_contig_range() -> start_isolate_page_range() ->
> > > > > > > > > set_migratetype_isolate() -> has_unmovable_pages()
> > > > > > > > 
> > > > > > > > I see. It seems that the CMA and memory hotplug have a very different
> > > > > > > > view on what should happen during isolation.
> > > > > > > >  
> > > > > > > > > We can add one argument, 'XXX' to set_migratetype_isolate() and change
> > > > > > > > > it to check migrate type rather than has_unmovable_pages() if 'XXX' is
> > > > > > > > > specified.
> > > > > > > > 
> > > > > > > > Can we use the migratetype argument and do the special thing for
> > > > > > > > MIGRATE_CMA? Like the following diff?
> > > > > > > 
> > > > > > > And with the full changelog.
> > > > > > > ---
> > > > > > > >From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
> > > > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > > > Date: Thu, 19 Oct 2017 14:14:02 +0200
> > > > > > > Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
> > > > > > >  has_unmovable_pages
> > > > > > > 
> > > > > > > Joonsoo has noticed that "mm: drop migrate type checks from
> > > > > > > has_unmovable_pages" would break CMA allocator because it relies on
> > > > > > > has_unmovable_pages returning false even for CMA pageblocks which in
> > > > > > > fact don't have to be movable:
> > > > > > > alloc_contig_range
> > > > > > >   start_isolate_page_range
> > > > > > >     set_migratetype_isolate
> > > > > > >       has_unmovable_pages
> > > > > > > 
> > > > > > > This is a result of the code sharing between CMA and memory hotplug
> > > > > > > while each one has a different idea of what has_unmovable_pages should
> > > > > > > return. This is unfortunate but fixing it properly would require a lot
> > > > > > > of code duplication.
> > > > > > > 
> > > > > > > Fix the issue by introducing the requested migrate type argument
> > > > > > > and special case MIGRATE_CMA case where CMA page blocks are handled
> > > > > > > properly. This will work for memory hotplug because it requires
> > > > > > > MIGRATE_MOVABLE.
> > > > > > 
> > > > > > Unfortunately, alloc_contig_range() can be called with
> > > > > > MIGRATE_MOVABLE so this patch cannot perfectly fix the problem.
> > > > > 
> > > > > Yes, alloc_contig_range can be called with MIGRATE_MOVABLE but my
> > > > > understanding is that only CMA allocator really depends on this weird
> > > > > semantic and that does MIGRATE_CMA unconditionally.
> > > > 
> > > > alloc_contig_range() could be called for partial pages in the
> > > > pageblock. With your patch, this case also fails unnecessarilly if the
> > > > other pages in the pageblock is pinned.
> > > 
> > > Is this really the case for GB pages? Do we really want to mess those
> > 
> > No, but, as I mentioned already, this API can be called with less
> > pages. I know that there is no user with less pages at this moment but
> > I cannot see any point to reduce this API's capability.
> 
> I am still confused. So when exactly would you want to use this api for
> MIGRATE_MOVABLE and use a partial MIGRATE_CMA pageblock?
> 
> > > with CMA blocks and make those blocks basically unusable because GB
> > > pages are rarely (if at all migrateable)?
> > > 
> > > > Until now, there is no user calling alloc_contig_range() with partial
> > > > pages except CMA allocator but API could support it.
> > > 
> > > I disagree. If this is a CMA thing it should stay that way. The semantic
> > > is quite confusing already, please let's not make it even worse.
> > 
> > It is already used by other component.
> > 
> > I'm not sure what is the confusing semantic you mentioned. I think
> > that set_migratetype_isolate() has confusing semantic and should be
> > fixed since making the pageblock isolated doesn't need to check if
> > there is unmovable page or not. Do you think that
> > set_migratetype_isolate() need to check it? If so, why?
> 
> My intuitive understanding of set_migratetype_isolate is that it either
> suceeds and that means that the given pfn range can be isolated for the
> given type of allocation (be it movable or cma). No new pages will be
> allocated from this range to allow converging into a free range in a
> finit amount of time. At least this is how the hotplug code would like
> to use it and I suppose that the alloc_contig_range would like to
> guarantee the same to not rely on a fixed amount of migration attempts.

Yes, alloc_contig_range() also want to guarantee the similar thing.
Major difference between them is 'given pfn range'. memory hotplug
works by pageblock unit but alloc_contig_range() doesn't.
alloc_contig_range() works by the page unit. However, there is no easy
way to isolate individual page so it uses pageblock isolation
regardless of 'given pfn range'. In this case, checking movability of
all pages on the pageblock would cause the problem as I mentioned
before.

> 
> > > > > > I did a more thinking and found that it's strange to check if there is
> > > > > > unmovable page in the pageblock during the set_migratetype_isolate().
> > > > > > set_migratetype_isolate() should be just for setting the migratetype
> > > > > > of the pageblock. Checking other things should be done by another
> > > > > > place, for example, before calling the start_isolate_page_range() in
> > > > > > __offline_pages().
> > > > > 
> > > > > How do we guarantee the atomicity?
> > > > 
> > > > What atomicity do you mean?
> > > 
> > > Currently we are checking and isolating pages under zone lock. If we
> > > split that we are losing atomicity, aren't we.
> > 
> > I think that it can be done easily.
> > 
> > set_migratetype_isolate() {
> >         lock
> >         __set_migratetype_isolate();
> >         unlock
> > }
> > 
> > set_migratetype_isolate_if_no_unmovable_pages() {
> >         lock
> >         if (has_unmovable_pages())
> >                 fail
> >         else
> >                 __set_migratetype_isolate()
> >         unlock
> > }
> 
> So you are essentially suggesting to split the API for
> alloc_contig_range and hotplug users? Care to send a patch? It is not
> like I would really love this but I would really like to have this issue
> addressed because I really do want all other patches which depend on
> this to be merged in the next release cycle.
> 
> That being said, I would much rather see MIGRATE_CMA case special cased
> than duplicate the already confusing API but I will not insist of
> course.

Okay. I atteach the patch. Andrew, could you revert Michal's series
and apply this patch first? Perhaps, Michal will resend his series on
top of this one.

Thanks.


--------------->8-------------------
