Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5765F6B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 18:02:32 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4SM2SwC028710
	for <linux-mm@kvack.org>; Sat, 28 May 2011 15:02:30 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq6.eem.corp.google.com with ESMTP id p4SM2Odo002061
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 15:02:26 -0700
Received: by pzk36 with SMTP id 36so1258791pzk.6
        for <linux-mm@kvack.org>; Sat, 28 May 2011 15:02:24 -0700 (PDT)
Date: Sat, 28 May 2011 15:02:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
In-Reply-To: <1306617270.2497.516.camel@laptop>
Message-ID: <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils> <1306617270.2497.516.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 28 May 2011, Peter Zijlstra wrote:
> On Sat, 2011-05-28 at 13:20 -0700, Hugh Dickins wrote:
> > On one machine I've been getting hangs, a page fault's anon_vma_prepare()
> > waiting in anon_vma_lock(), other processes waiting for that page's lock.
> > 
> > This is a replay of last year's f18194275c39
> > "mm: fix hang on anon_vma->root->lock".
> > 
> > The new page_lock_anon_vma() places too much faith in its refcount: when
> > it has acquired the mutex_trylock(), it's possible that a racing task in
> > anon_vma_alloc() has just reallocated the struct anon_vma, set refcount
> > to 1, and is about to reset its anon_vma->root.
> > 
> > Fix this by saving anon_vma->root, and relying on the usual page_mapped()
> > check instead of a refcount check: if page is still mapped, the anon_vma
> > is still ours; if page is not still mapped, we're no longer interested.
> 
> Interesting race.. but can we guarantee that the page didn't get
> remapped meanwhile?

Remapped how?  If migrated, then this page will simply be unmapped,
and another page take its place.

I see now your comment above page_get_anon_vma(), saying the page might
have been remapped to a different anon_vma, but how does tha come about?

Oh, are you referring to page_move_anon_rmap()?  Yikes, I wasn't paying
attention when that came in: in my comfortable little world, once PageAnon
page->mapping is set, it remains constant until the page is freed.

That's long been a given, but now I see, not for the last year.
I'll give some thought to that right now, it's hard to appreciate
the ramifications.  The page lock is held while that move is made,
but I believe there's one (perhaps no more) path to page_lock_anon_vma(),
when checking page_referenced(), when the page is not necessarily locked.

But I'm not even sure if you're referring to page_move_anon_rmap(),
or something else?

> 
> The updated comment by page_get_anon_vma() describes the lack of
> serialization against page_remove_rmap() but fails to mention the
> page_add_anon_rmap cases (bad me, I know I checked at the time, but
> can't for the life of me remember what it was now).

What is the problematic page_add_anon_rmap() case?  Ah, when do_swap_page()
calls do_page_add_anon_rmap() with exclusive 1?  Which is pretty much
equivalent to the page_move_anon_rmap() case, but just from that slightly
different place.

> 
> _IFF_ we are serialized, your patch should suffice, since then
> page_mapped() implies a >0 refcount, if not however, I think we need
> both tests since in that case the page might be mapped again against a
> different anon_vma and our current anon_vma (the one we locked against)
> might have refcount == 0 and already be past the mutex_is_locked() test
> in anon_vma_free(), at which point we're up shit creek since then the
> anon_vma we're returning can disappear the moment we do
> rcu_read_unlock().

I'm not convinced that the refcount helps at all there.  If the page is
now using a different anon_vma than the one it started out with, what
prevents the old one from being freed and reused and now refcount 1?

But I'm replying before I've given it enough thought,
mainly to let you know that I am back on it now.

> 
> Or am I delusional due to lack of sleep?

Congratulations!?

I fear you're not delusional: thank you for catching this.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
