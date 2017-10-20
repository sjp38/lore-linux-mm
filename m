Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27E816B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:17:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so4563345wmu.19
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:17:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si525093wmc.46.2017.10.20.01.17.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 01:17:05 -0700 (PDT)
Date: Fri, 20 Oct 2017 10:17:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171020081700.fec53qxieeqouhwi@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
 <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <59E9A426.5070009@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59E9A426.5070009@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 20-10-17 15:22:14, Xishi Qiu wrote:
> On 2017/10/20 10:13, Joonsoo Kim wrote:
> 
> > On Thu, Oct 19, 2017 at 02:21:18PM +0200, Michal Hocko wrote:
[...]
> >> >From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
> >> From: Michal Hocko <mhocko@suse.com>
> >> Date: Thu, 19 Oct 2017 14:14:02 +0200
> >> Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
> >>  has_unmovable_pages
> >>
> >> Joonsoo has noticed that "mm: drop migrate type checks from
> >> has_unmovable_pages" would break CMA allocator because it relies on
> >> has_unmovable_pages returning false even for CMA pageblocks which in
> >> fact don't have to be movable:
> >> alloc_contig_range
> >>   start_isolate_page_range
> >>     set_migratetype_isolate
> >>       has_unmovable_pages
> >>
> >> This is a result of the code sharing between CMA and memory hotplug
> >> while each one has a different idea of what has_unmovable_pages should
> >> return. This is unfortunate but fixing it properly would require a lot
> >> of code duplication.
> >>
> >> Fix the issue by introducing the requested migrate type argument
> >> and special case MIGRATE_CMA case where CMA page blocks are handled
> >> properly. This will work for memory hotplug because it requires
> >> MIGRATE_MOVABLE.
> > 
> > Unfortunately, alloc_contig_range() can be called with
> > MIGRATE_MOVABLE so this patch cannot perfectly fix the problem.
> > 
> > I did a more thinking and found that it's strange to check if there is
> > unmovable page in the pageblock during the set_migratetype_isolate().
> > set_migratetype_isolate() should be just for setting the migratetype
> > of the pageblock. Checking other things should be done by another
> > place, for example, before calling the start_isolate_page_range() in
> > __offline_pages().
> > 
> > Thanks.
> > 
> 
> Hi Joonsoo,
> 
> How about add a flag to skip or not has_unmovable_pages() in set_migratetype_isolate()?
> Something like the skip_hwpoisoned_pages.

I believe this is what Joonsoo was proposing actually. I cannot say I
would like skip_hwpoisoned_pages and adding one more flag is just too
ugly. So I would prefer to have something that would actually make sense
from the semantic POV. If CMA really needs to work with partial CMA
blocks then MIGRATE_CMA as an indicator sounds like the right way to go
to me. But I am not a CMA expert so I might be missing some subtlety
here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
