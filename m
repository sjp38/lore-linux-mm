Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C55A86B0011
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 21:38:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z5-v6so584353plo.21
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 18:38:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b7-v6si2372998plr.399.2018.03.27.18.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 18:37:59 -0700 (PDT)
Date: Tue, 27 Mar 2018 18:37:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-Id: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
In-Reply-To: <20180328005142.GC91956@WeideMacBook-Pro.local>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
	<20180327154740.9a7713a74a383254b51f4d1a@linux-foundation.org>
	<20180328005142.GC91956@WeideMacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, tj@kernel.org, linux-mm@kvack.org

On Wed, 28 Mar 2018 08:51:42 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> On Tue, Mar 27, 2018 at 03:47:40PM -0700, Andrew Morton wrote:
> >On Tue, 27 Mar 2018 11:57:07 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
> >
> >> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
> >> node. The memblock_region in memblock_type are already ordered, which means
> >> the first hit in iteration is the minimum pfn.
> >> 
> >> This patch returns the fist hit instead of iterating the whole regions.
> >> 
> >> ...
> >>
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -6365,14 +6365,14 @@ unsigned long __init node_map_pfn_alignment(void)
> >>  /* Find the lowest pfn for a node */
> >>  static unsigned long __init find_min_pfn_for_node(int nid)
> >>  {
> >> -	unsigned long min_pfn = ULONG_MAX;
> >> -	unsigned long start_pfn;
> >> +	unsigned long min_pfn;
> >>  	int i;
> >>  
> >> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
> >> -		min_pfn = min(min_pfn, start_pfn);
> >> +	for_each_mem_pfn_range(i, nid, &min_pfn, NULL, NULL) {
> >> +		break;
> >> +	}
> >
> >That would be the weirdest-looking code snippet in mm/!
> >
> 
> You mean the only break in a for_each loop? Hmm..., this is really not that
> nice. Haven't noticed could get a "best" in this way :-)

I guess we can make it nicer by adding a comment along the lines of

	/*
	 * Use for_each_mem_pfn_range() to locate the lowest valid pfn in the
	 * range.  We only need to iterate a single time, as the pfn's are
	 * sorted in ascending order.
	 */

Because adding a call to the obviously-internal __next_mem_pfn_range()
isn't very nice either.

Anyway, please have a think, see what we can come up with.
