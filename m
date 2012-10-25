Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CA9AA6B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 15:51:23 -0400 (EDT)
Date: Thu, 25 Oct 2012 15:51:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121025195110.GA4771@cmpxchg.org>
References: <1351183471-14710-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351183471-14710-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, peterz@infradead.org, akpm@linux-foundation.org, Chris Metcalf <cmetcalf@tilera.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Oct 25, 2012 at 05:44:31PM +0100, Will Deacon wrote:
> On x86 memory accesses to pages without the ACCESSED flag set result in the
> ACCESSED flag being set automatically. With the ARM architecture a page access
> fault is raised instead (and it will continue to be raised until the ACCESSED
> flag is set for the appropriate PTE/PMD).
> 
> For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> be called for a write fault.
> 
> This patch ensures that faults on transparent hugepages which do not result
> in a CoW update the access flags for the faulting pmd.
> 
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> Ok chaps, I rebased this thing onto today's next (which basically
> necessitated a rewrite) so I've reluctantly dropped my acks and kindly
> ask if you could eyeball the new code, especially where the locking is
> concerned. In the numa code (do_huge_pmd_prot_none), Peter checks again
> that the page is not splitting, but I can't see why that is required.

I don't either.  If the thing was splitting when the fault happened,
that path is not taken.  And the locked pmd_same() check should rule
out splitting setting in after testing pmd_trans_huge_splitting().

Peter?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
