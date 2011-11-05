Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6FF986B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 21:33:30 -0400 (EDT)
Date: Sat, 5 Nov 2011 02:33:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111105013317.GU18879@redhat.com>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <20111104235603.GT18879@redhat.com>
 <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Sat, Nov 05, 2011 at 08:21:03AM +0800, Nai Xia wrote:
> copy_vma() ---> rmap_walk() scan dst VMA --> move_page_tables() moves src to dst
> --->  rmap_walk() scan src VMA.  :D

Hmm yes. I think I got in the wrong track because I focused too much
on that line you started talking about, the *vmap = new_vma, you said
I had to reorder stuff there too, and that didn't make sense.

The reason it doesn't make sense is that it can't be ok to reorder
stuff when *vmap = new_vma (i.e. new_vma = old_vma). So if I didn't
need to reorder in that case I thought I could extrapolate it was
always ok.

But the opposite is true: that case can't be solved.

Can it really happen that vma_merge will pack (prev_vma, new_range,
old_vma) together in a single vma? (i.e. prev_vma extended to
old_vma->vm_end)

Even if there's no prev_vma in the picture (but that's the extreme
case) it cannot be safe: i.e. a (new_range, old_vma) or (old_vma,
new_range).

1 single "vma" for src and dst virtual ranges, means 1 single
vma->vm_pgoff. But we've two virtual addresses and two ptes. So the
same page->index can't work for both if the vma->vm_pgoff is the
same.

So regardless of the ordering here we're dealing with something more
fundamental.

If rmap_walk runs immediately after vma_merge completes and releases
the anon_vma_lock, it won't find any pte in the vma anymore. No matter
the order.

I thought at this before and I didn't mention it but at the light of
the above issue I start to think this is the only possible correct
solution to the problem. We should just never call vma_merge before
move_page_tables. And do the merge by hand later after mremap is
complete.

The only safe way to do it is to have _two_ different vmas, with two
different ->vm_pgoff. Then it will work. And by always creating a new
vma we'll always have it queued at the end, and it'll be safe for the
same reasons fork is safe.

Always allocate a new vma, and then after the whole vma copy is
complete, look if we can merge and free some vma. After the fact, so
it means we can't use vma_merge anymore. vma_merge assumes the
new_range is "virtual" and no vma is mapped there I think. Anyway
that's an implementation issue. In some unlikely case we'll allocate 1
more vma than before, and we'll free it once mremap is finished, but
that's small problem compared to solving this once and for all.

And that will fix it without ordering games and it'll fix the *vmap=
new_vma case too. That case really tripped on me as I was assuming
*that* was correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
