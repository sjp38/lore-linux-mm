Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2C36B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 22:09:20 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so4036580eek.10
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 19:09:20 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id d8si39156594eeh.53.2014.02.03.19.09.18
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 19:09:19 -0800 (PST)
From: Jason Evans <je@fb.com>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Date: Tue, 4 Feb 2014 03:08:27 +0000
Message-ID: <CF1584DE.149CA%je@fb.com>
In-Reply-To: <20140204013151.GB3481@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B898BB1CEBE31342A993D9E4609DC6C9@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel
 Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, "pliard@google.com" <pliard@google.com>

On 2/3/14, 5:31 PM, "Minchan Kim" <minchan@kernel.org> wrote:
>While I discuss with Johannes, I'm biasing to implemnt MADV_FREE for
>Linux.
>instead of vrange syscall for allocator.
>The reason I preferred vrange syscall over MADV_FREE is vrange syscall
>is almost O(1) so it's really light weight system call although it needs
>one more syscall to unmark volatility while MADV_FREE is O(#pages) but
>as Johannes pointed out, these day kernel trends are using huge pages(ex,
>2M) so I guess the overhead is really big.
>
>(Another topic: If application want to use huge pages on Linux,
>it should mmap the region is aligned to the huge page size but when
>I read jemalloc source code, it seems not. Do you have any reason?)

jemalloc uses 4 MiB naturally aligned chunks by default (chunk size can be
any power of 2 that is at least two pages), so by default jemalloc does
align its mappings to huge page boundaries.

However, chunks have embedded metadata headers, which means that in
practice, only the second half of each chunk can be madvise()d away if
only huge pages are in use.  Additionally, the overhead of using even one
huge page per size class would be unacceptable for most applications (2
MiB * ~30 size classes * number of active arenas), so adjusting the
allocator's layout algorithms to use huge pages would require a very
different strategy than is currently used, and the likelihood of having
huge pages completely drain of allocations would be quite low.  On top of
that, the implicit nature of transparent huge pages makes them difficult
to reliably account for in userland.  In other words, huge pages and
explicit dirty page purging are for most practical purposes incompatible.

>As a bonus point, many allocators already has a logic to use MADV_FREE
>so it's really easy to use it if Linux start to support it.

MADV_FREE is certainly an easy interface to use, and as long as there
aren't any serious scalability issues in the implementation (e.g.
concurrent madvise() calls for disjoint virtual addresses from multiple
threads should be contention-free), I think it's perfectly adequate.

>Do you see other point that light-weight vrange syscall is
>superior to MADV_FREE of big chunk all at once?

Other than system call overhead, volatile ranges and MADV_FREE are both
great for jemalloc's purposes.  MADV_FREE is a bit easier to deal with,
mainly because volatile ranges are distinct from dirty pages and virtual
memory coalescing in jemalloc will require some additional work to
logically treat adjacent volatile/dirty ranges as contiguous, but that's a
solvable problem.

Thanks,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
