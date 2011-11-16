Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EBB386B0072
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 09:00:50 -0500 (EST)
Date: Wed, 16 Nov 2011 15:00:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111116140042.GD3306@redhat.com>
References: <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <20111104235603.GT18879@redhat.com>
 <CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
 <20111105013317.GU18879@redhat.com>
 <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
 <20111107131413.GA18279@suse.de>
 <20111107154235.GE3249@redhat.com>
 <20111107162808.GA3083@suse.de>
 <20111109012542.GC5075@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109012542.GC5075@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nai Xia <nai.xia@gmail.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wed, Nov 09, 2011 at 02:25:42AM +0100, Andrea Arcangeli wrote:
> Also note, if we find a way to enforce orderings in the prio tree (not
> sure if it's possible, apparently it's already using list_add_tail
> so..), then we could also remove the i_mmap_lock from mremap and fork.

I'm not optimistic we can enforce ordering there. Being a tree it's
walked in range order.

I thought of another solution that would avoid having to reorder the
list in mremap and avoid the i_mmap_mutex to be added to fork (and
then we can remove it from mremap too). The solution is to rmap_walk
twice. I mean two loops over the same_anon_vma for those rmap walks
that must be reliable (that includes two calls of
unmap_mapping_range). For both same_anon_vma and prio tree.

Reading truncate_pagecache I see two loops already and a comment
saying it's for fork(), to avoid leaking ptes in the child. So fork is
probably ok already without having to take the i_mmap_mutex, but then
I wonder why that also doesn't fix mremap if we do two loops there and
why that i_mmap_mutex is really needed in mremap considering those two
calls already present in truncate_pagecache. I wonder if that was a
"theoretical" fix that missed the fact truncate already walks the prio
tree twice, so it doesn't matter if the rmap_walk goes in the opposite
direction of move_page_tables? That i_mmap_lock in mremap (now
i_mmap_mutex) is there since start of git history. The double loop was
introduced in d00806b183152af6d24f46f0c33f14162ca1262a. So it's very
possible that i_mmap_mutex is now useless (after
d00806b183152af6d24f46f0c33f14162ca1262a) and the fix for fork, was
already taking care of mremap too and that i_mmap_mutex can now be
removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
