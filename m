Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 805776B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 15:15:39 -0400 (EDT)
Date: Wed, 11 Mar 2009 20:15:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311191526.GN27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311182216.GJ27823@random.random> <20090311190655.GA690@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311190655.GA690@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 08:06:55PM +0100, Ingo Molnar wrote:
> Good - i saw the '(fast-)gup fix' qualifier and fast-gup is a 
> fresh feature. If the problem existed in earlier kernels too 
> then i guess it isnt urgent.

It always existed yes. The reason of the (fast-) qualifier is because
gup-fast made it harder to fix this in mainline (there is also a patch
floating around for 2.6.18 based kernels that is simpler thanks to
gup-fast not being there). The trouble of gup-fast is that doing the
check of page_count inside PT lock (or mmap_sem write mode like in
fork(), but ksm only takes mmap_sem in read mode and it relied on PT
lock only) wasn't enough anymore to be sure the page_count wouldn't
increase from under us just after we read it, because a gup-fast could
be running in another CPU without mmap_sem and without PT lock
taken. So fixing this on mainline has been a bit harder as I had to
prevent gup-fast to go ahead in the fast path, in a way that didn't
send IPIs to flush the smp-tlb before reading the page_count (so to
avoid sending IPIs for every anon page mapped writeable).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
