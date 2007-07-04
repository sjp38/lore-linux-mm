Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l647ZYfg1647766
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 07:35:34 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l647ZXF81925216
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 09:35:34 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l647ZWQ7010073
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 09:35:32 +0200
Subject: Re: [patch 1/5] avoid tlb gather restarts.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0707031829390.2111@blonde.wat.veritas.com>
References: <20070703111822.418649776@de.ibm.com>
	 <20070703121228.254110263@de.ibm.com>
	 <Pine.LNX.4.64.0707031829390.2111@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 04 Jul 2007 09:37:51 +0200
Message-Id: <1183534671.1208.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-03 at 18:42 +0100, Hugh Dickins wrote:
> > If need_resched() is false in the inner loop of unmap_vmas it is
> > unnecessary to do a full blown tlb_finish_mmu / tlb_gather_mmu for
> > each ZAP_BLOCK_SIZE ptes. Do a tlb_flush_mmu() instead. That gives
> > architectures with a non-generic tlb flush implementation room for
> > optimization. The tlb_flush_mmu primitive is a available with the
> > generic tlb flush code, the ia64_tlb_flush_mm needs to be renamed
> > and a dummy function is added to arm and arm26.
> > 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Acked-by: Hugh Dickins <hugh@veritas.com>
> 
> (Looking at it, I see that we could argue that there ought to be a
> need_resched() etc. check after your tlb_flush_mmu() in unmap_vmas,
> in case it's spent a long while in there on some arches; but I don't
> think we have the ZAP_BLOCK_SIZE tuned with any great precision, and
> you'd at worst be doubling the latency there, so let's not worry
> about it.  I write this merely in order to reserve myself an
> "I told you so" if anyone ever notices increased latency ;)

Hmm, we'd have to repeat the longish if statement to make sure we don't
miss a cond_resched after tlb_flush_mmu. I'd rather not do that.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
