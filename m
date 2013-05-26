Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 432376B003D
	for <linux-mm@kvack.org>; Sat, 25 May 2013 22:50:47 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id ef5so6897710obb.30
        for <linux-mm@kvack.org>; Sat, 25 May 2013 19:50:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
Date: Sun, 26 May 2013 06:50:46 +0400
Message-ID: <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
Subject: TLB and PTE coherency during munmap
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>

Hello arch and mm people.

Is it intentional that threads of a process that invoked munmap syscall
can see TLB entries pointing to already freed pages, or it is a bug?

I'm talking about zap_pmd_range and zap_pte_range:

      zap_pmd_range
        zap_pte_range
          arch_enter_lazy_mmu_mode
            ptep_get_and_clear_full
            tlb_remove_tlb_entry
            __tlb_remove_page
          arch_leave_lazy_mmu_mode
        cond_resched

With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
and __tlb_remove_page there is a loop in the zap_pte_range that clears
PTEs and frees corresponding pages, but doesn't flush TLB, and
surrounding loop in the zap_pmd_range that calls cond_resched. If a thread
of the same process gets scheduled then it is able to see TLB entries
pointing to already freed physical pages.

I've noticed that with xtensa arch when I added a test before returning to
userspace checking that TLB contents agrees with page tables of the
current mm. This check reliably fires with the LTP test mtest05 that
maps, unmaps and accesses memory from multiple threads.

Is there anything wrong in my description, maybe something specific to
my arch, or this issue really exists?

I've also noticed that there are a lot of arches with default implementations
of the involved functions, does that mean that any/all of them have this
issue too?

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
