Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADF516B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 05:28:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u18so18137904wrc.17
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 02:28:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8si15202323wmd.88.2017.04.18.02.28.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 02:28:02 -0700 (PDT)
Date: Tue, 18 Apr 2017 11:27:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: consider zone which is not fully populated to
 have holes
Message-ID: <20170418092757.GM22360@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170415121734.6692-2-mhocko@kernel.org>
 <97a658cd-e656-6efa-7725-150063d276f1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97a658cd-e656-6efa-7725-150063d276f1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 18-04-17 10:45:23, Vlastimil Babka wrote:
> On 04/15/2017 02:17 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __pageblock_pfn_to_page has two users currently, set_zone_contiguous
> > which checks whether the given zone contains holes and
> > pageblock_pfn_to_page which then carefully returns a first valid
> > page from the given pfn range for the given zone. This doesn't handle
> > zones which are not fully populated though. Memory pageblocks can be
> > offlined or might not have been onlined yet. In such a case the zone
> > should be considered to have holes otherwise pfn walkers can touch
> > and play with offline pages.
> > 
> > Current callers of pageblock_pfn_to_page in compaction seem to work
> > properly right now because they only isolate PageBuddy
> > (isolate_freepages_block) or PageLRU resp. __PageMovable
> > (isolate_migratepages_block) which will be always false for these pages.
> > It would be safer to skip these pages altogether, though. In order
> > to do that let's check PageReserved in __pageblock_pfn_to_page because
> > offline pages are reserved.
> 
> My issue with this is that PageReserved can be also set for other
> reasons than offlined block, e.g. by a random driver. So there are two
> suboptimal scenarios:
> 
> - PageReserved is set on some page in the middle of pageblock. It won't
> be detected by this patch. This violates the "it would be safer" argument.
> - PageReserved is set on just the first (few) page(s) and because of
> this patch, we skip it completely and won't compact the rest of it.

Why would that be a big problem? PageReserved is used only very seldom
and few page blocks skipped would seem like a minor issue to me.

> So if we decide we really need to check PageReserved to ensure safety,
> then we have to check it on each page. But I hope the existing criteria
> in compaction scanners are sufficient. Unless the semantic is that if
> somebody sets PageReserved, he's free to repurpose the rest of flags at
> his will (IMHO that's not the case).

I am not aware of any such user. PageReserved has always been about "the
core mm should touch these pages and modify their state" AFAIR.
But I believe that touching those holes just asks for problems so I
would rather have them covered.

> The pageblock-level check them becomes a performance optimization so
> when there's an "offline hole", compaction won't iterate it page by
> page. But the downside is the false positive resulting in skipping whole
> pageblock due to single page.
> I guess it's uncommon for a longlived offline holes to exist, so we
> could simply just drop this?

This is hard to tell but I can imagine that some memory hotplug
balloning drivers might want to offline hole into existing zones. 
 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 0cacba69ab04..dcbbcfdda60e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1351,6 +1351,8 @@ struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
> >  		return NULL;
> >  
> >  	start_page = pfn_to_page(start_pfn);
> > +	if (PageReserved(start_page))
> > +		return NULL;
> >  
> >  	if (page_zone(start_page) != zone)
> >  		return NULL;
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
