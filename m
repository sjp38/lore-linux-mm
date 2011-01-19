Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 907DF8D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 12:10:35 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 19 Jan 2011 18:10:39 +0100
Message-ID: <1295457039.28776.137.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-17 at 23:12 -0800, Hugh Dickins wrote:

> However, there's one more-than-cleanup that I think you will need to add:
> the ZAP_BLOCK_SIZE zap_work stuff is still there, but I think it needs
> to be removed now, with the need_resched() and other checks moved down
> from unmap_vmas() to inside the pagetable spinlock in zap_pte_range().
>=20
> Because you're now accumulating more work than ever in the mmu_gather's
> buffer, and the more so with the 20/21 extended list: but this amounts
> to a backlog of work which will *usually* be done at the tlb_finish_mmu,
> but when memory is low (no extra buffers) may need flushing earlier -
> as things stand, while holding the pagetable spinlock, so introducing
> a large unpreemptible latency under those conditions.
>=20
> I believe that along with the need_resched() check moved inside
> zap_pte_range(), you need to check if the mmu_gather buffer is full,
> and if so drop pagetable spinlock while you flush it.  Hmm, but if
> it's extensible, then it wasn't full: I've not worked out how this
> would actually fit together.

Very good point!! I'll work on this, I'll probably do a few of those
cleanups previously left undone too, I'm seriously doubting the
usefulness of the whole restart_addr muck now that its preemptible.

> (I also believe that when memory is low, we *ought* to be freeing up
> the pages sooner: perhaps all the GFP_ATOMICs should be GFP_NOWAITs.)

Agreed, I've moved everything to: GFP_NOWAIT | __GFP_NOWARN.=20

> I found patch ordering a bit odd: I'm going to comment on them in
> what seems a more natural ordering to me: if Andrew folds your 00
> comments into 01 as he usually does, then I'd rather see them on the
> main preemptible mmu_gather patch, than on reverting some anon_vma
> annotations!=20

Shouldn't we simply ask for better changelogs instead of Andrew doing
that? That said, I do like your order better, so did indeed reorder as
you suggest.

>  And with anon_vma->lock already nested inside i_mmap_lock,
> I think the anon_vma mods are secondary, and can just follow after.
>=20
> 08/21 mm-preemptible_mmu_gather.patch
>       Acked-by: Hugh Dickins <hughd@google.com>
>       But I'd prefer __tlb_alloc_pages() be named __tlb_alloc_page(),
>       and think it should pass __GFP_NOWARN with its GFP_ATOMIC (same
>       remark would apply in several other patches too).

Did the rename, and like mentioned, switched to GFP_NOWAIT |
__GFP_NOWARN for everything.

> 09/21 powerpc-preemptible_mmu_gather.patch
>       I'll leave Acking to Ben, but it looked okay so far as I could tell=
