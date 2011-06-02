Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 413146B007B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 00:08:37 -0400 (EDT)
Date: Wed, 1 Jun 2011 23:08:31 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
Message-ID: <20110602040821.GA7934@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20110518153445.GA18127@sgi.com> <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com> <20110519045630.GA22533@sgi.com> <BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com> <20110519221101.GC19648@sgi.com> <20110520130411.d1e0baef.akpm@linux-foundation.org> <20110520223032.GA15192@x61.tchesoft.com> <20110526210751.GA14819@optiplex.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110526210751.GA14819@optiplex.tchesoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, rja@americas.sgi.com

On Thu, May 26, 2011 at 06:07:53PM -0300, Rafael Aquini wrote:
> On Fri, May 20, 2011 at 07:30:32PM -0300, Rafael Aquini wrote:
> > On Fri, May 20, 2011 at 01:04:11PM -0700, Andrew Morton wrote:
> > > On Thu, 19 May 2011 17:11:01 -0500
> > > Russ Anderson <rja@sgi.com> wrote:
> > > 
> > > > OK, I see your point.  The root problem is hugepages allocated at boot are
> > > > subtracted from totalram_pages but hugepages allocated at run time are not.
> > > > Correct me if I've mistate it or are other conditions.
> > > > 
> > > > By "allocated at run time" I mean "echo 1 > /proc/sys/vm/nr_hugepages".
> > > > That allocation will not change totalram_pages but will change
> > > > hugetlb_total_pages().
> > > > 
> > > > How best to fix this inconsistency?  Should totalram_pages include or exclude
> > > > hugepages?  What are the implications?
> > > 
> > > The problem is that hugetlb_total_pages() is trying to account for two
> > > different things, while totalram_pages accounts for only one of those
> > > things, yes?
> > > 
> > > One fix would be to stop accounting for huge pages in totalram_pages
> > > altogether.  That might break other things so careful checking would be
> > > needed.
> > > 
> > > Or we stop accounting for the boot-time allocated huge pages in
> > > hugetlb_total_pages().  Split the two things apart altogether and
> > > account for boot-time allocated and runtime-allocated pages separately.  This
> > > souds saner to me - it reflects what's actually happening in the kernel.
> > 
> > Perhaps we can just reinstate the # of pages "stealed" at early boot allocation
> > later, when hugetlb_init() calls gather_bootmem_prealloc()
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 8ee3bd8..d606c9c 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1111,6 +1111,7 @@ static void __init gather_bootmem_prealloc(void)
> >                 WARN_ON(page_count(page) != 1);
> >                 prep_compound_huge_page(page, h->order);
> >                 prep_new_huge_page(h, page, page_to_nid(page));
> > +               totalram_pages += 1 << h->order;
> >         }
> >  }
> 
> Howdy Russ,
> 
> Were you able to confirm if that proposed change fix the issue you've reported?

Yes, it fixes the inconsistency in reporting totalram_pages.

> Although I've tested it with usual size hugepages and it did not messed things up,
> I'm not able to test it with GB hugepages, as I do not have any proc with "pdpe1gb" flag available.

There seems to be another issue.  1G hugepages can be allocated at boot time, but
cannot be allocated at run time.  "default_hugepagesz=1G hugepagesz=1G hugepages=1" on 
the boot line works.  With "default_hugepagesz=1G hugepagesz=1G" the command
"echo 1 > /proc/sys/vm/nr_hugepages" fails.

uv4-sys:~ # echo 1 > /proc/sys/vm/nr_hugepages
-bash: echo: write error: Invalid argument


> Thanks in advance!
> Cheers!
> -- 
> Rafael Aquini <aquini@linux.com>

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
