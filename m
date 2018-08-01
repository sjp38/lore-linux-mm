Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7263A6B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 14:32:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so7018699pfo.23
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 11:32:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g34-v6sor5405475pld.68.2018.08.01.11.32.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 11:32:02 -0700 (PDT)
Date: Wed, 1 Aug 2018 11:31:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Linux 4.18-rc7
In-Reply-To: <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1808011042090.14313@eggly.anvils>
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com> <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com> <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com> <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com> <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com> <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk> <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, 1 Aug 2018, Linus Torvalds wrote:
> 
> Anyway, the upshot of all this is that I think I know what the ia64
> problem was, and John sent the patch for the ashmem case, and I'm
> going to hold off reverting that vma_is_anonymous() false-positives
> commit after all.

I'd better send deletion of zap_pmd_range()'s VM_BUG_ON_VMA(): below
(but I've no proprietorial interest, if you prefer to do your own).

John's patch is good, and originally I thought it was safe from that
VM_BUG_ON_VMA(), because the /dev/ashmem fd exposed to the user is
disconnected from the vm_file in the vma, and madvise(,,MADV_REMOVE)
insists on VM_SHARED. But afterwards read John's earlier mail,
drawing attention to the vfs_fallocate() in there: I may be wrong,
and I don't know if Android has THP in the config anyway, but it looks
to me like an unmap_mapping_range() from ashmem's vfs_fallocate()
could hit precisely the VM_BUG_ON_VMA(), once it's vma_is_anonymous().

(I'm not familiar with ashmem, and I certainly don't understand the
role of MAP_PRIVATE ashmem mappings - hole-punch's zap_pte_range()
should end up leaving any anon pages in place; but the presence of
the BUG is requiring us all to understand too much too quickly.)


[PATCH] mm: delete historical BUG from zap_pmd_range()

Delete the old VM_BUG_ON_VMA() from zap_pmd_range(), which asserted
that mmap_sem must be held when splitting an "anonymous" vma there.
Whether that's still strictly true nowadays is not entirely clear,
but the danger of sometimes crashing on the BUG is now fairly clear.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memory.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- 4.18-rc7/mm/memory.c	2018-06-16 18:48:22.041173422 -0700
+++ linux/mm/memory.c	2018-08-01 11:01:21.397286507 -0700
@@ -1417,11 +1417,9 @@ static inline unsigned long zap_pmd_rang
 	do {
 		next = pmd_addr_end(addr, end);
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
-				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+			if (next - addr != HPAGE_PMD_SIZE)
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
-			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
+			else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
 			/* fall through */
 		}
