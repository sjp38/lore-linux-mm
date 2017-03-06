Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC2E6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 21:15:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o126so21472945pfb.2
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 18:15:17 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s3si17594650plj.94.2017.03.05.18.15.16
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 18:15:16 -0800 (PST)
Date: Mon, 6 Mar 2017 11:15:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 06/11] mm: remove SWAP_MLOCK in ttu
Message-ID: <20170306021508.GD8779@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-7-git-send-email-minchan@kernel.org>
 <54799ea5-005d-939c-de32-bc21af881ab4@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54799ea5-005d-939c-de32-bc21af881ab4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

Hi Anshuman,

On Fri, Mar 03, 2017 at 06:06:38PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
> > because it means the page is not-swappable so it should move to
> > another LRU list(active or unevictable). putback friends will
> > move it to right list depending on the page's LRU flag.
> 
> Right, if it cannot be swapped out there is not much difference with
> SWAP_FAIL once we change the callers who expected to see a SWAP_MLOCK
> return instead.
> 
> > 
> > A side effect is shrink_page_list accounts unevictable list movement
> > by PGACTIVATE but I don't think it corrupts something severe.
> 
> Not sure I got that, could you please elaborate on this. We will still
> activate the page and put it in an appropriate LRU list if it is marked
> mlocked ?

Right. putback_iactive_pages/putback_lru_page has a logic to filter
out unevictable pages and move them to unevictable LRU list so it
doesn't break LRU change behavior but the concern is until now,
we have accounted PGACTIVATE for only evictable LRU list page but
by this change, it accounts it to unevictable LRU list as well.
However, although I don't think it's big problem in real practice,
we can fix it simply with checking PG_mlocked if someone reports.

Thanks.


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
