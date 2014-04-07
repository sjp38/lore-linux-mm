Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9226B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 02:19:24 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so6062056pdj.23
        for <linux-mm@kvack.org>; Sun, 06 Apr 2014 23:19:24 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tk5si7861585pbc.166.2014.04.06.23.19.22
        for <linux-mm@kvack.org>;
        Sun, 06 Apr 2014 23:19:23 -0700 (PDT)
Date: Mon, 7 Apr 2014 15:19:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Message-ID: <20140407061932.GF12144@bbox>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <20140401212102.GM4407@cmpxchg.org>
 <533B8C2D.9010108@linaro.org>
 <20140402183113.GL1500@redhat.com>
 <20140402192744.GU14688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402192744.GU14688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 02, 2014 at 03:27:44PM -0400, Johannes Weiner wrote:
> On Wed, Apr 02, 2014 at 08:31:13PM +0200, Andrea Arcangeli wrote:
> > Hi everyone,
> > 
> > On Tue, Apr 01, 2014 at 09:03:57PM -0700, John Stultz wrote:
> > > So between zero-fill and SIGBUS, I think SIGBUS makes the most sense. If
> > > you have a third option you're thinking of, I'd of course be interested
> > > in hearing it.
> > 
> > I actually thought the way of being notified with a page fault (sigbus
> > or whatever) was the most efficient way of using volatile ranges.
> > 
> > Why having to call a syscall to know if you can still access the
> > volatile range, if there was no VM pressure before the access?
> > syscalls are expensive, accessing the memory direct is not. Only if it
> > page was actually missing and a page fault would fire, you'd take the
> > slowpath.
> 
> Not everybody wants to actually come back for the data in the range,
> allocators and message passing applications just want to be able to
> reuse the memory mapping.
> 
> By tying the volatility to the dirty bit in the page tables, an
> allocator could simply clear those bits once on free().  When malloc()
> hands out this region again, the user is expected to write, which will
> either overwrite the old page, or, if it was purged, fault in a fresh
> zero page.  But there is no second syscall needed to clear volatility.
> 
> > > Now... once you've chosen SIGBUS semantics, there will be folks who will
> > > try to exploit the fact that we get SIGBUS on purged page access (at
> > > least on the user-space side) and will try to access pages that are
> > > volatile until they are purged and try to then handle the SIGBUS to fix
> > > things up. Those folks exploiting that will have to be particularly
> > > careful not to pass volatile data to the kernel, and if they do they'll
> > > have to be smart enough to handle the EFAULT, etc. That's really all
> > > their problem, because they're being clever. :)
> > 
> > I'm actually working on feature that would solve the problem for the
> > syscalls accessing missing volatile pages. So you'd never see a
> > -EFAULT because all syscalls won't return even if they encounters a
> > missing page in the volatile range dropped by the VM pressure.
> > 
> > It's called userfaultfd. You call sys_userfaultfd(flags) and it
> > connects the current mm to a pseudo filedescriptor. The filedescriptor
> > works similarly to eventfd but with a different protocol.
> > 
> > You need a thread that will never access the userfault area with the
> > CPU, that is responsible to poll on the userfaultfd and talk the
> > userfaultfd protocol to fill-in missing pages. The userfault thread
> > after a POLLIN event reads the virtual addresses of the fault that
> > must have happened on some other thread of the same mm, and then
> > writes back an "handled" virtual range into the fd, after the page (or
> > pages if multiple) have been regenerated and mapped in with
> > sys_remap_anon_pages(), mremap or equivalent atomic pagetable page
> > swapping. Then depending on the "solved" range written back into the
> > fd, the kernel will wakeup the thread or threads that were waiting in
> > kernel mode on the "handled" virtual range, and retry the fault
> > without ever exiting kernel mode.
> > 
> > We need this in KVM for running the guest on memory that is on other
> > nodes or other processes (postcopy live migration is the most common
> > use case but there are others like memory externalization and
> > cross-node KSM in the cloud, to keep a single copy of memory across
> > multiple nodes and externalized to the VM and to the host node).
> > 
> > This thread made me wonder if we could mix the two features and you
> > would then depend on MADV_USERFAULT and userfaultfd to deliver to
> > userland the "faults" happening on the volatile pages that have been
> > purged as result of VM pressure.
> > 
> > I'm just saying this after Johannes mentioned the issue with syscalls
> > returning -EFAULT. Because that is the very issue that the userfaultfd
> > is going to solve for the KVM migration thread.
> > 
> > What I'm thinking now would be to mark the volatile range also
> > MADV_USERFAULT and then calling userfaultfd and instead of having the
> > cache regeneration "slow path" inside the SIGBUS handler, to run it in
> > the userfault thread that polls the userfaultfd. Then you could write
> > the volatile ranges to disk with a write() syscall (or use any other
> > syscall on the volatile ranges), without having to worry about -EFAULT
> > being returned because one page was discarded. And if MADV_USERFAULT
> > is not called in combination with vrange syscalls, then it'd still
> > work without the userfault, but with the vrange syscalls only.
> > 
> > In short the idea would be to let the userfault code solve the fault
> > delivery to userland for you, and make the vrange syscalls only focus
> > on the page purging problem, without having to worry about what
> > happens when something access a missing page.
> 
> Yes, the two seem certainly combinable to me.
> 
> madvise(MADV_FREE | MADV_USERFAULT) to allow purging and userspace
> fault handling.  In the fault slowpath, you can then regenerate any
> missing data and do MADV_FREE again if it should remain volatile.  And
> again, any actual writes to the region would clear volatility because
> now the cache copy changed and discarding it would mean losing state.

Another scenario that above can't cover.
Someone might put volatility permanently until unmarking so they can
generate cache pages on that range freely without further syscall.

I mean above sugguestion can cover those pages were already mapped
when syscall was called but couldn't cover upcoming fault-in pages
so I think vrange syscall is still needed.

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
