Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DA5F76B0129
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:27:55 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so3498480pab.1
        for <linux-mm@kvack.org>; Thu, 08 May 2014 16:27:55 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ef1si1211246pbc.386.2014.05.08.16.27.53
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 16:27:54 -0700 (PDT)
Date: Fri, 9 May 2014 08:29:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
Message-ID: <20140508232959.GB25951@bbox>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
 <20140508055852.GD5282@bbox>
 <536BB931.7070902@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536BB931.7070902@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 08, 2014 at 10:04:49AM -0700, John Stultz wrote:
> On 05/07/2014 10:58 PM, Minchan Kim wrote:
> > On Tue, Apr 29, 2014 at 02:21:19PM -0700, John Stultz wrote:
> >> Another few weeks and another volatile ranges patchset...
> >>
> >> After getting the sense that the a major objection to the earlier
> >> patches was the introduction of a new syscall (and its somewhat
> >> strange dual length/purged-bit return values), I spent some time
> >> trying to rework the vma manipulations so we can be we won't fail
> >> mid-way through changing volatility (basically making it atomic).
> >> I think I have it working, and thus, there is no longer the
> >> need for a new syscall, and we can go back to using madvise()
> >> to set and unset pages as volatile.
> > As I said reply as other patch's reply, I'm ok with this but I'd
> > like to make it clear to support zero-filled page as well as SIGBUS.
> > If we want to use madvise, maybe we need another advise flag like
> > MADV_VOLATILE_SIGBUS.
> 
> I still disagree that zero-fill is more obvious behavior. And again, I
> still support MADV_VOLATILE and MADV_FREE both being added, as they
> really do have different use cases that I'd rather not try to fit into
> one operation.

As I replied previous mail, MADV_FREE is one-shot operation so upcoming
faulted page couldn't be affected so caller should call the syscall again
sometime to make the range volatile again and MADV_FREE is O(N) so vrange
with zero-fill could avoid that totally.

> 
> 
> >>
> >> New changes are:
> >> ----------------
> >> o Reworked vma manipulations to be be atomic
> >> o Converted back to using madvise() as syscall interface
> >> o Integrated fix from Minchan to avoid SIGBUS faulting race
> >> o Caught/fixed subtle use-after-free bug w/ vma merging
> >> o Lots of minor cleanups and comment improvements
> >>
> >>
> >> Still on the TODO list
> >> ----------------------------------------------------
> >> o Sort out how best to do page accounting when the volatility
> >>   is tracked on a per-mm basis.
> > What's is your concern about page accouting?
> > Could you elaborate it more for everybody to understand your concern
> > clearly.
> 
> Basically the issue is that since we keep the volatility in the vma,
> when we mark a page as volatile, its only marking the page for that
> processes, not globally (since the page may be COWed). This makes
> keeping track of the number of actual pages that are volatile accurately
> somewhat difficult, since we can't just add one for each page marked and
> subtract one for each page unmarked (for tmpfs/shm file based
> volatility, where volatility is shared globally, this will be much easier ;)
> 
> It might not be too hard to keep a per-process-pages count of
> volatility, but in that case we could see some strange effects where it
> seems like there are 3x the number of actual volatile pages, and that
> might throw off some of the scanning. So its something I've deferred a
> bit to think about.

Okay. So, why do you want to account volatile page?
Originally, what I expected is to age anonymous LRU list until the number of
count is zero so aging overhead would be zero if there is no volatile page
any more in the system but downside of the approach is it makes vrange marking
syscall cost O(N). That's why I suggested couting of volatile *vmas* instead of
volatile *pages*. It could make unnecessary aging of anon lru list if there is
no physical pages in the vma but I think it's good deal because we moved
hot path overhead to slow path and that's one of design goal of vrange syscall.
We might make an effort to make such aging not agressive in future, which
would be another topic.

> 
> 
> 
> >> o Revisit anonymous page aging on swapless systems
> > One idea is that we can age forcefully on swapless system if system
> > has volatile vma or lazyfree pages. If the number of volatile vma or
> > lazyfree pages is zero, we can stop the aging automatically.
> 
> I'll look into this some more.
> 
> 
> >
> >> o Draft up re-adding tmpfs/shm file volatility support
> >>
> >   o One concern from minchan.
> >   I really like O(1) cost of unmarking syscall.
> >
> > Vrange syscall is for others, not itself. I mean if some process calls
> > vrange syscall, it would scacrifice his resource for others when
> > emergency happens so if the syscall is overhead rather expensive,
> > anybody doesn't want to use it.
> 
> So yes. I agree the cost is more expensive then I'd like. However, I'd
> like to get a consensus on the expected behavior established and get
> folks first agreeing to the semantics and the interface. Then we can
> follow up with optimizations.

Oops, I forgot mentioning "We could do it with optimization in future".
I absolute agree with you. I don't want to do that in this stage but just
want to record one idea to optimize it so don't get me wrong. It's not
a objection.

> 
> > One idea is put increasing counter in mm_struct and assign the token
> > to volatile vma. Maybe we can squeeze it into vma->vm_start's lower
> > bits if we don't want to bloat vma size because we always hold mmap_sem
> > with write-side lock when we handle vrange syscall.
> > And we can use the token and purged mark together to pte when the purge
> > happens. With this, we can bail out as soon as we found purged entry in
> > unmarking syscall so remained ptes still have purged pte although
> > unmarking syscall is done. But it's no problem because if the vma is
> > marked as volatile again, the token will be change(ie, increased) and
> > doesn't match with pte's token. When the page fault occur, we can compare
> > the token to emit SIGBUS. If it doesn't match, we can ignore and just
> > map new page to pte.
> >
> > One problem is overflow of counter. In the case, we can deliver false
> > positive to user but it isn't severe, either because use have a preparation
> > to handle SIGBUS if he want to use vrange syscall with SIGBUS model.
> 
> This sounds like an interesting optimization. But again, I worry that
> adding these edge cases (which I honestly really don't see as
> problematic) muddies the water and keeps reviewers away. I'd rather wait
> until after we have something settled behavior wise, then start
> discussing these performance optimizations that may cause
> safe-but-false-postives.
> 
> 
> Thanks so much for your review and guidance here (I was worried I had
> lost everyone's attention again). I really appreciate the feedback!
> 
> thanks
> -john
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
