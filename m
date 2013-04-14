Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 8007A6B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 03:42:13 -0400 (EDT)
Received: by mail-da0-f45.google.com with SMTP id v40so1668573dad.32
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 00:42:12 -0700 (PDT)
Date: Sun, 14 Apr 2013 16:42:04 +0900
From: Minchan Kim <minchan.kernel.2@gmail.com>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130414074204.GC8241@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <5165CA22.6080808@gmail.com>
 <20130411065546.GA10303@blaptop>
 <5166643E.6050704@gmail.com>
 <20130411080243.GA12626@blaptop>
 <5166712C.7040802@gmail.com>
 <20130411083146.GB12626@blaptop>
 <5166D037.6040405@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5166D037.6040405@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hi KOSAKI,

On Thu, Apr 11, 2013 at 11:01:11AM -0400, KOSAKI Motohiro wrote:
> >>>> and adding new syscall invokation is unwelcome.
> >>>
> >>> Sure. But one more system call could be cheaper than page-granuarity
> >>> operation on purged range.
> >>
> >> I don't think vrange(VOLATILE) cost is the related of this discusstion.
> >> Whether sending SIGBUS or just nuke pte, purge should be done on vmscan,
> >> not vrange() syscall.
> > 
> > Again, please see the MADV_FREE. http://lwn.net/Articles/230799/
> > It does changes pte and page flags on all pages of the range through
> > zap_pte_range. So it would make vrange(VOLASTILE) expensive and
> > the bigger cost is, the bigger range is.
> 
> This haven't been crossed my mind. now try_to_discard_one() insert vrange
> for making SIGBUS. then, we can insert pte_none() as the same cost too. Am
> I missing something?

For your requirement, we need some tracking model to detect some page is
using by the process currently before VM discards it *if* we don't give
vrange(NOVOLATILE) pair system call(Look at below). So the tracking model
should be formed in vrange(VOLATILE) system call context.

> 
> I couldn't imazine why pte should be zapping on vrange(VOLATILE).

Sorry, my explanation was too bad to understand.
I will try again.

First of all, thing you want is almost like MADV_FREE.
So let's look at it firstly.

If you call madvise(range, MADV_FREE), VM should investigate all of
pages mapped at page table for range(start, start + len) so we need
page table lookup for the range and mark a flag to all page descriptor
(ex,PG_lazyfree) to give hint to kernel for discarding the page instead of
swappint out when reclaim happens. Another thing we need is to clear out
a dirty bit from PTE to detect the pages is dirtied or not, since we call
madvise(range, MADV_FREE) because we can't discard them, which are using by
some process since he called madvise. So if VM find the page has PG_lazyfree
but the page is dirtied recenlty by peeking PTE, VM can't discard the page.
So madivse system call's overhead is folloinwg as in madvise(MADV_FREE)

1. look up all pages from page table for the range.
2. mark some bit(PG_lazyfree) for page descriptors of pages mapped at range
3. clear dirty bit and TLB flush

So, madvise(MADV_FREE) would be better than madvise(DONTNEED) because it can
avoid page fault if memory pressure doesn't happen but system call overhead
could be still huge and expecially the overhead is increased proportionally
by range size.

Let's talk about vrange(range, VOLATILE)
The overhead of it is very small, which is just mark a flag into a
structure which represents the range (ie, struct vrange). When VM want to reclaim
some pages, VM find a page is mapped at VOLATILE area, so it could discard it
instead of swapping out. It moves the ovehead from system call itself to
VM reclaim path which is very slow path in the system and I think it's desirable
design(And that's why we have rmap).
But the problem is remained. VM can't detect page using by process after he calls
vrange(range, VOLATILE) because we didn't do anything in vrange(VOLATILE) so
VM might discard the page under the process. It didn't happen in madvise(MADV_FREE)
because it cleared out dirty bit of PTE to detect the page is used or not
since madvise is called.

Solution in vrange is to make new vrange(range, NOVOLATILE) system call, which give
the hint to kernel for preventing descarding pages in the range any more.
The cost of vrange(range, NOVOLATILE) is very small, too.
It just clear out the flags from a struct vrange which represents a range.

So I think calling of pair system call about volatile would be cheaper than a
only madvise(MADV_FREE).

I hope it helps your understanding but not sure because I am writing this
in airport which are very hard to focus my work. :(

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
