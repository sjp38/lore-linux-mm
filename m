Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 91FC36B0127
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:11:05 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so967578pab.34
        for <linux-mm@kvack.org>; Thu, 08 May 2014 16:11:05 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id vv4si1187677pbc.279.2014.05.08.16.11.03
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 16:11:04 -0700 (PDT)
Date: Fri, 9 May 2014 08:12:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/4] MADV_VOLATILE: Add MADV_VOLATILE/NONVOLATILE hooks
 and handle marking vmas
Message-ID: <20140508231259.GA25951@bbox>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
 <1398806483-19122-3-git-send-email-john.stultz@linaro.org>
 <20140508012142.GA5282@bbox>
 <536BB310.1050105@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <536BB310.1050105@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 08, 2014 at 09:38:40AM -0700, John Stultz wrote:
> On 05/07/2014 06:21 PM, Minchan Kim wrote:
> > Hey John,
> >
> > On Tue, Apr 29, 2014 at 02:21:21PM -0700, John Stultz wrote:
> >> This patch introduces MADV_VOLATILE/NONVOLATILE flags to madvise(),
> >> which allows for specifying ranges of memory as volatile, and able
> >> to be discarded by the system.
> >>
> >> This initial patch simply adds flag handling to madvise, and the
> >> vma handling, splitting and merging the vmas as needed, and marking
> >> them with VM_VOLATILE.
> >>
> >> No purging or discarding of volatile ranges is done at this point.
> >>
> >> This a simplified implementation which reuses some of the logic
> >> from Minchan's earlier efforts. So credit to Minchan for his work.
> > Remove purged argument is really good thing but I'm not sure merging
> > the feature into madvise syscall is good idea.
> > My concern is how we support user who don't want SIGBUS.
> > I believe we should support them because someuser(ex, sanitizer) really
> > want to avoid MADV_NONVOLATILE call right before overwriting their cache
> > (ex, If there was purged page for cyclic cache, user should call NONVOLATILE
> > right before overwriting to avoid SIGBUS).
> 
> So... Why not use MADV_FREE then for this case?

MADV_FREE is one-shot operation. I mean we should call it again to make
them lazyfree while vrange could preserve volatility.
Pz, think about thread-sanitizer usecase. They do mmap 70TB once start up
and want to mark the range as volatile. If they uses MADV_FREE instead of
volatile, they should mark 70TB as lazyfree periodically, which is terrible
because MADV_FREE's cost is O(N).

> 
> Just to be clear, by moving back to madvise, I'm not trying to replace
> MADV_FREE. I think you're work there is still useful and splitting the
> semantics between the two is cleaner.

I know.
New vrange syscall which works with existing VMA instead of new vrange
interval tree removed big concern from mm folks about duplicating
of manage layer(ex, vm_area_struct and vrange inteval tree) and
it removed my concern that mmap_sem write-side lock scalability for
allocator usecase so we can make the implemenation simple and clear.
I like it but zero-page VS SIGBUS is another issue we should make an
agreement.

> 
> 
> > Moreover, this changes made unmarking cost O(N) so I'd like to avoid
> > NOVOLATILE syscall if possible.
> Well, I think that was made in v13, but yes. NONVOLATILE is currently an
> expensive operation in order to keep the semantics simpler, as requested
> by Johannes and Kosaki-san.
> 
> 
> > For me, SIGBUS is more special usecase for code pages but I believe
> > both are reasonable for each usecase so my preference is MADV_VOLATILE
> > is just zero-filled page and MADV_VOLATILE_SIGBUS, another new advise
> > if you really want to merge volatile range feature with madvise.
> 
> This I disagree with. Even for non-code page cases, SIGBUS on volatile
> page access is important for normal users who might accidentally touch
> volatile data, so they know they are corrupting their data. I know
> Johannes suggested this is simply a use-after-free issue, but I really
> feel it results in having very strange semantics. And for those cases
> where there is a benefit to zero-fill, MADV_FREE seems more appropriate.

I already explained above why MADV_FREE is not enough.

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
