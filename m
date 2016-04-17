Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8016B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 22:28:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so188221547pab.2
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:28:26 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id e187si10506975pfe.32.2016.04.16.19.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 19:28:25 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id r5so12450160pag.1
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:28:25 -0700 (PDT)
Date: Sat, 16 Apr 2016 19:28:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 01/31] huge tmpfs: prepare counts in meminfo, vmstat and
 SysRq-m
In-Reply-To: <20160411110545.GD22996@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1604161900410.1896@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051410260.5965@eggly.anvils> <20160411110545.GD22996@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Apr 2016, Kirill A. Shutemov wrote:
> On Tue, Apr 05, 2016 at 02:12:26PM -0700, Hugh Dickins wrote:
> > ShmemFreeHoles will show the wastage from using huge pages for small, or
> > sparsely occupied, or unrounded files: wastage not included in Shmem or
> > MemFree, but will be freed under memory pressure.  (But no count for the
> > partially occupied portions of huge pages: seems less important, but
> > could be added.)
> 
> And here first difference in interfaces comes: I don't have an
> equivalent in my implementation, as I don't track such information.
> It looks like an implementation detail for team-pages based huge tmpfs.

It's an implementation detail insofar as that you've not yet implemented
the equivalent with compound pages - and I think you're hoping never to
do so.

Of course, nobody wants ShmemFreeHoles as such, but they do want
the filesize flexibility that comes with them.  And they may be an
important detail if free memory is vanishing into a black hole.

They are definitely a peculiar category, which is itself a strong
reason for making them visible in some way.  But I don't think I'd
mind if we decided they're not quite up to /proc/meminfo standards,
and should be shown somewhere else instead.  [Quiet sob.]

But if we do move them out of /proc/meminfo, I'll argue that they
should then be added in to the user-visible MemFree (though not to
the internal NR_FREE_PAGES): at different times I've felt differently
on that, and when MemAvailable came in, then it was so clear that they
belong in that category, that I didn't want them in MemFree; but if
they're not themselves high-level visible in /proc/meminfo, then
I think that probably they should go into MemFree.

But really, here, we want distro advice rather than my musings.

> 
> We don't track anything similar for anon-THP.

The case just doesn't arise with anon THP (or didn't arise before
your recent changes anyway): the object could only be a pmd-mapped
entity, and always showing AnonFreeHoles 0kB is just boring.

> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3830,6 +3830,11 @@ out:
> >  }
> >  
> >  #define K(x) ((x) << (PAGE_SHIFT-10))
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +#define THPAGE_PMD_NR	HPAGE_PMD_NR
> > +#else
> > +#define THPAGE_PMD_NR	0	/* Avoid BUILD_BUG() */
> > +#endif
> 
> I've just put THP-related counters on separate line and wrap it into
> #ifdef.

Time and time again I get very annoyed by that BUILD_BUG() buried
inside HPAGE_PMD_NR.  I expect you do too.  But it's true that it
does sometimes alert us to some large chunk of code that ought to
be slightly reorganized to get it optimized away.  So I never
quite summon up the courage to un-BUILD_BUG it.

I think we need a secret definition that only you and I know,
THPAGE_PMD_NR or whatever, to get around it on occasion.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
