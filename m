Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B2D1B6B003A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:45:01 -0400 (EDT)
Date: Wed, 13 Mar 2013 15:44:59 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130313064459.GC13815@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <CAPM31RJ1tzd7yWQEgL0u-PjK7mV=wY57OPDJ76ijJAC2YnDuHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPM31RJ1tzd7yWQEgL0u-PjK7mV=wY57OPDJ76ijJAC2YnDuHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, Sanjay Ghemawat <sanjay@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Mar 12, 2013 at 04:16:57PM -0700, Paul Turner wrote:
> On Tue, Mar 12, 2013 at 12:38 AM, Minchan Kim <minchan@kernel.org> wrote:
> > First of all, let's define the term.
> > From now on, I'd like to call it as vrange(a.k.a volatile range)
> > for anonymous page. If you have a better name in mind, please suggest.
> >
> > This version is still *RFC* because it's just quick prototype so
> > it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
> > Before further sorting out issues, I'd like to post current direction
> > and discuss it. Of course, I'd like to extend this discussion in
> > comming LSF/MM.
> >
> > In this version, I changed lots of thing, expecially removed vma-based
> > approach because it needs write-side lock for mmap_sem, which will drop
> > performance in mutli-threaded big SMP system, KOSAKI pointed out.
> > And vma-based approach is hard to meet requirement of new system call by
> > John Stultz's suggested semantic for consistent purged handling.
> > (http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)
> >
> > I tested this patchset with modified jemalloc allocator which was
> > leaded by Jason Evans(jemalloc author) who was interest in this feature
> > and was happy to port his allocator to use new system call.
> > Super Thanks Jason!
> >
> > The benchmark for test is ebizzy. It have been used for testing the
> > allocator performance so it's good for me. Again, thanks for recommending
> > the benchmark, Jason.
> > (http://people.freebsd.org/~kris/scaling/ebizzy.html)
> >
> > The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)
> >
> >         ebizzy -S 20
> >
> > jemalloc-vanilla: 52389 records/sec
> > jemalloc-vrange: 203414 records/sec
> >
> >         ebizzy -S 20 with background memory pressure
> >
> > jemalloc-vanilla: 40746 records/sec
> > jemalloc-vrange: 174910 records/sec
> >
> > And it's much improved on KVM virtual machine.
> >
> > This patchset is based on v3.9-rc2
> >
> > - What's the sys_vrange(addr, length, mode, behavior)?
> >
> >   It's a hint that user deliver to kernel so kernel can *discard*
> >   pages in a range anytime. mode is one of VRANGE_VOLATILE and
> >   VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
> >   kernel coudn't discard any pages any more while VRANGE_VOLATILE
> >   is memory unpin opeartion so kernel can discard pages in vrange
> >   anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
> >   PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
> >   discard page in a vrange, please, discard all of pages in a
> >   vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
> >   that please discard of some pages in a vrange. But now I didn't
> >   implemented VRANGE_PARTIAL handling yet.
> >
> > - What happens if user access page(ie, virtual address) discarded
> >   by kernel?
> >
> >   The user can encounter SIGBUS.
> >
> > - What should user do for avoding SIGBUS?
> >   He should call vrange(addr, length, VRANGE_NOVOLATILE, mode) before
> >   accessing the range which was called
> >   vrange(addr, length, VRANGE_VOLATILE, mode)
> >
> > - What happens if user access page(ie, virtual address) doesn't
> >   discarded by kernel?
> >
> >   The user can see vaild data which was there before calling
> > vrange(., VRANGE_VOLATILE) without page fault.
> >
> > - What's different with madvise(DONTNEED)?
> >
> >   System call semantic
> >
> >   DONTNEED makes sure user always can see zero-fill pages after
> >   he calls madvise while vrange can see data or encounter SIGBUS.
> >
> >   Internal implementation
> >
> >   The madvise(DONTNEED) should zap all mapped pages in range so
> >   overhead is increased linearly with the number of mapped pages.
> >   Even, if user access zapped pages as write mode, page fault +
> >   page allocation + memset should be happened.
> >
> >   The vrange just register a address range instead of zapping all of pte
> >   n the vma so it doesn't touch ptes any more.
> >
> > - What's the benefit compared to DONTNEED?
> >
> >   1. The system call overhead is smaller because vrange just registers
> >      a range using interval tree instead of zapping all the page in a range
> >      so overhead should be really cheap.
> >
> >   2. It has a chance to eliminate overheads (ex, zapping pte + page fault
> >      + page allocation + memset(PAGE_SIZE)) if memory pressure isn't
> >      severe.
> >
> >   3. It has a potential to zap all ptes and free the pages if memory
> >      pressure is severe so discard scanning overhead could be smaller - TODO
> >
> > - What's for targetting?
> >
> >   Firstly, user-space allocator like ptmalloc, jemalloc or heap management
> >   of virtual machine like Dalvik. Also, it comes in handy for embedded
> >   which doesn't have swap device so they can't reclaim anonymous pages.
> >   By discarding instead of swapout, it could be used in the non-swap system.
> 
> I think that another potentially useful use-case would be using this
> -- or a similar API -- to opportunistically return deep user stack
> frames.
> 
> This is another place where we strongly care about the time-to-free as
> well as the time-to-reallocate in the case of relatively immediate
> re-use.

Indeed. Great idea!
Thanks, Paul.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
