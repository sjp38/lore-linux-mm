Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0159C6B0268
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:24:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so2328756wmu.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:24:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 129si9856664wme.241.2017.10.11.04.24.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 04:24:16 -0700 (PDT)
Date: Wed, 11 Oct 2017 13:24:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20171011112415.6hsudsrqhyuwjffx@dhcp22.suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
 <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz>
 <d29b6788-da1b-23e9-090c-d43428deb97d@suse.cz>
 <20171011081317.b2cdnhjdyzgdo3up@dhcp22.suse.cz>
 <c1b5f3cf-db9b-1cb8-dd0d-312940b7b953@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c1b5f3cf-db9b-1cb8-dd0d-312940b7b953@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 11-10-17 13:17:13, Vlastimil Babka wrote:
> On 10/11/2017 10:13 AM, Michal Hocko wrote:
> > On Wed 11-10-17 10:04:39, Vlastimil Babka wrote:
> >> On 10/11/2017 08:51 AM, Michal Hocko wrote:
> > [...]
> >>> This is really strange! As you write in other email the page is
> >>> reserved. That means that some of the earlier checks 
> >>> 	if (zone_idx(zone) == ZONE_MOVABLE)
> >>> 		return false;
> >>> 	mt = get_pageblock_migratetype(page);
> >>> 	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> >>
> >> The MIGRATE_MOVABLE check is indeed bogus, because that doesn't
> >> guarantee there are no unmovable pages in the block (CMA block OTOH
> >> should be a guarantee).
> > 
> > OK, thanks for confirmation. I will remove the MIGRATE_MOVABLE check
> > here. Do you think it is worth removing CMA check as well? This is
> > merely an optimization AFAIU because we do not have to check the full
> > pageblockworth of pfns.
> 
> Actually, we should remove the CMA part as well. It's true that
> MIGRATE_CMA does guarantee that the *buddy allocator* won't allocate
> non-MOVABLE pages from the pageblock. But if the memory got allocated as
> an actual CMA allocation (alloc_contig...) it will almost certainly not
> be movable.

That was my suspicious. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
