Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 4DBA96B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 06:37:17 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:37:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130402103713.GD32241@suse.de>
References: <20130327060141.GA23703@longonot.mountain>
 <20130327165556.GA22966@dhcp22.suse.cz>
 <20130401111324.GY18466@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130401111324.GY18466@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 01, 2013 at 02:13:24PM +0300, Dan Carpenter wrote:
> I still don't understand the code in gfp_to_alloc_flags().
> 
> 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> 
> ORing with zero is odd.
> 

Thanks Dan for the report and thanks Michal for fixing it. I was offline
for last week which lead to my tardy response.

The odditiy is that ALLOC_WMARK_MIN is not treated as a flag but as an
offset within the zone->wmark so it starts as 0. It could have been
written as

	int alloc_flags = ALLOC_CPUSET;

but then it would be easy to forget that in this path we are using the
MIN watermark.

The "flag" is used as an offset because it eliminated a number of
branches in the page allocator and was a micro-optimisation at the time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
