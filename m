Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3F92E8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 06:38:44 -0400 (EDT)
Date: Wed, 23 Mar 2011 10:38:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: page allocator: Silence build_all_zonelists()
 section mismatch.
Message-ID: <20110323103836.GC6802@csn.ul.ie>
References: <20110322133045.GA24498@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110322133045.GA24498@linux-sh.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 22, 2011 at 10:30:45PM +0900, Paul Mundt wrote:
> The memory hotplug case involves calling to build_all_zonelists() which
> in turns calls in to setup_zone_pageset(). The latter is marked
> __meminit while build_all_zonelists() itself has no particular
> annotation. build_all_zonelists() is only handed a non-NULL pointer in
> the case of memory hotplug through an existing __meminit path, so the
> setup_zone_pageset() reference is always safe.
> 
> The options as such are either to flag build_all_zonelists() as __ref (as
> per __build_all_zonelists()), or to simply discard the __meminit
> annotation from setup_zone_pageset().
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> 
> ---
> 
> While discarding the __meminit annotation from setup_zone_pageset() is
> probably cleanest I expected some people would take issue with this so
> opted for the more visually offensive __ref route. I can resend for the
> other way if people prefer, or someone else can do it given that it's a
> trivial change.
> 
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Discarding __meminit from setup_zone_pageset() would unnecessarily grow
the kernel image in the !HOTPLUG case and setting __meminit on
build_all_zonelists() looks like it would just cause other section
mistmatch warnings so;

Acked-by: Mel Gorman <mel@csn.ul.ie>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
