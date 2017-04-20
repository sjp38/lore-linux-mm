Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B56952806DB
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 03:28:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n5so4676917wrb.7
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 00:28:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si7752381wrv.67.2017.04.20.00.28.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 00:28:24 -0700 (PDT)
Date: Thu, 20 Apr 2017 09:28:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: your mail
Message-ID: <20170420072820.GB15781@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170415121734.6692-1-mhocko@kernel.org>
 <20170417054718.GD1351@js1304-desktop>
 <20170417081513.GA12511@dhcp22.suse.cz>
 <20170420012753.GA22054@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170420012753.GA22054@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-04-17 10:27:55, Joonsoo Kim wrote:
> On Mon, Apr 17, 2017 at 10:15:15AM +0200, Michal Hocko wrote:
[...]
> > Which pfn walkers you have in mind?
> 
> For example, kpagecount_read() in fs/proc/page.c. I searched it by
> using pfn_valid().

Yeah, I've checked that one and in fact this is a good example of the
case where you do not really care about holes. It just checks the page
count which is a valid information under any circumstances.

> > > The other problem I found is that your change will makes some
> > > contiguous zones to be considered as non-contiguous. Memory allocated
> > > by memblock API is also marked as PageResereved. If we consider this as
> > > a hole, we will set such a zone as non-contiguous.
> > 
> > Why would that be a problem? We shouldn't touch those pages anyway?
> 
> Skipping those pages in compaction are valid so no problem in this
> case.
> 
> The problem I mentioned above is that adding PageReserved() check in
> __pageblock_pfn_to_page() invalidates optimization by
> set_zone_contiguous(). In compaction, we need to get a valid struct
> page and it requires a lot of work. There is performance problem
> report due to this so set_zone_contiguous() optimization is added. It
> checks if the zone is contiguous or not in boot time. If zone is
> determined as contiguous, we can easily get a valid struct page in
> runtime without expensive checks.

OK, I see. I've had some vague understading and the clarification helps.

> Your patch try to add PageReserved() to __pageblock_pfn_to_page(). It
> woule make that zone->contiguous usually returns false since memory
> used by memblock API is marked as PageReserved() and your patch regard
> it as a hole. It invalidates set_zone_contiguous() optimization and I
> worry about it.

OK, fair enough. I did't consider memblock allocations. I will rethink
this patch but there are essentially 3 options
	- use a different criterion for the offline holes dection. I
	  have just realized we might do it by storing the online
	  information into the mem sections
	- drop this patch
	- move the PageReferenced check down the chain into
	  isolate_freepages_block resp. isolate_migratepages_block

I would prefer 3 over 2 over 1. I definitely want to make this more
robust so 1 is preferable long term but I do not want this to be a
roadblock to the rest of the rework. Does that sound acceptable to you?
 
[..]
> Let me clarify my desire(?) for this issue.
> 
> 1. If pfn_valid() returns true, struct page has valid information, at
> least, in flags (zone id, node id, flags, etc...). So, we can use them
> without checking PageResereved().

This is no longer true after my rework. Pages are associated with the
zone during _onlining_ rather than when they are physically hotpluged.
Basically only the nid is set properly. Strictly speaking this is the
case also without my rework because the zone might change during online
phase so you cannot assume it is correct even now. It just happens that
it more or less works just fine.

> 2. pfn_valid() for offlined holes returns false. This can be easily
> (?) implemented by manipulating SECTION_MAP_MASK in hotplug code. I
> guess that there is no reason that pfn_valid() returns true for
> offlined holes. If there is, please let me know.

There is some code which really expects that pfn_valid returns true iff
there is a struct page and it doesn't care about the online status.
E.g. hotplug code itself so no, we cannot change pfn_valid. What we can
do though is to add pfn_to_online_page which would do the proper check.
I have already sent [1]. As noted above we can (ab)use the remaining bit
in SECTION_MAP_MASK to detect offline pages more robustly.

> 3. We don't need to check PageReserved() in most of pfn walkers in
> order to check offline holes.

We still have to distinguish those who care about offline pages from
those who do not care about it.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
