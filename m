Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E2A936B0070
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:34:52 -0500 (EST)
Date: Thu, 20 Dec 2012 10:34:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v4 0/3] Support volatile for anonymous range
Message-ID: <20121220013447.GA2686@blaptop>
References: <1355813274-571-1-git-send-email-minchan@kernel.org>
 <50D0B5A2.2010707@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50D0B5A2.2010707@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 18, 2012 at 10:27:46AM -0800, Arun Sharma wrote:
> On 12/17/12 10:47 PM, Minchan Kim wrote:
> 
> >I hope more inputs from user-space allocator people and test patch
> >with their allocator because it might need design change of arena
> >management for getting real vaule.
> 
> jemalloc knows how to handle MADV_FREE on platforms that support it.
> This looks similar (we'll need a SIGBUS handler that does the right
> thing = zero the page + mark it as non-volatile in the common case).

Don't work because it's too late to mark it as non-volatile in signal
handler in case of malloc.

For example,
free(P1-P4) -> mvolatile(P1-P4) -> VM discard(P3) -> alloc(P1-P4) ->
use P1 -> VM discard(P1) -> use P3 -> SIGBUS -> mark nonvolatile ->
lost P1.

So, we should call mnovolatile before giving the free space to user.

> 
> All of this of course assumes that apps madvise the kernel through
> APIs exposed by the malloc implementation - not via a raw syscall.
> 
> In other words, some new user space code needs to be written to test

Agreed. I might want to design new allocator with this system calls if
existing allocators cannot use this system calls efficiently because it
might need allocator's design change. MADV_FREE/MADV_DONTNEED isn't cheap
due to enumerating ptes/page descriptors in that range to mark something
so I guess allocator avoids frequent calling of the such advise system call
and even if they call it, they want to call the big range as batch.
Just my imagine.

But mvolatile/mnovolatile is cheaper so you can call it more frequently
with smaller range so VM could have easy-reclaimable pages easily.
Another benefit of the mvolatile is it can change the behavior when memory
pressure is severe where it can zap all pages like DONTNEED so it could
work very flexible.
The downside of that approach is that if we call it with small range,
it can increase the number of VMA so we might tune point for VMA size.

> this out fully. Sounds feasible though.

Thanks!

> 
>  -Arun
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
