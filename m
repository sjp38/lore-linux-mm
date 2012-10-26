Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 14F886B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 05:34:15 -0400 (EDT)
Date: Fri, 26 Oct 2012 10:34:08 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121026093407.GD20914@mudshark.cambridge.arm.com>
References: <1351183471-14710-1-git-send-email-will.deacon@arm.com>
 <508A2B8B.7020608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508A2B8B.7020608@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "peterz@infradead.org" <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Oct 26, 2012 at 07:19:55AM +0100, Ni zhan Chen wrote:
> On 10/26/2012 12:44 AM, Will Deacon wrote:
> > On x86 memory accesses to pages without the ACCESSED flag set result in the
> > ACCESSED flag being set automatically. With the ARM architecture a page access
> > fault is raised instead (and it will continue to be raised until the ACCESSED
> > flag is set for the appropriate PTE/PMD).
> >
> > For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> > setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> > be called for a write fault.
> >
> > This patch ensures that faults on transparent hugepages which do not result
> > in a CoW update the access flags for the faulting pmd.
> 
> Could you write changlog?

>From v2? I included something below my SoB. The code should do exactly the
same as before, it's just rebased onto next so that I can play nicely with
Peter's patches.

> >
> > Cc: Chris Metcalf <cmetcalf@tilera.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > ---
> >
> > Ok chaps, I rebased this thing onto today's next (which basically
> > necessitated a rewrite) so I've reluctantly dropped my acks and kindly
> > ask if you could eyeball the new code, especially where the locking is
> > concerned. In the numa code (do_huge_pmd_prot_none), Peter checks again
> > that the page is not splitting, but I can't see why that is required.
> >
> > Cheers,
> >
> > Will
> 
> Could you explain why you not call pmd_trans_huge_lock to confirm the 
> pmd is splitting or stable as Andrea point out?

The way handle_mm_fault is now structured after the numa changes means that
we only enter the huge pmd page aging code if the entry wasn't splitting
before taking the lock, so it seemed a bit gratuitous to jump through those
hoops again in pmd_trans_huge_lock.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
