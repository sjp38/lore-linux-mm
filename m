Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EF0E76B007B
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 17:33:54 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so101661386pab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 14:33:54 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id al3si394975pad.232.2015.02.03.14.33.52
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 14:33:53 -0800 (PST)
Date: Wed, 4 Feb 2015 09:33:50 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
Message-ID: <20150203223350.GP6282@dastard>
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru>
 <20150202053708.GG4251@dastard>
 <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
 <20150202081115.GI4251@dastard>
 <54CF51C5.5050801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54CF51C5.5050801@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Oleg Drokin <green@linuxhacker.ru>, cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Feb 02, 2015 at 10:30:29AM +0000, Steven Whitehouse wrote:
> Hi,
> 
> On 02/02/15 08:11, Dave Chinner wrote:
> >On Mon, Feb 02, 2015 at 01:57:23AM -0500, Oleg Drokin wrote:
> >>Hello!
> >>
> >>On Feb 2, 2015, at 12:37 AM, Dave Chinner wrote:
> >>
> >>>On Sun, Feb 01, 2015 at 10:59:54PM -0500, green@linuxhacker.ru wrote:
> >>>>From: Oleg Drokin <green@linuxhacker.ru>
> >>>>
> >>>>leaf_dealloc uses vzalloc as a fallback to kzalloc(GFP_NOFS), so
> >>>>it clearly does not want any shrinker activity within the fs itself.
> >>>>convert vzalloc into __vmalloc(GFP_NOFS|__GFP_ZERO) to better achieve
> >>>>this goal.
....
> >>>>	ht = kzalloc(size, GFP_NOFS | __GFP_NOWARN);
> >>>>	if (ht == NULL)
> >>>>-		ht = vzalloc(size);
> >>>>+		ht = __vmalloc(size, GFP_NOFS | __GFP_NOWARN | __GFP_ZERO,
> >>>>+			       PAGE_KERNEL);
> >>>That, in the end, won't help as vmalloc still uses GFP_KERNEL
> >>>allocations deep down in the PTE allocation code. See the hacks in
> >>>the DM and XFS code to work around this. i.e. go look for callers of
> >>>memalloc_noio_save().  It's ugly and grotesque, but we've got no
> >>>other way to limit reclaim context because the MM devs won't pass
> >>>the vmalloc gfp context down the stack to the PTE allocations....
....
> >>So, I did some digging in archives and found this thread from
> >>2010 onward with various patches and rants.  Not sure how I
> >>missed that before.
> >>
> >>Should we have another run at this I wonder?
> >
> >By all means, but I don't think you'll have any more luck than
> >anyone else in the past. We've still got the problem of attitude
> >("vmalloc is not for general use") and making it actually work is
> >seen as "encouraging undesirable behaviour". If you can change
> >attitudes towards vmalloc first, then you'll be much more likely to
> >make progress in getting these problems solved....
> 
> Well I don't know whether it has to be vmalloc that provides the
> solution here... if memory fragmentation could be controlled then
> kmalloc of larger contiguous chunks of memory could be done using
> that, which might be a better solution overall.

Which has been said repeatedly for the past 15 years. And after all
this time kmalloc is still horribly unreliable for large contiguous
allocations. Hence we still have need for vmalloc for large
contiguous buffers because we have places where memory allocation
failure is simply not an option.

> But I do agree that
> we need to try and come to some kind of solution to this problem as
> it is one of those things that has been rumbling on for a long time
> without a proper solution.
> 
> I also wonder if vmalloc is still very slow? That was the case some
> time ago when I noticed a problem in directory access times in gfs2,
> which made us change to use kmalloc with a vmalloc fallback in the
> first place,

Another of the "myths" about vmalloc. The speed and scalability of
vmap/vmalloc is a long solved problem - Nick Piggin fixed the worst
of those problems 5-6 years ago - see the rewrite from 2008 that
started with commit db64fe0 ("mm: rewrite vmap layer")....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
