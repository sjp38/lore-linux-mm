Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id D07D46B003A
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:12:42 -0400 (EDT)
Received: by mail-ve0-f173.google.com with SMTP id db11so6575888veb.18
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 13:12:42 -0700 (PDT)
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
        by mx.google.com with ESMTPS id qp10si4512865vdb.7.2014.06.16.13.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 13:12:42 -0700 (PDT)
Received: by mail-ve0-f172.google.com with SMTP id jz11so6711101veb.3
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 13:12:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140603145710.GQ2878@cmpxchg.org>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
	<536BBB08.3000503@linaro.org>
	<20140603145710.GQ2878@cmpxchg.org>
Date: Mon, 16 Jun 2014 13:12:41 -0700
Message-ID: <CALAqxLXBs0scEEb7-rYbq9vHHs8VWUg-9vFXDoK4mzUt4smbYw@mail.gmail.com>
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 3, 2014 at 7:57 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, May 08, 2014 at 10:12:40AM -0700, John Stultz wrote:
>> On 04/29/2014 02:21 PM, John Stultz wrote:
>> > Another few weeks and another volatile ranges patchset...
>> >
>> > After getting the sense that the a major objection to the earlier
>> > patches was the introduction of a new syscall (and its somewhat
>> > strange dual length/purged-bit return values), I spent some time
>> > trying to rework the vma manipulations so we can be we won't fail
>> > mid-way through changing volatility (basically making it atomic).
>> > I think I have it working, and thus, there is no longer the
>> > need for a new syscall, and we can go back to using madvise()
>> > to set and unset pages as volatile.
>>
>> Johannes: To get some feedback, maybe I'll needle you directly here a
>> bit. :)
>>
>> Does moving this interface to madvise help reduce your objections?  I
>> feel like your cleaning-the-dirty-bit idea didn't work out, but I was
>> hoping that by reworking the vma manipulations to be atomic, we could
>> move to madvise and still avoid the new syscall that you seemed bothered
>> by. But I've not really heard much from you recently so I worry your
>> concerns on this were actually elsewhere, and I'm just churning the
>> patch needlessly.
>
> My objection was not the syscall.
>
> From a reclaim perspective, using the dirty state to denote whether a
> swap-backed page needs writeback before reclaim is quite natural and I
> much prefer Minchan's changes to the reclaim code over yours.
>
> From an interface point of view, I would prefer the simplicity of
> cleaning dirty bits to invalidate pages, and a default of zero-filling
> invalidated pages instead of sending SIGBUS.  This also is quite
> natural when you think of anon/shmem mappings as cache pages on top of
> /dev/zero (see mmap_zero() and shmem_zero_setup()).  And it translates
> well to tmpfs.
>
> At the same time, I acknowledge that there are usecases that want
> SIGBUS delivery for more than just convenience in order to implement
> userspace fault handling, and this is the only place where I see a
> real divergence in actual functionality from Minchan's code.

Thanks for the clarification and feedback. Sorry for my slow response,
as I was on vacation for a week and am just now catching up on this.

So again, SIGBUS for userspace fault handling is really of a
side-effect of having more userspace friendly semantics, and isn't
really the primary goal/usage model.

Zerofill semantics are mostly problematic because they make userspace
mistakes harder to find and diagnose. Android's ashmem actually uses
zerofill semantics, so while I see it as less ideal, technically
zerofill would work here.

However, combining zerofill with your preferred overloading of the
dirty state is particularly problematic because it makes any dirtying
of volatile data clear both the volatile state as well as the purged
state for the entire page. The volatile state is surprising, but less
problematic, but the clearing of the purged state means applications
would possibly get a partial zero page (for whatever wasn't written)
and no warning that their data was lost.  This is a very surprising
and unfriendly side-effect from a userspace perspective.

For context,  Android's ashmem preserves both the volatile and purged
state on volatile page dirtying (since the volatility and purged state
are kept in their own range structure independently from the VM).

> That, however, truly is a separate virtual memory feature.  Would it
> be possible for you to take MADV_FREE and MADV_REVIVE as a base and
> implement an madvise op that switches the no-page behavior of a VMA
> from zero-filling to SIGBUS delivery?

I'll see if I can look into it if I get some time. However, I suspect
its more likely I'll just have to admit defeat on this one and let
someone else champion the effort. Interest and reviews have seemingly
dropped again here and with other work ramping up, I'm not sure if
I'll be able to justify further work on this. :(

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
