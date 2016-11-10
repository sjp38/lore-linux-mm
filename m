Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA3596B02A0
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:25:44 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so12011569wma.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:25:44 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id b18si5966434wjb.236.2016.11.10.08.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 08:25:43 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id m203so2494236wma.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:25:43 -0800 (PST)
Date: Thu, 10 Nov 2016 19:25:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
Message-ID: <20161110162540.GA12743@node.shutemov.name>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com>
 <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
 <alpine.LSU.2.11.1611071433340.1384@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1611071433340.1384@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 07, 2016 at 03:17:11PM -0800, Hugh Dickins wrote:
> On Sat, 22 Oct 2016, Kirill A. Shutemov wrote:
> > 
> > Huge pages are detrimental for small file: they causes noticible
> > overhead on both allocation performance and memory footprint.
> > 
> > This patch aimed to address this issue by avoiding huge pages until file
> > grown to size of huge page. This would cover most of the cases where huge
> > pages causes regressions in performance.
> > 
> > Couple notes:
> > 
> >   - if shmem_enabled is set to 'force', the limit is ignored. We still
> >     want to generate as many pages as possible for functional testing.
> > 
> >   - the limit doesn't affect khugepaged behaviour: it still can collapse
> >     pages based on its settings;
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Sorry, but NAK.  I was expecting a patch to tune within_size behaviour.
> 
> > ---
> >  Documentation/vm/transhuge.txt | 3 +++
> >  mm/shmem.c                     | 5 +++++
> >  2 files changed, 8 insertions(+)
> > 
> > diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> > index 2ec6adb5a4ce..d1889c7c8c46 100644
> > --- a/Documentation/vm/transhuge.txt
> > +++ b/Documentation/vm/transhuge.txt
> > @@ -238,6 +238,9 @@ values:
> >    - "force":
> >      Force the huge option on for all - very useful for testing;
> >  
> > +To avoid overhead for small files, we don't allocate huge pages for a file
> > +until it grows to size of huge pages.
> > +
> >  == Need of application restart ==
> >  
> >  The transparent_hugepage/enabled values and tmpfs mount option only affect
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index ad7813d73ea7..49618d2d6330 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1692,6 +1692,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >  				goto alloc_huge;
> >  			/* TODO: implement fadvise() hints */
> >  			goto alloc_nohuge;
> > +		case SHMEM_HUGE_ALWAYS:
> > +			i_size = i_size_read(inode);
> > +			if (index < HPAGE_PMD_NR && i_size < HPAGE_PMD_SIZE)
> > +				goto alloc_nohuge;
> > +			break;
> >  		}
> >  
> >  alloc_huge:
> 
> So (eliding the SHMEM_HUGE_ADVISE case in between) you now have:
> 
> 		case SHMEM_HUGE_WITHIN_SIZE:
> 			off = round_up(index, HPAGE_PMD_NR);
> 			i_size = round_up(i_size_read(inode), PAGE_SIZE);
> 			if (i_size >= HPAGE_PMD_SIZE &&
> 					i_size >> PAGE_SHIFT >= off)
> 				goto alloc_huge;
> 			goto alloc_nohuge;
> 		case SHMEM_HUGE_ALWAYS:
> 			i_size = i_size_read(inode);
> 			if (index < HPAGE_PMD_NR && i_size < HPAGE_PMD_SIZE)
> 				goto alloc_nohuge;
> 			goto alloc_huge;
> 
> I'll concede that those two conditions are not the same; but again you're
> messing with huge=always to make it, not always, but conditional on size.
> 
> Please, keep huge=always as is: if I copy a 4MiB file into a huge tmpfs,
> I got ShmemHugePages 4096 kB before, which is what I wanted.  Whereas
> with this change I get only 2048 kB, just like with huge=within_size.

I don't think it's a problem really. We don't have guarantees anyway.
And we can collapse the page later.

But okay.

> Treating the first extent differently is a hack, and does not respect
> that this is a filesystem, on which size is likely to increase.
> 
> By all means refine the condition for huge=within_size, and by all means
> warn in transhuge.txt that huge=always may tend to waste valuable huge
> pages if the filesystem is used for small files without good reason

Would it be okay, if I just replace huge=within_size logic with what I
proposed here for huge=always?

That's not what I intended initially for this option, but...

> (but maybe the implementation needs to reclaim those more effectively).

It's more about cost of allocation than memory pressure.

-----8<-----
