Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 29D5E6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 13:36:30 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id r15so3896105ead.41
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 10:36:29 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y48si37219925eew.100.2014.02.03.10.36.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 10:36:28 -0800 (PST)
Date: Mon, 3 Feb 2014 13:36:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140203183614.GL6963@cmpxchg.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <20140129051102.GA11786@bbox>
 <20140131164901.GG6963@cmpxchg.org>
 <20140203145806.GB2542@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140203145806.GB2542@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

On Mon, Feb 03, 2014 at 03:58:06PM +0100, Jan Kara wrote:
> On Fri 31-01-14 11:49:01, Johannes Weiner wrote:
> > On Wed, Jan 29, 2014 at 02:11:02PM +0900, Minchan Kim wrote:
> > > >    The only way to make these semantics clean is either
> > > > 
> > > >      a) have vrange() return a range ID so that only full ranges can
> > > >      later be marked non-volatile, or
> > > 
> > > > 
> > > >      b) remember individual page purges so that sub-range changes can
> > > >      properly report them
> > > > 
> > > >    I don't like a) much because it's somewhat arbitrarily more
> > > >    restrictive than madvise, mprotect, mmap/munmap etc.  And for b),
> > > >    the straight-forward solution would be to put purge-cookies into
> > > >    the page tables to properly report purges in subrange changes, but
> > > >    that would be even more coordination between vmas, page tables, and
> > > >    the ad-hoc vranges.
> > > 
> > > Agree but I don't want to put a accuracy of defalut vrange syscall.
> > > Page table lookup needs mmap_sem and O(N) cost so I'm afraid it would
> > > make userland folks hesitant using this system call.
> > 
> > If userspace sees nothing but cost in this system call, nothing but a
> > voluntary donation for the common good of the system, then it does not
> > matter how cheap this is, nobody will use it.  Why would they?  Even
>   I think this is a flawed logic. If you take it to the extreme then why
> each application doesn't allocate all the available memory and never free
> it? Because users will kick such application in the ass as soon as they
> have a viable alternative. So there is certainly a relatively strong
> benefit in being a good citizen on the system. But it's a matter of a
> tradeoff - if being a good citizen costs you too much (in the extreme if it
> would make the application hardly usable because it is too slow), then you
> just give up or hack it around in some other way...

Oh, that is exactly what I was trying to point out.  The argument was
basically that it has to be as cheap and lightweight as humanly
possible because applications participate voluntarily and they won't
donate memory back if it comes at a cost.

And as you said, this is flawed.  There is an incentive to give back
memory other than altruistic tendencies, namely the looming kick in
the butt.

So I very much agree that there is a trade-off to be had, but I think
the cost of the proposed implementation is not justified.

If we agree that simply not returning memory is unacceptable anyway,
providing an interface that is drastically cheaper than the current
means of returning memory is already an improvement.  Even if it's
still O(#pages).  So I think the incentive to use it is there.  We
should design it to fit into the existing VM and then optimize it,
rather than design for an (unnecessary) optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
