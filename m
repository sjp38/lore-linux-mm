Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E135D6B025F
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:15:07 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so55739239lfz.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:07 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id l5si43460562wjj.53.2016.05.30.02.15.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 02:15:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 2917E98B95
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:15:06 +0000 (UTC)
Date: Mon, 30 May 2016 10:15:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH] mm/init: fix zone boundary creation
Message-ID: <20160530091504.GN2527@techsingularity.net>
References: <1462435033-15601-1-git-send-email-oohall@gmail.com>
 <20160526142142.b16f7f3f18204faf0823ac65@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160526142142.b16f7f3f18204faf0823ac65@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, May 26, 2016 at 02:21:42PM -0700, Andrew Morton wrote:
> On Thu,  5 May 2016 17:57:13 +1000 "Oliver O'Halloran" <oohall@gmail.com> wrote:
> 
> > As a part of memory initialisation the architecture passes an array to
> > free_area_init_nodes() which specifies the max PFN of each memory zone.
> > This array is not necessarily monotonic (due to unused zones) so this
> > array is parsed to build monotonic lists of the min and max PFN for
> > each zone. ZONE_MOVABLE is special cased here as its limits are managed by
> > the mm subsystem rather than the architecture. Unfortunately, this special
> > casing is broken when ZONE_MOVABLE is the not the last zone in the zone
> > list. The core of the issue is:
> > 
> > 	if (i == ZONE_MOVABLE)
> > 		continue;
> > 	arch_zone_lowest_possible_pfn[i] =
> > 		arch_zone_highest_possible_pfn[i-1];
> > 
> > As ZONE_MOVABLE is skipped the lowest_possible_pfn of the next zone
> > will be set to zero. This patch fixes this bug by adding explicitly
> > tracking where the next zone should start rather than relying on the
> > contents arch_zone_highest_possible_pfn[].
> 
> hm, this is all ten year old Mel code.
> 

ZONE_MOVABLE at the time always existed at the end of a node during
initialisation time. It was allowed because the memory was always "stolen"
from the end of the node where it could have the same limitations as
ZONE_HIGHMEM if necessary. It was also safe to assume that zones never
overlapped as zones were about addressing limitations.  If ZONE_CMA or
ZONE_DEVICE can overlap with other zones during initialisation time then
there may be a few gremlins hiding in there. Unfortunately I have not
done an audit searching for problems with overlapping zones.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
