Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 898D76B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:57:48 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so6788088wiw.2
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:57:48 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id wf5si25504736wjb.92.2014.06.03.07.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 07:57:47 -0700 (PDT)
Date: Tue, 3 Jun 2014 10:57:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
Message-ID: <20140603145710.GQ2878@cmpxchg.org>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
 <536BBB08.3000503@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536BBB08.3000503@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 08, 2014 at 10:12:40AM -0700, John Stultz wrote:
> On 04/29/2014 02:21 PM, John Stultz wrote:
> > Another few weeks and another volatile ranges patchset...
> >
> > After getting the sense that the a major objection to the earlier
> > patches was the introduction of a new syscall (and its somewhat
> > strange dual length/purged-bit return values), I spent some time
> > trying to rework the vma manipulations so we can be we won't fail
> > mid-way through changing volatility (basically making it atomic).
> > I think I have it working, and thus, there is no longer the
> > need for a new syscall, and we can go back to using madvise()
> > to set and unset pages as volatile.
> 
> Johannes: To get some feedback, maybe I'll needle you directly here a
> bit. :)
> 
> Does moving this interface to madvise help reduce your objections?  I
> feel like your cleaning-the-dirty-bit idea didn't work out, but I was
> hoping that by reworking the vma manipulations to be atomic, we could
> move to madvise and still avoid the new syscall that you seemed bothered
> by. But I've not really heard much from you recently so I worry your
> concerns on this were actually elsewhere, and I'm just churning the
> patch needlessly.

My objection was not the syscall.

>From a reclaim perspective, using the dirty state to denote whether a
swap-backed page needs writeback before reclaim is quite natural and I
much prefer Minchan's changes to the reclaim code over yours.

>From an interface point of view, I would prefer the simplicity of
cleaning dirty bits to invalidate pages, and a default of zero-filling
invalidated pages instead of sending SIGBUS.  This also is quite
natural when you think of anon/shmem mappings as cache pages on top of
/dev/zero (see mmap_zero() and shmem_zero_setup()).  And it translates
well to tmpfs.

At the same time, I acknowledge that there are usecases that want
SIGBUS delivery for more than just convenience in order to implement
userspace fault handling, and this is the only place where I see a
real divergence in actual functionality from Minchan's code.

That, however, truly is a separate virtual memory feature.  Would it
be possible for you to take MADV_FREE and MADV_REVIVE as a base and
implement an madvise op that switches the no-page behavior of a VMA
from zero-filling to SIGBUS delivery?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
