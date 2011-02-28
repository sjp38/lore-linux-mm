Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DBD508D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 09:19:21 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1298893487.2428.10537.camel@twins>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>
	 <1298657083.2428.2483.camel@twins>
	 <20110225215123.GA10026@flint.arm.linux.org.uk>
	 <1298893487.2428.10537.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Feb 2011 15:18:47 +0100
Message-ID: <1298902727.2428.10867.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, 2011-02-28 at 12:44 +0100, Peter Zijlstra wrote:
>   unmap_region()
>     tlb_gather_mmu()
>     unmap_vmas()
>       for (; vma; vma =3D vma->vm_next)
>         unmao_page_range()
>           tlb_start_vma() -> flush cache range

So why is this correct? Can't we race with a concurrent access to the
memory region (munmap() vs other thread access race)? While
unmap_region() callers will have removed the vma from the tree so faults
will not be satisfied, TLBs might still be present and allow us to
access the memory and thereby reloading it in the cache.

>           zap_*_range()
>             ptep_get_and_clear_full() -> batch/track external tlbs
>             tlb_remove_tlb_entry() -> batch/track external tlbs
>             tlb_remove_page() -> track range/batch page
>           tlb_end_vma() -> flush tlb range
>=20
>  [ for architectures that have hardware page table walkers
>    concurrent faults can still load the page tables ]
>=20
>     free_pgtables()
>       while (vma)
>         unlink_*_vma()
>         free_*_range()
>           *_free_tlb()
>     tlb_finish_mmu()
>=20
>   free vmas=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
