Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 888116B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 20:31:51 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so7548774pdj.25
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 17:31:51 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id yt9si14527077pab.4.2014.02.03.17.31.48
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 17:31:49 -0800 (PST)
Date: Tue, 4 Feb 2014 10:31:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140204013151.GB3481@bbox>
References: <52EAFBF6.7020603@linaro.org>
 <CF103DE0.14877%je@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CF103DE0.14877%je@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Evans <je@fb.com>
Cc: John Stultz <john.stultz@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, "pliard@google.com" <pliard@google.com>

Hello Jason,

On Fri, Jan 31, 2014 at 01:44:55AM +0000, Jason Evans wrote:
> On 1/30/14, 5:27 PM, "John Stultz" <john.stultz@linaro.org> wrote:
> >I'm still not totally sure about, but willing to try
> >* Page granular volatile tracking
> 
> In the malloc case (anonymous unused dirty memory), this would have very
> similar characteristics to madvise(...MADV_FREE) as on e.g. FreeBSD, but
> with the extra requirement that memory be marked nonvolatile prior to
> reuse.  That wouldn't be terrible -- certainly an improvement over
> madvise(...MADV_DONTNEED), but range-based volatile regions would actually
> be an improvement over prior art, rather than a more cumbersome equivalent.
> 
> Either way, I'm really looking forward to being able to utilize volatile
> ranges in jemalloc.

First of all, Again, I should thank for your help!

While I discuss with Johannes, I'm biasing to implemnt MADV_FREE for Linux.
instead of vrange syscall for allocator.
The reason I preferred vrange syscall over MADV_FREE is vrange syscall
is almost O(1) so it's really light weight system call although it needs
one more syscall to unmark volatility while MADV_FREE is O(#pages) but
as Johannes pointed out, these day kernel trends are using huge pages(ex,
2M) so I guess the overhead is really big.

(Another topic: If application want to use huge pages on Linux,
it should mmap the region is aligned to the huge page size but when
I read jemalloc source code, it seems not. Do you have any reason?)

As a bonus point, many allocators already has a logic to use MADV_FREE
so it's really easy to use it if Linux start to support it.

Do you see other point that light-weight vrange syscall is
superior to MADV_FREE of big chunk all at once?

Thanks for the comment, Jason.

> 
> Thanks,
> Jason
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
