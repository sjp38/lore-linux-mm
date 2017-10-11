Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 199BF6B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:24:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so6481855pff.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:24:52 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id m14si10530265pgs.511.2017.10.11.14.24.50
        for <linux-mm@kvack.org>;
        Wed, 11 Oct 2017 14:24:51 -0700 (PDT)
Date: Thu, 12 Oct 2017 08:24:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011212401.GM15067@dastard>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
 <20171011210613.GQ3667@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011210613.GQ3667@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Wed, Oct 11, 2017 at 11:06:13PM +0200, Jan Kara wrote:
> On Wed 11-10-17 10:34:47, Dave Hansen wrote:
> > On 10/11/2017 01:06 AM, Jan Kara wrote:
> > >>> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> > >>> have noticed a regression in bonnie++ benchmark when deleting files.
> > >>> Eventually we have tracked this down to a fact that page cache truncation got
> > >>> slower by about 10%. There were both gains and losses in the above interval of
> > >>> kernels but we have been able to identify that commit 83929372f629 "filemap:
> > >>> prepare find and delete operations for huge pages" caused about 10% regression
> > >>> on its own.
> > >> It's odd that just checking if some pages are huge should be that
> > >> expensive, but ok ..
> > > Yeah, I was surprised as well but profiles were pretty clear on this - part
> > > of the slowdown was caused by loads of page->_compound_head (PageTail()
> > > and page_compound() use that) which we previously didn't have to load at
> > > all, part was in hpage_nr_pages() function and its use.
> > 
> > Well, page->_compound_head is part of the same cacheline as the rest of
> > the page, and the page is surely getting touched during truncation at
> > _some_ point.  The hpage_nr_pages() might cause the cacheline to get
> > loaded earlier than before, but I can't imagine that it's that expensive.
> 
> Then my intuition matches yours ;) but profiles disagree.

Do you get the same benefit across different filesystems?

> That being said
> I'm not really expert in CPU microoptimizations and profiling so feel free
> to gather perf profiles yourself before and after commit 83929372f629 and
> get better explanation of where the cost is - I would be really curious
> what you come up with because the explanation I have disagrees with my
> intuition as well...

When I see this sort of stuff my immediate thought is "what is the
change in the icache footprint of the hot codepath"? There's a
few IO benchmarks (e.g. IOZone) that are l1/l2 cache footprint
sensitive on XFS, and can see up to 10% differences in performance
from kernel build to kernel build that have no code changes in the
IO paths or l1/l2 dcache footprint.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
