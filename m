Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id A03436B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 18:57:10 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7696844pbc.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 15:57:10 -0700 (PDT)
Message-ID: <52533C12.9090007@zytor.com>
Date: Mon, 07 Oct 2013 15:56:18 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-6-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/02/2013 05:51 PM, John Stultz wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> This patch adds new system call sys_vrange.
> 
> NAME
> 	vrange - Mark or unmark range of memory as volatile
> 

vrange() is about as nondescriptive as one can get -- there is exactly
one letter that has any connection with that this does.

> SYNOPSIS
> 	int vrange(unsigned_long start, size_t length, int mode,
> 			 int *purged);
> 
> DESCRIPTION
> 	Applications can use vrange(2) to advise the kernel how it should
> 	handle paging I/O in this VM area.  The idea is to help the kernel
> 	discard pages of vrange instead of reclaiming when memory pressure
> 	happens. It means kernel doesn't discard any pages of vrange if
> 	there is no memory pressure.
> 
> 	mode:
> 	VRANGE_VOLATILE
> 		hint to kernel so VM can discard in vrange pages when
> 		memory pressure happens.
> 	VRANGE_NONVOLATILE
> 		hint to kernel so VM doesn't discard vrange pages
> 		any more.
> 
> 	If user try to access purged memory without VRANGE_NOVOLATILE call,
> 	he can encounter SIGBUS if the page was discarded by kernel.
> 
> 	purged: Pointer to an integer which will return 1 if
> 	mode == VRANGE_NONVOLATILE and any page in the affected range
> 	was purged. If purged returns zero during a mode ==
> 	VRANGE_NONVOLATILE call, it means all of the pages in the range
> 	are intact.

I'm a bit confused about the "purged"

>From an earlier version of the patch:

> - What's different with madvise(DONTNEED)?
> 
>   System call semantic
> 
>   DONTNEED makes sure user always can see zero-fill pages after
>   he calls madvise while vrange can see data or encounter SIGBUS.

This difference doesn't seem to be a huge one.  The other one seems to
be the blocking status of MADV_DONTNEED, which perhaps may be better
handled by adding an option (MADV_LAZY) perhaps?

That way we would have lazy vs. immediate, and zero versus SIGBUS.

I see from the change history of the patch that this was an madvise() at
some point, but was changed into a separate system call at some point,
does anyone remember why that was?  A quick look through my LKML
archives doesn't really make it clear.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
