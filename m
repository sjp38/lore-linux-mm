Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 019FF6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 09:54:26 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id 10so1227445lbg.1
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:54:25 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id gi3si5557167wib.83.2015.01.07.06.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 06:47:52 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id x12so1284601wgg.38
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:47:52 -0800 (PST)
Date: Wed, 7 Jan 2015 15:47:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 4/4] mm: microoptimize zonelist operations
Message-ID: <20150107144750.GF16553@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-5-git-send-email-vbabka@suse.cz>
 <20150106150920.GE20860@dhcp22.suse.cz>
 <54ACF93B.3060801@suse.cz>
 <20150107105749.GC16553@dhcp22.suse.cz>
 <20150107111706.GC2395@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107111706.GC2395@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 07-01-15 11:17:07, Mel Gorman wrote:
> On Wed, Jan 07, 2015 at 11:57:49AM +0100, Michal Hocko wrote:
> > On Wed 07-01-15 10:15:39, Vlastimil Babka wrote:
> > > On 01/06/2015 04:09 PM, Michal Hocko wrote:
> > > > On Mon 05-01-15 18:17:43, Vlastimil Babka wrote:
> > > >> The function next_zones_zonelist() returns zoneref pointer, as well as zone
> > > >> pointer via extra parameter. Since the latter can be trivially obtained by
> > > >> dereferencing the former, the overhead of the extra parameter is unjustified.
> > > >> 
> > > >> This patch thus removes the zone parameter from next_zones_zonelist(). Both
> > > >> callers happen to be in the same header file, so it's simple to add the
> > > >> zoneref dereference inline. We save some bytes of code size.
> > > > 
> > > > Dunno. It makes first_zones_zonelist and next_zones_zonelist look
> > > > different which might be a bit confusing. It's not a big deal but
> > > > I am not sure it is worth it.
> > > 
> > > Yeah I thought that nobody uses them directly anyway thanks to
> > > for_each_zone_zonelist* so it's not a big deal.
> > 
> > OK, I have checked why we need the whole struct zoneref when it
> > only caches zone_idx. dd1a239f6f2d (mm: have zonelist contains
> > structs with both a zone pointer and zone_idx) claims this will
> > reduce cache contention by reducing pointer chasing because we
> > do not have to dereference pgdat so often in hot paths. Fair
> > enough but I do not see any numbers in the changelog nor in the
> > original discussion (https://lkml.org/lkml/2007/11/20/547 resp.
> > https://lkml.org/lkml/2007/9/28/170). Maybe Mel remembers what was the
> > benchmark which has shown the difference so that we can check whether
> > this is still relevant and caching the index is still worth it.
> > 
> 
> IIRC, the difference was a few percent on instruction profiles and cache
> profiles when driven from a systemtap microbenchmark but I no longer have
> the data and besides it would have been based on an ancient machine by
> todays standards. When zeroing of pages is taken into account it's going
> to be marginal so a userspace test would probably show nothing. Still,
> I see little motivation to replace a single deference with multiple
> dereferences and pointer arithmetic when zonelist_zone_idx() is called.

OK, fair enough. I have tried to convert back to simple zone * and it
turned out we wouldn't save too much code so this is really not worth
time and possible complications.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
