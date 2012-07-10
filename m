Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6E31E6B0069
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 05:45:22 -0400 (EDT)
Date: Tue, 10 Jul 2012 10:45:13 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120710094513.GB9108@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
 <20120709122523.GC4627@tiehlicka.suse.cz>
 <20120709141324.GK7315@mudshark.cambridge.arm.com>
 <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Hugh,

Cheers for looking at this.

On Tue, Jul 10, 2012 at 12:57:14AM +0100, Hugh Dickins wrote:
> On Mon, 9 Jul 2012, Will Deacon wrote:
> > On Mon, Jul 09, 2012 at 01:25:23PM +0100, Michal Hocko wrote:
> > > On Wed 04-07-12 15:32:56, Will Deacon wrote:
> > > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > > index e198831..b83d026 100644
> > > > --- a/mm/hugetlb.c
> > > > +++ b/mm/hugetlb.c
> > > > @@ -2646,6 +2646,7 @@ retry:
> > > >  			goto out;
> > > >  		}
> > > >  		clear_huge_page(page, address, pages_per_huge_page(h));
> > > > +		flush_dcache_page(page);
> > > >  		__SetPageUptodate(page);
> > > 
> > > Does this have to be explicit in the arch independent code?
> > > It seems that ia64 uses flush_dcache_page already in the clear_user_page
> > 
> > It would match what is done in similar situations by cow_user_page (mm/memory.c)
> > and shmem_writepage (mm/shmem.c). Other subsystems also have explicit page
> > flushing (DMA bounce, ksm) so I think this is the right place for it.
> 
> I am not at all sure if you are right or not:
> please let's consult linux-arch about this - now Cc'ed.

I assume that by `linux-arch' you mean BenH :)

> If this hugetlb_no_page() were solely mapping the hugepage into that
> userspace, I would say you are wrong.  It's the job of clear_huge_page()
> to take the mapped address into account, and pass it down to the
> architecture-specific implementation, to do whatever flushing is
> needed - you should be providing that in your architecture.
> 
> In particular, notice how clear_huge_page() goes round a loop of
> clear_user_highpage()s: in your patch, you're expecting the implementation
> of flush_dcache_page() to notice whether or not this is a hugepage, and
> flush the appropriate size.
> 
> Perhaps yours is the only architecture to need this on huge, and your
> flush_dcache_page() implements it correctly; but it does seem surprising.

ARM doesn't yet have hugetlb support in mainline so we can do whatever
people prefer. I think it makes sense for flush_dcache_page to be hugepage
aware so that we can sync the caches when installing huge ptes using the
same code as normal ptes. Of course, that may not be the same across all
architectures, so you certainly have a valid point.

> If I start to grep the architectures for non-empty flush_dcache_page(),
> I soon find things in arch/arm such as v4_mc_copy_user_highpage() doing
> if (!test_and_set_bit(PG_dcache_clean,)) __flush_dcache_page() - where
> the naming suggests that I'm right, it's the architecture's responsibility
> to arrange whatever flushing is needed in its copy and clear page functions.

On ARM the flushing is there to deal with dcache aliasing and highmem, so the
clear/copy functions won't actually do explicit flushing on modern (ARMv7)
cores. Instead we flush the page when writing the pte and noticing that
PG_arch_1 (PG_dcache_clean) is clear...

...so the real question is why this wasn't being triggered for huge pages.
I'll go and take another look since I would expect PG_arch_1 to be cleared
for pages coming back from alloc_huge_page.

> But... this hugetlb_no_page() has a VM_MAYSHARE case below, which puts
> the new page into page cache, making it accessible by other processes:
> that may indeed be reason for flush_dcache_page() there - or a loop of
> flush_dcache_page()s.  But I worry then that in the !VM_MAYSHARE case
> you would be duplicating expensive flushes: perhaps they should be
> restricted to the VM_MAYSHARE block.

If the PG_arch_1 flag does its job, duplicate flushes shouldn't be a
problem.

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
