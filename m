Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 06BF66B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 20:33:15 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so8005340pab.39
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 17:33:15 -0700 (PDT)
Date: Tue, 8 Oct 2013 09:34:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
Message-ID: <20131008003430.GE25780@bbox>
References: <1380761503-14509-6-git-send-email-john.stultz@linaro.org>
 <52533C12.9090007@zytor.com>
 <5253404D.2030503@linaro.org>
 <52534331.2060402@zytor.com>
 <52534692.7010400@linaro.org>
 <525347BE.7040606@zytor.com>
 <525349AE.1070904@linaro.org>
 <52534AEC.5040403@zytor.com>
 <20131008001306.GD25780@bbox>
 <52534F60.9030500@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52534F60.9030500@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Oct 07, 2013 at 05:18:40PM -0700, John Stultz wrote:
> On 10/07/2013 05:13 PM, Minchan Kim wrote:
> > Hello Peter,
> >
> > On Mon, Oct 07, 2013 at 04:59:40PM -0700, H. Peter Anvin wrote:
> >> On 10/07/2013 04:54 PM, John Stultz wrote:
> >>>> And wouldn't this apply to MADV_DONTNEED just as well?  Perhaps what we
> >>>> should do is an enhanced madvise() call?
> >>> Well, I think MADV_DONTNEED doesn't *have* do to anything at all. Its
> >>> advisory after all. So it may immediately wipe out any data, but it may not.
> >>>
> >>> Those advisory semantics work fine w/ VRANGE_VOLATILE. However,
> >>> VRANGE_NONVOLATILE is not quite advisory, its telling the system that it
> >>> requires the memory at the specified range to not be volatile, and we
> >>> need to correctly inform userland how much was changed and if any of the
> >>> memory we did change to non-volatile was purged since being set volatile.
> >>>
> >>> In that way it is sort of different from madvise. Some sort of an
> >>> madvise2 could be done, but then the extra purge state argument would be
> >>> oddly defined for any other mode.
> >>>
> >>> Is your main concern here just wanting to have a zero-fill mode with
> >>> volatile ranges? Or do you really want to squeeze this in to the madvise
> >>> call interface?
> >> The point is that MADV_DONTNEED is very similar in that sense,
> >> especially if allowed to be lazy.  It makes a lot of sense to permit
> >> both scrubbing modes orthogonally.
> >>
> >> The point you're making has to do with withdrawal of permission to flush
> >> on demand, which is a result of having the lazy mode (ongoing
> >> permission) and having to be able to withdraw such permission.
> > I'm sorry I could not understand what you wanted to say.
> > Could you elaborate a bit?
> My understanding of his point is that VRANGE_VOLATILE is like a lazy
> MADV_DONTNEED (with sigbus, rather then zero fill on fault), suggests
> that we should find a way to have VRANGE_VOLATILE be something like
> MADV_DONTNEED|MADV_LAZY|MADV_SIGBUS_FAULT, instead of adding a new
> syscall.  This would provide more options, since one could instead just
> do MADV_DONTNEED|MADV_LAZY if they wanted zero-fill faults.

Hmm, actually, I have thought VRANGE_SIGBUS option because Address/Thread
sanitizer people wanted it as you know and someone might want it, too.

I agree it's orthogonal but not sure MADV_LAZY and MADV_SIGBUS_FAULT can be
used for other combination of advise except MADV_DONTNEED so it might
confuse userland without benefit.

> 
> And indeed, for the VRANGE_VOLATILE case, we could do something like
> that, but the unresolved problem I see is that that we still need to
> handle the VRANGE_NONVOLATILE case, and the madvise() interface doesn't
> seem to accomodate the needed semantics well.

VRANGE_VOLATILE case could be a problem. In my mind, I had an idea to
return purged state when we call vrange(VRANGE_VOLATILE) because kernel
could purge them as soon as vrange(VRANGE_VOLATILE) called if memory is
really tight so userland can notice "purging" earlier and kernel can
discard them more efficiently.


> 
> thanks
> -john
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
