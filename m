Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B22546B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:11:10 -0400 (EDT)
Date: Thu, 19 May 2011 17:11:01 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
Message-ID: <20110519221101.GC19648@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20110518153445.GA18127@sgi.com> <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com> <20110519045630.GA22533@sgi.com> <BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>

On Thu, May 19, 2011 at 10:37:13AM -0300, Rafael Aquini wrote:
> On Thu, May 19, 2011 at 1:56 AM, Russ Anderson <rja@sgi.com> wrote:
> >
> > The way it was verified was putting a printk in to print totalram_pages
> > and hugetlb_total_pages.  First the system was booted without any huge
> > pages.  The next boot one huge page was allocated.  The next boot more
> > hugepages allocated.  Each time totalram_pages was reduced by the nuber
> > of huge pages allocated, with totalram_pages + hugetlb_total_pages
> > equaling the original number of pages.
> >
> > That behavior is also consistent with allocating over half of memory
> > resulting in CommitLimit going negative (as is shown in the above
> > output).
> >
> > Here is some data.  Each represents a boot using 1G hugepages.
> >   0 hugepages : totalram_pages 16519867 hugetlb_total_pages       0
> >   1 hugepages : totalram_pages 16257723 hugetlb_total_pages  262144
> >   2 hugepages : totalram_pages 15995578 hugetlb_total_pages  524288
> >  31 hugepages : totalram_pages  8393403 hugetlb_total_pages 8126464
> >  32 hugepages : totalram_pages  8131258 hugetlb_total_pages 8388608
> >
> >
> > > hugepages are reserved, hugetlb_total_pages() has to be accounted and
> > > subtracted from totalram_pages in order to render an accurate number of
> > > remaining pages available to the general memory workload commitment.
> > >
> > > I've tried to reproduce your findings on my boxes,  without
> > > success, unfortunately.
> >
> > Put a printk in meminfo_proc_show() to print totalram_pages and
> > hugetlb_total_pages().  Add "default_hugepagesz=1G hugepagesz=1G
> > hugepages=64"
> > to the boot line (varying the number of hugepages).
> >
> > > I'll keep chasing to hit this behaviour, though.
> 
> I got what I was doing different, and you are partially right.
> Checking mm/hugetlb.c:
> 1811 static int __init hugetlb_nrpages_setup(char *s)
> 1812 {
> ....
> 1834         /*
> 1835          * Global state is always initialized later in hugetlb_init.
> 1836          * But we need to allocate >= MAX_ORDER hstates here early to
> still
> 1837          * use the bootmem allocator.
> 1838          */
> 1839         if (max_hstate && parsed_hstate->order >= MAX_ORDER)
> 1840                 hugetlb_hstate_alloc_pages(parsed_hstate);
> 1841
> 1842         last_mhp = mhp;
> 1843
> 1844         return 1;
> 1845 }
> 1846 __setup("hugepages=", hugetlb_nrpages_setup);
> 
> I realize this issue you've reported only happens when you're using
> oversized hugepages. As their order are always >= MAX_ORDER, they got pages
> early allocated from bootmem allocator. So, these pages are not accounted
> for totalram_pages.
> 
> Although your patch covers a fix for the proposed case, it only works for
> scenarios where oversized hugepages are allocated on boot. I think it will,
> unfortunately, cause a bug for the remaining scenarios.

OK, I see your point.  The root problem is hugepages allocated at boot are
subtracted from totalram_pages but hugepages allocated at run time are not.
Correct me if I've mistate it or are other conditions.

By "allocated at run time" I mean "echo 1 > /proc/sys/vm/nr_hugepages".
That allocation will not change totalram_pages but will change
hugetlb_total_pages().

How best to fix this inconsistency?  Should totalram_pages include or exclude
hugepages?  What are the implications?

I have no strong preference as to which way to go as long as it is consistent.

> Cheers!
> --aquini

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
