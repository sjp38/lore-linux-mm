Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 476316B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 23:07:32 -0400 (EDT)
Date: Sat, 5 Nov 2011 04:07:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111105030718.GV18879@redhat.com>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
 <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
 <alpine.LSU.2.00.1111041158440.1554@sister.anvils>
 <20111104205440.GP18879@redhat.com>
 <CAPQyPG5RgPnN-kVc1Oy+78mAa9vevLiZWCwx2pEkeHKY1t6V1A@mail.gmail.com>
 <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nai Xia <nai.xia@gmail.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 04, 2011 at 07:21:28PM -0700, Hugh Dickins wrote:
> I found Andrea's "anon_vma_merge" reply very hard to understand; but
> it looks like he now accepts that it was mistaken, or on the wrong
> track at least...

No matter how we get the order right, we still need to reverse the
order in case of error without taking the lock. So even allocating a
new vma every time wouldn't be enough to get out of the ordering
games (it would be enough in the non-error path of course...).

So there are a couple of ways:

1) Keep my patch (adjust comment) and add a second ordering call in
   the error path. Cleanup the *vmap case.

2) Always allocate a new vma, merge later, and still keep my patch for
   reversing the order in the error path only (not an huge improvement
   if we still have to reverse the order). So this now looks the worst
   option at the light of the error path which would give
   trouble by going the opposite way... again.

3) Return to your fix that takes the anon_vma lock during the pte
   moves

Fixing my patch requires just a one liner to fix the error path, it's
not like the patch was wrong in fact it reduced the window even more,
it just missed one liner in the error path.

But it's still doing reordering. Which I think is safe and not
fundamentally different in ordering terms by the old anon_vma logic
before _chain (which is why this bug could have triggered before
too). But certainly more complex than taking the anon_vma lock around
every pagetable move, that's for sure. fork will still relay on the
ordering but fork has a super easy life compared to mremap which goes
both ways and has vma_merge in it too which makes the vma order non
deterministic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
