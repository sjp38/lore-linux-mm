Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 902626B0109
	for <linux-mm@kvack.org>; Thu,  8 May 2014 13:04:53 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so2544165pde.12
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:04:53 -0700 (PDT)
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
        by mx.google.com with ESMTPS id hp2si792906pac.483.2014.05.08.10.04.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 10:04:52 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so2581725pde.27
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:04:52 -0700 (PDT)
Message-ID: <536BB931.7070902@linaro.org>
Date: Thu, 08 May 2014 10:04:49 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org> <20140508055852.GD5282@bbox>
In-Reply-To: <20140508055852.GD5282@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/07/2014 10:58 PM, Minchan Kim wrote:
> On Tue, Apr 29, 2014 at 02:21:19PM -0700, John Stultz wrote:
>> Another few weeks and another volatile ranges patchset...
>>
>> After getting the sense that the a major objection to the earlier
>> patches was the introduction of a new syscall (and its somewhat
>> strange dual length/purged-bit return values), I spent some time
>> trying to rework the vma manipulations so we can be we won't fail
>> mid-way through changing volatility (basically making it atomic).
>> I think I have it working, and thus, there is no longer the
>> need for a new syscall, and we can go back to using madvise()
>> to set and unset pages as volatile.
> As I said reply as other patch's reply, I'm ok with this but I'd
> like to make it clear to support zero-filled page as well as SIGBUS.
> If we want to use madvise, maybe we need another advise flag like
> MADV_VOLATILE_SIGBUS.

I still disagree that zero-fill is more obvious behavior. And again, I
still support MADV_VOLATILE and MADV_FREE both being added, as they
really do have different use cases that I'd rather not try to fit into
one operation.


>>
>> New changes are:
>> ----------------
>> o Reworked vma manipulations to be be atomic
>> o Converted back to using madvise() as syscall interface
>> o Integrated fix from Minchan to avoid SIGBUS faulting race
>> o Caught/fixed subtle use-after-free bug w/ vma merging
>> o Lots of minor cleanups and comment improvements
>>
>>
>> Still on the TODO list
>> ----------------------------------------------------
>> o Sort out how best to do page accounting when the volatility
>>   is tracked on a per-mm basis.
> What's is your concern about page accouting?
> Could you elaborate it more for everybody to understand your concern
> clearly.

Basically the issue is that since we keep the volatility in the vma,
when we mark a page as volatile, its only marking the page for that
processes, not globally (since the page may be COWed). This makes
keeping track of the number of actual pages that are volatile accurately
somewhat difficult, since we can't just add one for each page marked and
subtract one for each page unmarked (for tmpfs/shm file based
volatility, where volatility is shared globally, this will be much easier ;)

It might not be too hard to keep a per-process-pages count of
volatility, but in that case we could see some strange effects where it
seems like there are 3x the number of actual volatile pages, and that
might throw off some of the scanning. So its something I've deferred a
bit to think about.



>> o Revisit anonymous page aging on swapless systems
> One idea is that we can age forcefully on swapless system if system
> has volatile vma or lazyfree pages. If the number of volatile vma or
> lazyfree pages is zero, we can stop the aging automatically.

I'll look into this some more.


>
>> o Draft up re-adding tmpfs/shm file volatility support
>>
>   o One concern from minchan.
>   I really like O(1) cost of unmarking syscall.
>
> Vrange syscall is for others, not itself. I mean if some process calls
> vrange syscall, it would scacrifice his resource for others when
> emergency happens so if the syscall is overhead rather expensive,
> anybody doesn't want to use it.

So yes. I agree the cost is more expensive then I'd like. However, I'd
like to get a consensus on the expected behavior established and get
folks first agreeing to the semantics and the interface. Then we can
follow up with optimizations.

> One idea is put increasing counter in mm_struct and assign the token
> to volatile vma. Maybe we can squeeze it into vma->vm_start's lower
> bits if we don't want to bloat vma size because we always hold mmap_sem
> with write-side lock when we handle vrange syscall.
> And we can use the token and purged mark together to pte when the purge
> happens. With this, we can bail out as soon as we found purged entry in
> unmarking syscall so remained ptes still have purged pte although
> unmarking syscall is done. But it's no problem because if the vma is
> marked as volatile again, the token will be change(ie, increased) and
> doesn't match with pte's token. When the page fault occur, we can compare
> the token to emit SIGBUS. If it doesn't match, we can ignore and just
> map new page to pte.
>
> One problem is overflow of counter. In the case, we can deliver false
> positive to user but it isn't severe, either because use have a preparation
> to handle SIGBUS if he want to use vrange syscall with SIGBUS model.

This sounds like an interesting optimization. But again, I worry that
adding these edge cases (which I honestly really don't see as
problematic) muddies the water and keeps reviewers away. I'd rather wait
until after we have something settled behavior wise, then start
discussing these performance optimizations that may cause
safe-but-false-postives.


Thanks so much for your review and guidance here (I was worried I had
lost everyone's attention again). I really appreciate the feedback!

thanks
-john






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
