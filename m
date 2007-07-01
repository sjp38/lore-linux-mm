Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l617DmCX1628428
	for <linux-mm@kvack.org>; Sun, 1 Jul 2007 07:13:48 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l617DmRH2166808
	for <linux-mm@kvack.org>; Sun, 1 Jul 2007 09:13:48 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l617DmfQ013646
	for <linux-mm@kvack.org>; Sun, 1 Jul 2007 09:13:48 +0200
Subject: Re: [patch 5/5] Optimize page_mkclean_one
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0706301448450.13752@blonde.wat.veritas.com>
References: <20070629135530.912094590@de.ibm.com>
	 <20070629141528.511942868@de.ibm.com>
	 <Pine.LNX.4.64.0706301448450.13752@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Sun, 01 Jul 2007 09:15:53 +0200
Message-Id: <1183274153.15924.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2007-06-30 at 15:04 +0100, Hugh Dickins wrote:
> > Oh yes, the dirty handling is tricky. I had to fix a really nasty bug
> > with it lately. As for page_mkclean_one the difference is that it
> > doesn't claim a page is dirty if only the write protect bit has not been
> > set. If we manage to lose dirty bits from ptes and have to rely on the
> > write protect bit to take over the job, then we have a different problem
> > altogether, no ?
> 
> [Moving that over from 1/5 discussion].
> 
> Expect you're right, but I _really_ don't want to comment, when I don't
> understand that "|| pte_write" in the first place, and don't know the
> consequence of pte_dirty && !pte_write or !pte_dirty && pte_write there.

The pte_write() part is for the shared dirty page tracking. If you want
to make sure that a max of x% of your pages are dirty then you cannot
allow to have more than x% to be writable. Thats why page_mkclean_one
clears the dirty bit and makes the page read-only.

> My suspicion is that the "|| pte_write" is precisely to cover your
> s390 case where pte is never dirty (it may even have been me who got
> Peter to put it in for that reason).  In which case your patch would
> be fine - though I think it'd be improved a lot by a comment or
> rearrangement or new macro in place of the pte_dirty || pte_write
> line (perhaps adjust my pte_maybe_dirty in asm-generic/pgtable.h,
> and use that - its former use in msync has gone away now).

No, s390 is covered by the page_test_dirty / page_clear_dirty pair in
page_mkclean. 

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
