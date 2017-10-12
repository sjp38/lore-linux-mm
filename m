Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38C9B6B0069
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:07:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so6075821wmu.2
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:07:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si2032520wrh.61.2017.10.12.07.07.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 07:07:12 -0700 (PDT)
Date: Thu, 12 Oct 2017 16:07:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171012140704.GH29293@quack2.suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
 <20171011210613.GQ3667@quack2.suse.cz>
 <20171011212401.GM15067@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011212401.GM15067@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Thu 12-10-17 08:24:01, Dave Chinner wrote:
> On Wed, Oct 11, 2017 at 11:06:13PM +0200, Jan Kara wrote:
> > On Wed 11-10-17 10:34:47, Dave Hansen wrote:
> > > On 10/11/2017 01:06 AM, Jan Kara wrote:
> > > >>> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> > > >>> have noticed a regression in bonnie++ benchmark when deleting files.
> > > >>> Eventually we have tracked this down to a fact that page cache truncation got
> > > >>> slower by about 10%. There were both gains and losses in the above interval of
> > > >>> kernels but we have been able to identify that commit 83929372f629 "filemap:
> > > >>> prepare find and delete operations for huge pages" caused about 10% regression
> > > >>> on its own.
> > > >> It's odd that just checking if some pages are huge should be that
> > > >> expensive, but ok ..
> > > > Yeah, I was surprised as well but profiles were pretty clear on this - part
> > > > of the slowdown was caused by loads of page->_compound_head (PageTail()
> > > > and page_compound() use that) which we previously didn't have to load at
> > > > all, part was in hpage_nr_pages() function and its use.
> > > 
> > > Well, page->_compound_head is part of the same cacheline as the rest of
> > > the page, and the page is surely getting touched during truncation at
> > > _some_ point.  The hpage_nr_pages() might cause the cacheline to get
> > > loaded earlier than before, but I can't imagine that it's that expensive.
> > 
> > Then my intuition matches yours ;) but profiles disagree.
> 
> Do you get the same benefit across different filesystems?

Mel has answered this already.

> > That being said
> > I'm not really expert in CPU microoptimizations and profiling so feel free
> > to gather perf profiles yourself before and after commit 83929372f629 and
> > get better explanation of where the cost is - I would be really curious
> > what you come up with because the explanation I have disagrees with my
> > intuition as well...
> 
> When I see this sort of stuff my immediate thought is "what is the
> change in the icache footprint of the hot codepath"? There's a
> few IO benchmarks (e.g. IOZone) that are l1/l2 cache footprint
> sensitive on XFS, and can see up to 10% differences in performance
> from kernel build to kernel build that have no code changes in the
> IO paths or l1/l2 dcache footprint.

Yeah, icache footprint could be part of the reason commit 83929372f629
makes things slower but it definitely isn't the only reason. I have
experimented with modifications of THP handling so that we can discern
normal and THP pages from just looking at page flags (currently we have to
look at both page flags and page->_compound_head) and it did bring about
half of the regression back. But in the end I've discarded that because
those changes were likely to slow down splitting of THPs significantly.

WRT build-to-build variance of the benchmark: I saw build-to-build variance
in the measured truncate times around 2% on that machine. So it is
not negligible but small enough so that I'm confident measured differences
are not just a noise...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
