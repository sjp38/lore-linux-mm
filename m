Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 795B86B005C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 07:26:54 -0400 (EDT)
Date: Thu, 12 Jul 2012 12:26:45 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120712112645.GG2816@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
 <20120709122523.GC4627@tiehlicka.suse.cz>
 <20120709141324.GK7315@mudshark.cambridge.arm.com>
 <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
 <20120710094513.GB9108@mudshark.cambridge.arm.com>
 <20120710104234.GI9108@mudshark.cambridge.arm.com>
 <20120711174802.GG13498@mudshark.cambridge.arm.com>
 <20120712111659.GF21013@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712111659.GF21013@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jul 12, 2012 at 12:16:59PM +0100, Michal Hocko wrote:
> On Wed 11-07-12 18:48:02, Will Deacon wrote:
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

Well, the comment in linux/page-flags.h does state that:

 * PG_arch_1 is an architecture specific page state bit.  The generic code
 * guarantees that this bit is cleared for a page when it first is entered into
 * the page cache.

so it's not completely clear cut that the architecture should be responsible
for clearing this bit when allocating pages from the hugepage pool.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
