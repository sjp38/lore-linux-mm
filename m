Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 9F61C6B007D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 23:34:53 -0500 (EST)
Date: Tue, 11 Dec 2012 13:34:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121211043451.GB22698@blaptop>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <50AD739A.30804@linaro.org>
 <50B6E1F9.5010301@linaro.org>
 <20121204000042.GB20395@bbox>
 <50BD4A70.9060506@linaro.org>
 <20121204072207.GA9782@blaptop>
 <50BE4B64.6000003@linaro.org>
 <20121205070110.GC9782@blaptop>
 <50C287CE.5070404@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C287CE.5070404@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Dec 07, 2012 at 04:20:30PM -0800, John Stultz wrote:
> On 12/04/2012 11:01 PM, Minchan Kim wrote:
> >Hi John,
> >
> >On Tue, Dec 04, 2012 at 11:13:40AM -0800, John Stultz wrote:
> >>
> >>I don't think the problem is when vmas being marked VM_VOLATILE are
> >>being merged, its that when we mark the vma as *non-volatile*, and
> >>remove the VM_VOLATILE flag we merge the non-volatile vmas with
> >>neighboring vmas. So preserving the purged flag during that merge is
> >>important. Again, the example I used to trigger this was an
> >>alternating pattern of volatile and non volatile vmas, then marking
> >>the entire range non-volatile (though sometimes in two overlapping
> >>passes).
> >If I understand correctly, you mean following as.
> >
> >chunk1 = mmap(8M)
> >chunk2 = chunk1 + 2M;
> >chunk3 = chunk2 + 2M
> >chunk4 = chunk3 + 2M
> >
> >madvise(chunk1, 2M, VOLATILE);
> >madvise(chunk4, 2M, VOLATILE);
> >
> >/*
> >  * V : volatile vma
> >  * N : non volatile vma
> >  * So Now vma is VNVN.
> >  */
> >And chunk4 is purged.
> >
> >int ret = madvise(chunk1, 8M, NOVOLATILE);
> >ASSERT(ret == 1);
> >/* And you expect VNVN->N ?*/
> >
> >Right?
> 
> Yes. That's exactly right.
> 
> >If so, why should non-volatile function semantic allow it which cross over
> >non-volatile areas in a range? I would like to fail such case because
> >in case of MADV_REMOVE, it fails in the middle of operation if it encounter
> >VM_LOCKED.
> >
> >What do you think about it?
> Right, so I think this issue is maybe a problematic part of the VMA
> based approach.  While marking an area as nonvolatile twice might
> not make a lot of sense, I think userland applications would not
> appreciate the constraint that madvise(VOLATILE/NONVOLATILE) calls
> be made in perfect pairs of identical sizes.
> 
> For instance, if a browser has rendered a web page, but the page is
> so large that only a sliding window/view of that page is visible at
> one time, it may want to mark the regions not currently in the view
> as volatile.   So it would be nice (albeit naive) for that
> application that when the view location changed, it would just mark
> the new region as non-volatile, and any region not in the current
> view as volatile.  This would be easier then trying to calculate the
> diff of the old view region boundaries vs the new and modifying only
> the ranges that changed. Granted, doing so might be more efficient,
> but I'm not sure we can be sure every similar case would be more
> efficient.
> 
> So in my mind, double-clearing a flag should be allowed (as well as
> double-setting), as well as allowing for setting/clearing
> overlapping regions.

It might and as you said, it's not matched by normal madvise opearation.
So if user really want it, we might need another interface like new
system call like mlock.

Although we can implement it, what I has a concern is mmap_sem hold time.
For VMA approach, we need exclusive mmap_sem and it ends up preventing
concurrent page fault handling so it would mitigate anon volatile's goal
for user-space allocators. So I would like to avoid more works with
exclusive mmap_sem as far as possible.

Of course, you can argue that if we don't support such semantic,
user can call madvise(NOVOATILE) several time with several ranges
so it could be more bad. Right. But I suggest for plumbers to implement
range management smart and let's leave kernel implementation simple/fast.

I'm not solid. If user really want such semantic, I can support it with
new system call.

Frankly speaking, I would like to remove madvise(NOVOLATILE) call.
If you already saw my patch just I sent morning, you can guess what it is.
The problem of anon volatile with madvise(NOVOLATILE) is that time delay
between allocator allocats a free chunk and user really access the memory.
Normally, when allocator return free chunk to customer, allocator should
call madvise(NOVOLATILE) but user could access the memory long time after.
So during that time difference, that pages could be swap out.
So I decide to remove madvise(NOVOLATILE) and it's handled at first
page fault.

Yeb. The same rule couldn't applied to tmpfs volatile and it does needs
NOVOLATILE semantic. Hmm,, I am biasing to new system call.

int mvolatile(const void *addr, size_t len, int mode);
int munvolatile(const void *addr, size_t len;

If someone call mvolatile with AUTO mode, it would work as my anon volatile
while in MANUAL mode, user must call munvolatile before using.
It might meet your and mine goal. But adding new system call is last resort. :)

> 
> Aside from if the behavior should be allowed or not, the error mode
> of madvise is problematic as well, since failures can happen mid way
> through the operation, leaving the vmas in the range specified
> inconsistent. Since usually its only advisory, such inconsistent
> states aren't really problematic, and repeating the last action is
> probably fine.

True.

> 
> The problem with NOVOLATILE's  purged state, with vmas, is that if
> we hit an error mid-way through, its hard to figure out what the
> state of the pages are for the range specified. Some of them could
> have been purged and set to non-volatile, while some may not be
> purged, and still left volatile. You can't just repeat the last
> action and get a sane result (as we lose the purged flag state).

Agreed.

> 
> With my earlier fallocate implementations, I tried to avoid this by
> making any memory allocations that might be required before making
> any state changes, so there wasn't a chance for a partial failure
> from -ENOMEM.  (It was also simpler because in my own range
> management code there were only volatile ranges,  non-volatility was
> simply the absence of a volatile range. With vmas we have to manage
> both volatile and nonvolatile vmas).  I'm not sure how this could be
> done with the vma method other then by maybe reworking the
> merge/split logic, but I'm wary of mucking with that too much as I
> know its performance sensitive.
> 
> Your thoughts?  Am I just being too set in my way of thinking here?

Your claim makes sense. Two option.

1) Go separate way with each interface. (madvise vs fadvise or fallocate)
2) A new system call to unify them.

Hmm, I would like to wait more inputs from user-space allocator guys
because they might ask requirement which is similar to you.

> 
> thanks
> -john
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
