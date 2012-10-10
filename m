Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 8C5D56B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 20:11:02 -0400 (EDT)
Date: Wed, 10 Oct 2012 09:15:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
Message-ID: <20121010001514.GJ13817@bbox>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
 <20121009080735.GA24375@glandium.org>
 <5074975B.20809@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5074975B.20809@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Mike Hommey <mh@glandium.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 09, 2012 at 02:30:03PM -0700, John Stultz wrote:
> On 10/09/2012 01:07 AM, Mike Hommey wrote:
> >Note it doesn't have to be a vs. situation. madvise could be an
> >additional way to interface with volatile ranges on a given fd.
> >
> >That is, madvise doesn't have to mean anonymous memory. As a matter of
> >fact, MADV_WILLNEED/MADV_DONTNEED are usually used on mmaped files.
> >Similarly, there could be a way to use madvise to mark volatile ranges,
> >without the application having to track what memory ranges are
> >associated to what part of what file, which the kernel already tracks.
> 
> Good point. We could add madvise() interface, but limit it only to
> mmapped tmpfs files, in parallel with the fallocate() interface.
> 
> However, I would like to think through how MADV_MARK_VOLATILE with
> purely anonymous memory could work, before starting that approach.
> That and Neil's point that having an identical kernel interface
> restricted to tmpfs, only as a convenience to userland in switching
> from virtual address to/from mmapped file offset may be better left
> to a userland library.

How about this?

The scenario I imagine about madvise semantic following as.

1) Anonymous pages
Assume that there is some allocator library which manage mmaped reserved pool.
If it has lots of free memory which isn't used by anyone, it can unmap part of
reserved pool but unmap isn't cheap because kernel should zap all ptes of the
pages in the range. But if we avoid unmap, VM would swap out that range which
have just garbage unnecessary when memory pressure happens.
If it mark that range volatile, we can avoid unnecessary swap out and even
reclaim them with no swap. Only thing allocator have to do is unmark that range
before allocating to user.

2) File pages(NOT tmpfs)
We can reclaim volatile file pages easily without recycling of LRU
although it is accessed recently.
The difference with DONTNEED is that DONTNEED always move pages to
tail of inactive LRU to reclaim early but VOLATILE semantic leave them
as it is without moving to tail and reclaim them without considering
recently-used when they reach at tail of LRU by aging because they can
be unmarked sooner or later for using and we can't expect cost of
recreating of the object.

So reclaim preference : NORMAL < VOLATILE < DONTNEED


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
