Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 2F81C6B0069
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 00:15:20 -0500 (EST)
Date: Fri, 4 Jan 2013 14:15:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v5 0/8] Support volatile for anonymous range
Message-ID: <20130104051518.GD2617@blaptop>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
 <CAOMbAgLaFR+Et=F5+A7HPY16X-Y8VPm6mY_vE9XOJm8C-8OfPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOMbAgLaFR+Et=F5+A7HPY16X-Y8VPm6mY_vE9XOJm8C-8OfPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sanjay Ghemawat <sanjay@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Thu, Jan 03, 2013 at 09:19:08AM -0800, Sanjay Ghemawat wrote:
> On Wed, Jan 2, 2013 at 8:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> > This is still RFC because we need more input from user-space
> > people, more stress test, design discussion about interface/reclaim
> 
> Speaking as one of the authors of tcmalloc, I don't see any particular
> need for this new system call for tcmalloc.  We are fine using
> madvise(MADV_DONTNEED) and don't notice any significant
> performance issues caused by it.  Background: we throttle how
> quickly we release memory back to the system (1-10MB/s), so
> we do not call madvise() very much, and we don't end up reusing
> madvise-ed away pages at a fast rate. My guess is that we won't

It means TCmalloc controls madvise's rate dynamically without
user's intervention? Smart TCmalloc!

Let me ask some questions.
What is your policy for control of throttling of madvise?
I guess policy is following as.

The madvise's frequent calling is bad because pte zap overhead of
madvise + next page fault/memset + page access bit emulatation
page fault in some architecture like ARM when reused the range.
So we should call it fast rate only when memory pressure happens
very carefully. Is it similar to your throttling logic?

If my assumption isn't totally wrong, how could a process know
the memory pressure at the moment by just per-process view, NOT
system view?

If your logic takes some mistake, (for instace, memory pressure
is severe but it doesn't call madvise) working set could be reclaimed
like file-backed pages, which could minimize your benefit via madvise
throttling. I guess it's very fragile. It's more severe in embedded
world because they don't use swap so system encounters OOM instead of
swappout.

In this point, mvolatile's concept is light weight system call by
just mark the flag in the vma and auto free when system suffers from
memory pressure(about this, my plan is zap all pages if kswapd is active
when movlatile system call is called) by reclaimer with preventing
working set page eviction, otherwise enhance application's speed with
removing (minor fault + page allocation + memset). Also, it would make
allocator simple through removing control logic, which is less error-prone
and even might make smart TCmalloc better than now althoug it doesn't have
any significat performance issue.

> see large enough application-level performance improvements to
> cause us to change tcmalloc to use this system call.
> 
> > - What's different with madvise(DONTNEED)?
> >
> >   System call semantic
> >
> >   DONTNEED makes sure user always can see zero-fill pages after
> >   he calls madvise while mvolatile can see old data or encounter
> >   SIGBUS.
> 
> Do you need a new system call for this?  Why not just a new flag to madvise
> with weaker guarantees than zero-filling?  All of the implementation changes
> you point out below could be triggered from that flag.

Agreed and actually, I tried it but changed my mind because it required
adding many hacky codes in madvise due to return value and error's semantic
is totally different with normal madvise and needs three flags at least at
the moment but not sure we need more flags during discussion.

MADV_VOLATILE, MADV_NOVOLATILE, MADV_[NO]VOLATILE|MADV_PARTIAL_DISCARD

I don't want to make madvise dirty and consume lots of new flags of madvise
for a volatile feature. But if everybody want to fold into madivse,
I can do it, too.

Thanks for the feedback, Sanjay!

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
