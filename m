Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E2EA26B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 06:14:00 -0400 (EDT)
Date: Fri, 26 Oct 2012 13:15:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121026101520.GA1284@shutemov.name>
References: <1351183471-14710-1-git-send-email-will.deacon@arm.com>
 <20121026074435.GA871@shutemov.name>
 <20121026090715.GB20914@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121026090715.GB20914@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "peterz@infradead.org" <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Oct 26, 2012 at 10:07:15AM +0100, Will Deacon wrote:
> On Fri, Oct 26, 2012 at 08:44:35AM +0100, Kirill A. Shutemov wrote:
> > On Thu, Oct 25, 2012 at 05:44:31PM +0100, Will Deacon wrote:
> > > On x86 memory accesses to pages without the ACCESSED flag set result in the
> > > ACCESSED flag being set automatically. With the ARM architecture a page access
> > > fault is raised instead (and it will continue to be raised until the ACCESSED
> > > flag is set for the appropriate PTE/PMD).
> > > 
> > > For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> > > setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> > > be called for a write fault.
> > > 
> > > This patch ensures that faults on transparent hugepages which do not result
> > > in a CoW update the access flags for the faulting pmd.
> > > 
> > > Cc: Chris Metcalf <cmetcalf@tilera.com>
> > > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > > ---
> > > 
> > > Ok chaps, I rebased this thing onto today's next (which basically
> > > necessitated a rewrite) so I've reluctantly dropped my acks and kindly
> > > ask if you could eyeball the new code, especially where the locking is
> > > concerned. In the numa code (do_huge_pmd_prot_none), Peter checks again
> > > that the page is not splitting, but I can't see why that is required.
> > 
> > In handle_mm_fault() we check if the pmd is under splitting without
> > page_table_lock. It's kind of speculative cheap check. We need to re-check
> > if the PMD is really not under splitting after taking page_table_lock.
> 
> I appreciate the need to check whether the thing is splitting, but I thought
> that the pmd_same(*pmd, orig_pmd) check after taking the page_table_lock
> would be sufficient, because we know that the entry hasn't changed and that
> it wasn't splitting before we took the lock. This also mirrors the approach
> taken by do_huge_pmd_wp_page.
> 
> Is there something I'm missing?

Hm.. You're correct from my POV.

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

I think the check in do_huge_pmd_prot_none() is redundant. It only add
latency. I'll prepare patch to remove it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
