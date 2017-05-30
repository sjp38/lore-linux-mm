Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C71836B02B4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:39:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j27so397066wre.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 07:39:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y59si11949603eda.212.2017.05.30.07.39.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 07:39:49 -0700 (PDT)
Date: Tue, 30 May 2017 16:39:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170530143941.GK7969@dhcp22.suse.cz>
References: <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530140456.GA8412@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 30-05-17 16:04:56, Andrea Arcangeli wrote:
> On Tue, May 30, 2017 at 12:39:30PM +0200, Michal Hocko wrote:
> > On Tue 30-05-17 13:19:22, Mike Rapoport wrote:
> > > On Tue, May 30, 2017 at 09:44:08AM +0200, Michal Hocko wrote:
> > > > On Wed 24-05-17 17:27:36, Mike Rapoport wrote:
> > > > > On Wed, May 24, 2017 at 01:18:00PM +0200, Michal Hocko wrote:
> > > > [...]
> > > > > > Why cannot khugepaged simply skip over all VMAs which have userfault
> > > > > > regions registered? This would sound like a less error prone approach to
> > > > > > me.
> > > > > 
> > > > > khugepaged does skip over VMAs which have userfault. We could register the
> > > > > regions with userfault before populating them to avoid collapses in the
> > > > > transition period.
> > > > 
> > > > Why cannot you register only post-copy regions and "manually" copy the
> > > > pre-copy parts?
> > > 
> > > We can register only post-copy regions, but this will cause VMA
> > > fragmentation. Now we register the entire VMA with userfaultfd, no matter
> > > how many pages were dirtied there since the pre-dump. If we register only
> > > post-copy regions, we will split out the VMAs for those regions.
> > 
> > Is this really a problem, though?
> 
> It would eventually get -ENOMEM or at best create lots of unnecessary
> vmas (at least UFFDIO_COPY would never risk to trigger -ENOMEM).

I sysctl for the mapcount can be increased, right? I also assume that
those vmas will get merged after the post copy is done.

> The only attractive alternative is to use UFFDIO_COPY for precopy too
> after pre-registering the whole range in uffd (which would happen
> later anyway to start postcopy).
> 
> > It would be good to measure that though. You are proposing a new user
> > API and the THP api is quite convoluted already so there better be a
> > very good reason to add a new API. So far I can only see that it would
> > be more convinient to add another madvise command and that is rather
> > insufficient justification IMHO. Also do you expect somebody else would
> > use new madvise? What would be the usecase?
> 
> UFFDIO_COPY while not being a major slowdown for sure, it's likely
> measurable at the microbenchmark level because it would add a
> enter/exit kernel to every 4k memcpy. It's not hard to imagine that as
> measurable. How that impacts the total precopy time I don't know, it
> would need to be benchmarked to be sure.

Yes, please!

> The main benefit of this
> madvise is precisely to skip those enter/exit kernel that UFFDIO_COPY
> would add. Even if the impact on the total precopy time wouldn't be
> measurable (i.e. if it's network bound load), the madvise that allows
> using memcpy after setting VM_NOHUGEPAGE, would free up some CPU
> cycles in the destination that could be used by other processes.

I understand that part but it sounds awfully one purpose thing to me.
Are we going to add other MADVISE_RESET_$FOO to clear other flags just
because we can race in this specific use case?

> About the proposed madvise, it just clear bits, but it doesn't change
> at all how those bits are computed in THP code. So I don't see it as
> convoluted.

But we already have MADV_HUGEPAGE, MADV_NOHUGEPAGE and prctl to
enable/disable thp. Doesn't that sound little bit too much for a single
feature to you?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
