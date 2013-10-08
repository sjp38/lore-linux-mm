Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 657D96B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 03:10:50 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8189755pbb.13
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 00:10:50 -0700 (PDT)
Date: Tue, 8 Oct 2013 16:12:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
Message-ID: <20131008071202.GB29509@bbox>
References: <52534692.7010400@linaro.org>
 <525347BE.7040606@zytor.com>
 <525349AE.1070904@linaro.org>
 <52534AEC.5040403@zytor.com>
 <20131008001306.GD25780@bbox>
 <52535EE1.3060700@zytor.com>
 <20131008020847.GH25780@bbox>
 <52537326.7000505@gmail.com>
 <20131008030736.GA29509@bbox>
 <52538B95.6080208@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52538B95.6080208@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 08, 2013 at 12:35:33AM -0400, KOSAKI Motohiro wrote:
> (10/7/13 11:07 PM), Minchan Kim wrote:
> >Hi KOSAKI,
> >
> >On Mon, Oct 07, 2013 at 10:51:18PM -0400, KOSAKI Motohiro wrote:
> >>>Maybe, int madvise5(addr, length, MADV_DONTNEED|MADV_LAZY|MADV_SIGBUS,
> >>>         &purged, &ret);
> >>>
> >>>Another reason to make it hard is that madvise(2) is tight coupled with
> >>>with vmas split/merge. It needs mmap_sem's write-side lock and it hurt
> >>>anon-vrange test performance much heavily and userland might want to
> >>>make volatile range with small unit like "page size" so it's undesireable
> >>>to make it with vma. Then, we should filter out to avoid vma split/merge
> >>>in implementation if only MADV_LAZY case? Doable but it could make code
> >>>complicated and lost consistency with other variant of madvise.
> >>
> >>I haven't seen your performance test result. Could please point out URLs?
> >
> >https://lkml.org/lkml/2013/3/12/105
> 
> It's not comparison with and without vma merge. I'm interest how much benefit
> vmas operation avoiding have.

I had an number but lost it so I should set up it in my KVM machine :(
And I needed old kernel 3.7.0 for testing vma-based approach.

DRAM:2G, CPU : 12 

kernel 3.7.0

jemalloc: 20527 records/s
jemalloc vma based approach : 5360 records/s

vrange call made worse because every thread stuck with mmap_sem.

kernel 3.11.0

jemalloc: 21176 records/s
jemalloc vroot tree approach: 103637 records/s

It could enhance 5 times.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
