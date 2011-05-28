Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E01556B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:11:08 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QQQn3-0001FA-Hr
	for linux-mm@kvack.org; Sat, 28 May 2011 21:11:21 +0000
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 28 May 2011 23:14:30 +0200
Message-ID: <1306617270.2497.516.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-05-28 at 13:20 -0700, Hugh Dickins wrote:
> On one machine I've been getting hangs, a page fault's anon_vma_prepare()
> waiting in anon_vma_lock(), other processes waiting for that page's lock.
> 
> This is a replay of last year's f18194275c39
> "mm: fix hang on anon_vma->root->lock".
> 
> The new page_lock_anon_vma() places too much faith in its refcount: when
> it has acquired the mutex_trylock(), it's possible that a racing task in
> anon_vma_alloc() has just reallocated the struct anon_vma, set refcount
> to 1, and is about to reset its anon_vma->root.
> 
> Fix this by saving anon_vma->root, and relying on the usual page_mapped()
> check instead of a refcount check: if page is still mapped, the anon_vma
> is still ours; if page is not still mapped, we're no longer interested.

Interesting race.. but can we guarantee that the page didn't get
remapped meanwhile?

The updated comment by page_get_anon_vma() describes the lack of
serialization against page_remove_rmap() but fails to mention the
page_add_anon_rmap cases (bad me, I know I checked at the time, but
can't for the life of me remember what it was now).

_IFF_ we are serialized, your patch should suffice, since then
page_mapped() implies a >0 refcount, if not however, I think we need
both tests since in that case the page might be mapped again against a
different anon_vma and our current anon_vma (the one we locked against)
might have refcount == 0 and already be past the mutex_is_locked() test
in anon_vma_free(), at which point we're up shit creek since then the
anon_vma we're returning can disappear the moment we do
rcu_read_unlock().

Or am I delusional due to lack of sleep?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
