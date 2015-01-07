Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9223A6B0071
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 05:57:52 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so913104wes.38
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 02:57:52 -0800 (PST)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id ee5si4030487wic.103.2015.01.07.02.57.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 02:57:51 -0800 (PST)
Received: by mail-we0-f172.google.com with SMTP id k11so927449wes.31
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 02:57:51 -0800 (PST)
Date: Wed, 7 Jan 2015 11:57:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 4/4] mm: microoptimize zonelist operations
Message-ID: <20150107105749.GC16553@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-5-git-send-email-vbabka@suse.cz>
 <20150106150920.GE20860@dhcp22.suse.cz>
 <54ACF93B.3060801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54ACF93B.3060801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 07-01-15 10:15:39, Vlastimil Babka wrote:
> On 01/06/2015 04:09 PM, Michal Hocko wrote:
> > On Mon 05-01-15 18:17:43, Vlastimil Babka wrote:
> >> The function next_zones_zonelist() returns zoneref pointer, as well as zone
> >> pointer via extra parameter. Since the latter can be trivially obtained by
> >> dereferencing the former, the overhead of the extra parameter is unjustified.
> >> 
> >> This patch thus removes the zone parameter from next_zones_zonelist(). Both
> >> callers happen to be in the same header file, so it's simple to add the
> >> zoneref dereference inline. We save some bytes of code size.
> > 
> > Dunno. It makes first_zones_zonelist and next_zones_zonelist look
> > different which might be a bit confusing. It's not a big deal but
> > I am not sure it is worth it.
> 
> Yeah I thought that nobody uses them directly anyway thanks to
> for_each_zone_zonelist* so it's not a big deal.

OK, I have checked why we need the whole struct zoneref when it
only caches zone_idx. dd1a239f6f2d (mm: have zonelist contains
structs with both a zone pointer and zone_idx) claims this will
reduce cache contention by reducing pointer chasing because we
do not have to dereference pgdat so often in hot paths. Fair
enough but I do not see any numbers in the changelog nor in the
original discussion (https://lkml.org/lkml/2007/11/20/547 resp.
https://lkml.org/lkml/2007/9/28/170). Maybe Mel remembers what was the
benchmark which has shown the difference so that we can check whether
this is still relevant and caching the index is still worth it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
