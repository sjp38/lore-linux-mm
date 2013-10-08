Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 173306B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 20:02:44 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so7721600pdj.7
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 17:02:43 -0700 (PDT)
Date: Tue, 8 Oct 2013 09:03:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
Message-ID: <20131008000357.GC25780@bbox>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
 <1380761503-14509-6-git-send-email-john.stultz@linaro.org>
 <52533C12.9090007@zytor.com>
 <5253404D.2030503@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5253404D.2030503@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, John and Peter

On Mon, Oct 07, 2013 at 04:14:21PM -0700, John Stultz wrote:
> On 10/07/2013 03:56 PM, H. Peter Anvin wrote:
> > On 10/02/2013 05:51 PM, John Stultz wrote:
> >> From: Minchan Kim <minchan@kernel.org>
> >>
> >> This patch adds new system call sys_vrange.
> >>
> >> NAME
> >> 	vrange - Mark or unmark range of memory as volatile
> >>
> > vrange() is about as nondescriptive as one can get -- there is exactly
> > one letter that has any connection with that this does.
> 
> 
> Hrm. Any suggestions? Would volatile_range() be better?
> 
> 
> >
> >> SYNOPSIS
> >> 	int vrange(unsigned_long start, size_t length, int mode,
> >> 			 int *purged);
> >>
> >> DESCRIPTION
> >> 	Applications can use vrange(2) to advise the kernel how it should
> >> 	handle paging I/O in this VM area.  The idea is to help the kernel
> >> 	discard pages of vrange instead of reclaiming when memory pressure
> >> 	happens. It means kernel doesn't discard any pages of vrange if
> >> 	there is no memory pressure.
> >>
> >> 	mode:
> >> 	VRANGE_VOLATILE
> >> 		hint to kernel so VM can discard in vrange pages when
> >> 		memory pressure happens.
> >> 	VRANGE_NONVOLATILE
> >> 		hint to kernel so VM doesn't discard vrange pages
> >> 		any more.
> >>
> >> 	If user try to access purged memory without VRANGE_NOVOLATILE call,
> >> 	he can encounter SIGBUS if the page was discarded by kernel.
> >>
> >> 	purged: Pointer to an integer which will return 1 if
> >> 	mode == VRANGE_NONVOLATILE and any page in the affected range
> >> 	was purged. If purged returns zero during a mode ==
> >> 	VRANGE_NONVOLATILE call, it means all of the pages in the range
> >> 	are intact.
> > I'm a bit confused about the "purged"
> >
> > From an earlier version of the patch:
> >
> >> - What's different with madvise(DONTNEED)?
> >>
> >>   System call semantic
> >>
> >>   DONTNEED makes sure user always can see zero-fill pages after
> >>   he calls madvise while vrange can see data or encounter SIGBUS.
> > This difference doesn't seem to be a huge one.  The other one seems to
> > be the blocking status of MADV_DONTNEED, which perhaps may be better
> > handled by adding an option (MADV_LAZY) perhaps?
> >
> > That way we would have lazy vs. immediate, and zero versus SIGBUS.
> 
> And some sort of lazy-cancling call as well.
> 
> 
> >
> > I see from the change history of the patch that this was an madvise() at
> > some point, but was changed into a separate system call at some point,
> > does anyone remember why that was?  A quick look through my LKML
> > archives doesn't really make it clear.
> 
> The reason we can't use madvise, is that to properly handle error cases
> and report the pruge state, we need an extra argument.
> 
> In much earlier versions, we just returned an error when setting
> NONVOLATILE if the data was purged. However, since we have to possibly
> do allocations when marking a range as non-volatile, we needed a way to
> properly handle that allocation failing. We can't just return ENOMEM, as
> we may have already marked purged memory as non-volatile.
> 
> Thus, that's why with vrange, we return the number of bytes modified,
> along with the purge state. That way, if an error does occur we can
> return the purge state of the bytes successfully modified, and only
> return an error if nothing was changed, much like when a write fails.

As well, we might need addtional argument VRANGE_FULL/VRANGE_PARTIAL
for vrange system call. I discussed it long time ago but omitted it
for early easy review phase. It is requested by Mozilla fork and of course
I think it makes sense to me.

https://lkml.org/lkml/2013/3/22/20

In short, if you mark a range with VRANGE_FULL, kernel can discard all
of pages within the range if memory is tight while kernel can discard
part of pages in the vrange if you mark the range with VRANGE_PARTIAL.



> 
> thanks
> -john
> 
> 
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
