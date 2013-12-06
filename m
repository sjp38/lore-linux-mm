Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id AAC956B0039
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:24:04 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so161746eek.5
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:24:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si35102825eeo.11.2013.12.06.01.24.03
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 01:24:03 -0800 (PST)
Date: Fri, 6 Dec 2013 09:24:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131206092400.GJ11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-15-git-send-email-mgorman@suse.de>
 <529E641A.7040804@redhat.com>
 <20131203234637.GS11295@suse.de>
 <529F3D51.1090203@redhat.com>
 <20131204160741.GC11295@suse.de>
 <20131205104015.716ed0fe@annuminas.surriel.com>
 <20131205195446.GI11295@suse.de>
 <52A0DC7F.7050403@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52A0DC7F.7050403@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On Thu, Dec 05, 2013 at 03:05:19PM -0500, Rik van Riel wrote:
> On 12/05/2013 02:54 PM, Mel Gorman wrote:
> 
> >I think that's a better fit and a neater fix. Thanks! I think it barriers
> >more than it needs to (definite cost vs maybe cost), the flush can be
> >deferred until we are definitely trying to migrate and the pte case is
> >not guaranteed to be flushed before migration due to pte_mknonnuma causing
> >a flush in ptep_clear_flush to be avoided later. Mashing the two patches
> >together yields this.
> 
> I think this would fix the numa migrate case.
> 

Good. So far I have not been seeing any problems with it at least.

> However, I believe the same issue is also present in
> mprotect(..., PROT_NONE) vs. compaction, for programs
> that trap SIGSEGV for garbage collection purposes.
> 

I'm not 100% convinced we need to be concerned with races with
mprotect(PROT_NONE) and a parallel reference to that area from userspace. I
would consider it to be a buggy application if two threads were not
co-ordinating the protection of a region and referencing it.  I would also
expect garbage collectors to be managing smart pointers and using reference
counting to copy between heap generations (or similar mechanisms) instead
of trapping sigsegv.

Intel's architectural manual 3A covers what happens for delayed TLB
invalidations in section 4.10.4.4 (in the version I'm looking at at
least). The following two snippets are the most important

	Software developers should understand that, between the modification
	of a paging-structure entry and execution of the invalidation
	instruction recommended in Section 4.10.4.2, the processor may
	use translations based on either the old value or the new value
	of the paging- structure entry. The following items describe some
	of the potential consequences of delayed invalidation:

	o If a paging-structure entry is modified to change from 1 to 0 the P
	flag from 1 to 0, an access to a linear address whose translation is
	controlled by this entry may or may not cause a page-fault exception.

	o If a paging-structure entry is modified to change the R/W flag
	from 0 to 1, write accesses to linear addresses whose translation is
	controlled by this entry may or may not cause a page-fault exception.

After the PROT_NONE may happen until after the deferred TLB flush. In a
race with mprotect(PROT_NONE) it'll either complete the access or receive
SIGSEGV signal due to failed protections but this is pretty much
expected and unpredictable.

I do not think the present bit gets cleared on mprotect(PROT_NONE) due
to the relevant bits been

#define _PAGE_CHG_MASK  (PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT | \
                         _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)
#define PAGE_NONE   __pgprot(_PAGE_PROTNONE | _PAGE_ACCESSED)

If the present bit remains then compaction should flush the TLB on the
call to ptep_clear_flush as pte_accessible check is based on the present
bit. So even though it is possible for a write to complete during a call
to mprotect(PROT_NONE), the same is not true for compaction.

> They could lose modifications done in-between when
> the pte was set to PROT_NONE, and the actual TLB
> flush, if compaction moves the page around in-between
> those two events.
> 
> I don't know if this is a case we need to worry about
> at all, but I think the same fix would apply to that
> code path, so I guess we might as well make it...

I might be going "la la la la we're fine" and deluding myself but we
appear to be covered here and it would be a shame to add expense to a
path unnecessarily.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
