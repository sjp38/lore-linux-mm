Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7C96B0025
	for <linux-mm@kvack.org>; Sat, 28 May 2011 20:12:43 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4T0CcQj017359
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:12:38 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq6.eem.corp.google.com with ESMTP id p4T0CYjj007002
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:12:37 -0700
Received: by pxi10 with SMTP id 10so1742550pxi.36
        for <linux-mm@kvack.org>; Sat, 28 May 2011 17:12:33 -0700 (PDT)
Date: Sat, 28 May 2011 17:12:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
In-Reply-To: <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils> <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils> <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 28 May 2011, Linus Torvalds wrote:
> On Sat, May 28, 2011 at 3:02 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > But I'm replying before I've given it enough thought,
> > mainly to let you know that I am back on it now.
> 
> So I applied your other two patches as obvious, but not this one.

Thank you, that's right.

Though I think I'm arriving at the conclusion that this patch
is correct as is, despite the doubts that have arisen.

One argument is by induction: since we've noticed no problems before
Peter's patchset, and actually Peter's patchset plus my patch is not
really making any difference to this "anon_vma changing beneath you"
case, is it?

(I've not relooked at what the situation was before his final optimized
page_lock_anon_vma(): maybe that was fine, or maybe it could get into
decrementing a different refcount than had been incremented, if we
didn't have the protection of PageLocked against switching anon_vma.)

> 
> I'm wondering - wouldn't it be nicer to just re-check (after getting
> the anon_vma lock) that page->mapping still matches anon_mapping?

I toyed with that: it seemed a better idea than relying on the refcount,
which wasn't giving the guarantee we needed (the refcount is perfectly
good in other respects, it just isn't good for this particular check).

However, the problem (if there is one) goes a bit further than that:
if we don't actually have serialization against page->anon_vma (okay,
it's actually page->mapping, but simpler to express this way) being
changed at any instant, i.e. we're serving the page_referenced() without
PageLocked case, then what good is the "anon_vma" that page_lock_anon_vma()
returns?  If that can be freed and reused at any moment?

I believe that although it may no longer be the anon_vma that the page
is pointing to, it remains stable.  Because even if page->anon_vma is
updated, it will certainly have the same anon_vma->root as before
(see the first BUG_ON in __page_check_anon_rmap() for reassurance),
so the mutex locking holds good.

And the structure itself won't be freed: although the page is now
pointing to a less inclusive, more optimal anon_vma for reclaim to use,
the anon_vma which was originally pointed to remains on the same vma's
chains as it ever was, and only gets freed up when they're all gone.

So, when there's this race with moving anon_vma, page_lock_anon_vma()
may end up returning a less than optimal anon_vma, but it's still valid
as a good though longer list of vmas to look through.

The previous code would have broken horribly, wouldn't it, were that
not the case?

> 
> That said, I do agree with the "anon_vma_root" part of your patch. I
> just think you mixed up two independent issues with it: the fact that
> we may be unlocking a new root, and the precise check used to
> determine whether the anon_vma might have changed.

It's true that actually I first ran with just the page_mapped() instead
of refcount part of the patch; and was disappointed to find that did not
fix the hang on its own.  Had to spend a few minutes yesterday morning
actually thinking and remembering the root_anon_vma thing.

So to that extent they must be separable; but I'm finding it hard to
agree with putting in a broken half-patch.  And the page_mapped()
part of it is essential.

Let's add Rik to the Cc in case he's around and might comment too.

Hugh

> 
> So my gut feeling is that we should do the "anon_vma" root thing
> independently as a fix for the "maybe anon_vma->root changed" issue,
> and then as a separate patch decide on how to check whether anon_vma
> is still valid.
> 
> Hmm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
