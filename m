Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8B57E6B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:32:19 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so12358739pde.19
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:32:19 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id z1si30138906pas.101.2014.09.10.19.32.17
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 19:32:18 -0700 (PDT)
Date: Thu, 11 Sep 2014 12:32:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: lockdep warning when logging in via ssh
Message-ID: <20140911023213.GN20518@dastard>
References: <5410D3E7.2020804@redhat.com>
 <alpine.LSU.2.11.1409101609380.3685@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409101609380.3685@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Prarit Bhargava <prarit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Sandeen <esandeen@redhat.com>

On Wed, Sep 10, 2014 at 04:24:16PM -0700, Hugh Dickins wrote:
> On Wed, 10 Sep 2014, Prarit Bhargava wrote:
> 
> > I see this when I attempt to login via ssh.  I do not see it if I login on
> > the serial console.
....
> > 
> > According to Dave Chinner:
> > 
> > "It's the shmem code that is broken - instantiating an inode while
> > holding the mmap_sem inverts lock orders all over the place,
> > especially in the security subsystem...."
> 
> Interesting, thank you.  But it seems a bit late to accuse shmem
> of doing the wrong thing here: mmap -> shmem_zero_setup worked this
> way in 2.4.0 (if not before) and has done ever since.
> 
> Only now is a problem reported, so perhaps a change is needed rather
> at the xfs end - unless Dave has a suggestion for how to change it
> easily at the shmem end.
> 
> Or is xfs not the one to change recently, but something else in the stack?

XFS recently added directory inode specific lockdep class
annotations. AFAIA, nobody else has done this so nobody else will
have tripped over this issue. Effectively, lockdep is complaining
that shmem is taking inode security locks in a different order to
what it sees XFS taking directory locks and page faults in the
readdir path.

That is, VFS lock order is directory i_mutex/security lock on file
creation, directory i_mutex/filldir/may_fault(mmap_sem) on readdir
operations. Hence both the security lock and mmap_sem nest under
i_mutex in real filesystems, but on shmem the security lock nests
under mmap_sem because of inode instantiation.

Now, lockdep is too naive to realise that these are completely
different filesystems and so (probably) aren't in danger of
deadlocks, but the fact is that having shmem instantiate an inode as
a result of a page fault is -surprising- to say the least.

I said that "It's the shmem code that is broken" bluntly because
this has already been reported to the linux-mm list twice by me, and
it's been ignored twice. it may be that what shmem is doing is OK,
but the fact is that it is /very different/ to anyone else and is
triggering lockdep reports against the normal behaviour on other
filesystems.

My point is that avoiding the lockdep report or fixing any other
issue that it uncovers is not an XFS problem - shmem is doing the
weird thing and we should not be working around shmem idiosyncracies
in XFS or other filesystems....

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
