Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1F63E6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 12:55:58 -0400 (EDT)
Date: Wed, 27 Mar 2013 17:55:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130327165556.GA22966@dhcp22.suse.cz>
References: <20130327060141.GA23703@longonot.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327060141.GA23703@longonot.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: mgorman@suse.de, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[Adding Andrew into CC]

Hi Dan,

On Wed 27-03-13 09:01:42, Dan Carpenter wrote:
> Hello Mel Gorman,
> 
> The patch 290d1a3ce0ec: "mm: page_alloc: avoid marking zones full 
> prematurely after zone_reclaim()" from Mar 23, 2013, leads to the 
> following warning:
> "mm/page_alloc.c:1957 get_page_from_freelist()
> 	 warn: bitwise AND condition is false here"

Dohh, I have totally missed this during review and I managed to burn
myself on the similar issue in the past (gfp & GFP_NOWAIT).
The follow up fix is bellow

> mm/page_alloc.c
>   1948                                  /*
>   1949                                   * Failed to reclaim enough to meet watermark.
>   1950                                   * Only mark the zone full if checking the min
>   1951                                   * watermark or if we failed to reclaim just
>   1952                                   * 1<<order pages or else the page allocator
>   1953                                   * fastpath will prematurely mark zones full
>   1954                                   * when the watermark is between the low and
>   1955                                   * min watermarks.
>   1956                                   */
>   1957                                  if ((alloc_flags & ALLOC_WMARK_MIN) ||
>                                                            ^^^^^^^^^^^^^^^
> This is zero.
> 
>   1958                                      ret == ZONE_RECLAIM_SOME)
>   1959                                          goto this_zone_full;
> 
> [snip]
> 
>   2333  static inline int
>   2334  gfp_to_alloc_flags(gfp_t gfp_mask)
>   2335  {
>   2336          int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
>                                   ^^^^^^^^^^^^^^^
>   2337          const gfp_t wait = gfp_mask & __GFP_WAIT;
---
