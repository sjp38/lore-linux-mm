Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0CF6B051B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:59:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so1823270wrc.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:59:27 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id a8si19385262edl.470.2017.08.01.03.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 03:59:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 866591C2201
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 11:59:25 +0100 (IST)
Date: Tue, 1 Aug 2017 11:59:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 3/4] mm: fix MADV_[FREE|DONTNEED] TLB flush miss
 problem
Message-ID: <20170801105924.h4u4ocplofdpylh5@techsingularity.net>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1501566977-20293-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>

On Tue, Aug 01, 2017 at 02:56:16PM +0900, Minchan Kim wrote:
> Nadav reported parallel MADV_DONTNEED on same range has a stale TLB
> problem and Mel fixed it[1] and found same problem on MADV_FREE[2].
> 
> Quote from Mel Gorman
> 
> "The race in question is CPU 0 running madv_free and updating some PTEs
> while CPU 1 is also running madv_free and looking at the same PTEs.
> CPU 1 may have writable TLB entries for a page but fail the pte_dirty
> check (because CPU 0 has updated it already) and potentially fail to flush.
> Hence, when madv_free on CPU 1 returns, there are still potentially writable
> TLB entries and the underlying PTE is still present so that a subsequent write
> does not necessarily propagate the dirty bit to the underlying PTE any more.
> Reclaim at some unknown time at the future may then see that the PTE is still
> clean and discard the page even though a write has happened in the meantime.
> I think this is possible but I could have missed some protection in madv_free
> that prevents it happening."
> 
> This patch aims for solving both problems all at once and is ready for
> other problem with KSM, MADV_FREE and soft-dirty story[3].
> 
> TLB batch API(tlb_[gather|finish]_mmu] uses [inc|dec]_tlb_flush_pending
> and mmu_tlb_flush_pending so that when tlb_finish_mmu is called, we can catch
> there are parallel threads going on. In that case, forcefully, flush TLB
> to prevent for user to access memory via stale TLB entry although it fail
> to gather page table entry.
> 
> I confiremd this patch works with [4] test program Nadav gave so this patch
> supersedes "mm: Always flush VMA ranges affected by zap_page_range v2"
> in current mmotm.
> 
> NOTE:
> This patch modifies arch-specific TLB gathering interface(x86, ia64,
> s390, sh, um). It seems most of architecture are straightforward but s390
> need to be careful because tlb_flush_mmu works only if mm->context.flush_mm
> is set to non-zero which happens only a pte entry really is cleared by
> ptep_get_and_clear and friends. However, this problem never changes the
> pte entries but need to flush to prevent memory access from stale tlb.
> 
> Any thoughts?
> 

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
