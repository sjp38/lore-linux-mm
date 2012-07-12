Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 2533A6B005A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 07:26:37 -0400 (EDT)
Message-ID: <1342092392.3021.33.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 12 Jul 2012 12:26:32 +0100
In-Reply-To: <20120712111659.GF21013@tiehlicka.suse.cz>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
	 <20120709122523.GC4627@tiehlicka.suse.cz>
	 <20120709141324.GK7315@mudshark.cambridge.arm.com>
	 <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
	 <20120710094513.GB9108@mudshark.cambridge.arm.com>
	 <20120710104234.GI9108@mudshark.cambridge.arm.com>
	 <20120711174802.GG13498@mudshark.cambridge.arm.com>
	 <20120712111659.GF21013@tiehlicka.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2012-07-12 at 13:16 +0200, Michal Hocko wrote:
> On Wed 11-07-12 18:48:02, Will Deacon wrote:
> > On Tue, Jul 10, 2012 at 11:42:34AM +0100, Will Deacon wrote:
> > > On Tue, Jul 10, 2012 at 10:45:13AM +0100, Will Deacon wrote:
> > > > On Tue, Jul 10, 2012 at 12:57:14AM +0100, Hugh Dickins wrote:
> > > > > If I start to grep the architectures for non-empty flush_dcache_page(),
> > > > > I soon find things in arch/arm such as v4_mc_copy_user_highpage() doing
> > > > > if (!test_and_set_bit(PG_dcache_clean,)) __flush_dcache_page() - where
> > > > > the naming suggests that I'm right, it's the architecture's responsibility
> > > > > to arrange whatever flushing is needed in its copy and clear page functions.
> > 
> > [...]
> > 
> > > Ok, so this is exactly the problem. The hugetlb allocator uses its own
> > > pool of huge pages, so free_huge_page followed by a later alloc_huge_page
> > > will give you something where the page flags of the compound head do not
> > > guarantee that PG_arch_1 is clear.
> > 
> > Just to confirm, the following quick hack at least results in the correct
> > flushing for me (on ARM):
> > 
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index e198831..7a7c9d3 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1141,6 +1141,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> >         }
> >  
> >         set_page_private(page, (unsigned long)spool);
> > +       clear_bit(PG_arch_1, &page->flags);
> >  
> >         vma_commit_reservation(h, vma, addr);
> >  
> > 
> > 
> > The question is whether we should tidy that up for the core code or get
> > architectures to clear the bit in arch_make_huge_pte (which also seems to
> > work).
> 
> This should go into arch specific code IMO. Even the page flag name
> suggests this shouldn't be in the base code.

Agree completely.

PG_Arch_1 is mostly used for flushing implementations, but it's meaning
isn't unified.  For instance Arm and Parisc have opposite meanings for
this flag.  Touching it in generic code can therefore *never* be the
right thing to do.  What you're looking for here is the correct flushing
(or rather flush notification) interface.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
