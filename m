Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCAD46B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 21:20:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 54so6115340qtq.19
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 18:20:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y128si11893367qka.241.2017.10.03.18.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 18:20:22 -0700 (PDT)
Date: Tue, 3 Oct 2017 21:20:16 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/mmu_notifier: avoid double notification when it is
 useless
Message-ID: <20171004012016.GE20644@redhat.com>
References: <20170901173011.10745-1-jglisse@redhat.com>
 <20171003234215.GA5231@redhat.com>
 <20171004001559.GD20644@redhat.com>
 <0D64494B-AB3D-4091-B75A-883EA37BE098@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0D64494B-AB3D-4091-B75A-883EA37BE098@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

On Tue, Oct 03, 2017 at 05:43:47PM -0700, Nadav Amit wrote:
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > On Wed, Oct 04, 2017 at 01:42:15AM +0200, Andrea Arcangeli wrote:
> > 
> >> I'd like some more explanation about the inner working of "that new
> >> user" as per comment above.
> >> 
> >> It would be enough to drop mmu_notifier_invalidate_range from above
> >> without adding it to the filebacked case. The above gives higher prio
> >> to the hypothetical and uncertain future case, than to the current
> >> real filebacked case that doesn't need ->invalidate_range inside the
> >> PT lock, or do you see something that might already need such
> >> ->invalidate_range?
> > 
> > No i don't see any new user today that might need such invalidate but
> > i was trying to be extra cautious as i have a tendency to assume that
> > someone might do a patch that use try_to_unmap() without going through
> > all the comments in the function and thus possibly using it in a an
> > unexpected way from mmu_notifier callback point of view. I am fine
> > with putting the burden on new user to get it right and adding an
> > extra warning in the function description to try to warn people in a
> > sensible way.
> 
> I must be missing something. After the PTE is changed, but before the
> secondary TLB notification/invalidation - What prevents another thread from
> changing the mappings (e.g., using munmap/mmap), and setting a new page
> at that PTE?
> 
> Wouldna??t it end with the page being mapped without a secondary TLB flush in
> between?

munmap would call mmu_notifier to invalidate the range too so secondary
TLB would be properly flush before any new pte can be setup in for that
particular virtual address range. Unlike CPU TLB flush, secondary TLB
flush are un-conditional and thus current pte value does not play any
role.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
