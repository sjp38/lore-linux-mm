Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m5386Rtr239398
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 08:06:27 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m5386RcS4038750
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 10:06:27 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5386RwX031418
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 10:06:27 +0200
Subject: Re: [PATCH] Optimize page_remove_rmap for anon pages
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <200806030957.49069.nickpiggin@yahoo.com.au>
References: <1212069392.16984.25.camel@localhost>
	 <200806030957.49069.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 10:06:03 +0200
Message-Id: <1212480363.7746.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 09:57 +1000, Nick Piggin wrote:

First of all: thanks for looking into this. Games with the dirty bit are
scary and any change needs careful consideration.

> I don't know if it is that simple, is it?

It should be analog to the fact that for the two place the page_zap_rmap
function is supposed to be used the pte dirty bit isn't checked as well.

> I don't know how you are guaranteeing the given page ceases to exist.
> Even checking for the last mapper of the page (which you don't appear
> to do anyway) isn't enough because there could be a swapcount, in which
> case you should still have to mark the page as dirty.
> 
> For example (I think, unless s390 somehow propogates the dirty page
> bit some other way that I've missed), wouldn't the following break:
> 
> process p1 allocates anonymous page A
> p1 dirties A
> p1 forks p2, A now has a mapcount of 2
> p2 VM_LOCKs A (something to prevent it being swapped)
> page reclaim unmaps p1's pte, fails on p2
> p2 exits, page_dirty does not get checked because of this patch
> page has mapcount 0, PG_dirty is clear
> Page reclaim can drop it without writing it to swap

Indeed, this would break. Even without the VM_LOCK there is a race of
try_to_unmap vs. process exit. 

> As far as the general idea goes, it might be possible to avoid the
> check somehow, but you'd want to be pretty sure of yourself before
> diverging the s390 path further from the common code base, no?

I don't want to diverge more than necessary. But the performance gains
of the SSKE/ISKE avoidance makes it worthwhile for s390, no?

> The "easy" way to do it might be just unconditionally mark the page
> as dirty in this path (if the pte was writeable), so you can avoid
> the page_test_dirty check and be sure of not missing the dirty bit.

Hmm, but then an mprotect() can change the pte to read-ony and we'd miss
the dirty bit again. Back to the drawing board.

By the way there is another SSKE I want to get rid of: __SetPageUptodate
does a page_clear_dirty(). For all uses of __SetPageUptodate the page
will be dirty after the application did its first write. To clear the
page dirty bit only to have it set again shortly after doesn't make much
sense to me. Has there been any particular reason for the
page_clear_dirty in __SetPageUptodate ?

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
