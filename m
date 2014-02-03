Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 54B4F6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 09:58:11 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id x13so11741509wgg.33
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 06:58:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si1607318wik.1.2014.02.03.06.58.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 06:58:09 -0800 (PST)
Date: Mon, 3 Feb 2014 15:58:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140203145806.GB2542@quack.suse.cz>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <20140129000359.GZ6963@cmpxchg.org>
 <20140129051102.GA11786@bbox>
 <20140131164901.GG6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140131164901.GG6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

On Fri 31-01-14 11:49:01, Johannes Weiner wrote:
> On Wed, Jan 29, 2014 at 02:11:02PM +0900, Minchan Kim wrote:
> > >    The only way to make these semantics clean is either
> > > 
> > >      a) have vrange() return a range ID so that only full ranges can
> > >      later be marked non-volatile, or
> > 
> > > 
> > >      b) remember individual page purges so that sub-range changes can
> > >      properly report them
> > > 
> > >    I don't like a) much because it's somewhat arbitrarily more
> > >    restrictive than madvise, mprotect, mmap/munmap etc.  And for b),
> > >    the straight-forward solution would be to put purge-cookies into
> > >    the page tables to properly report purges in subrange changes, but
> > >    that would be even more coordination between vmas, page tables, and
> > >    the ad-hoc vranges.
> > 
> > Agree but I don't want to put a accuracy of defalut vrange syscall.
> > Page table lookup needs mmap_sem and O(N) cost so I'm afraid it would
> > make userland folks hesitant using this system call.
> 
> If userspace sees nothing but cost in this system call, nothing but a
> voluntary donation for the common good of the system, then it does not
> matter how cheap this is, nobody will use it.  Why would they?  Even
  I think this is a flawed logic. If you take it to the extreme then why
each application doesn't allocate all the available memory and never free
it? Because users will kick such application in the ass as soon as they
have a viable alternative. So there is certainly a relatively strong
benefit in being a good citizen on the system. But it's a matter of a
tradeoff - if being a good citizen costs you too much (in the extreme if it
would make the application hardly usable because it is too slow), then you
just give up or hack it around in some other way...

> if it's a lightweight call, they still have to implement a mechanism
> for regenerating content etc.  It's still an investment to make, so
> there has to be a personal benefit or it's flawed from the beginning.
> 
> So why do applications want to use it?
  So I really believe because they want to be a better citizen especially
on the systems where memory is relatively scarce resource (hand helds,
tablets, phones...).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
