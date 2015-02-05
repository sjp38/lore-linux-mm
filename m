Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E3C34828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:11:54 -0500 (EST)
Received: by pdev10 with SMTP id v10so9777346pde.10
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:11:54 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id g8si7478988pdo.134.2015.02.05.12.11.52
        for <linux-mm@kvack.org>;
        Thu, 05 Feb 2015 12:11:53 -0800 (PST)
Date: Fri, 6 Feb 2015 07:11:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
Message-ID: <20150205201149.GJ12722@dastard>
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru>
 <20150202053708.GG4251@dastard>
 <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
 <20150202081115.GI4251@dastard>
 <54CF51C5.5050801@redhat.com>
 <20150203223350.GP6282@dastard>
 <BD2045CE-45AD-4D79-8C8D-C854D112DCC5@linuxhacker.ru>
 <54D1EB3E.9050208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D1EB3E.9050208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Oleg Drokin <green@linuxhacker.ru>, cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Feb 04, 2015 at 09:49:50AM +0000, Steven Whitehouse wrote:
> Hi,
> 
> On 04/02/15 07:13, Oleg Drokin wrote:
> >Hello!
> >
> >On Feb 3, 2015, at 5:33 PM, Dave Chinner wrote:
> >>>I also wonder if vmalloc is still very slow? That was the case some
> >>>time ago when I noticed a problem in directory access times in gfs2,
> >>>which made us change to use kmalloc with a vmalloc fallback in the
> >>>first place,
> >>Another of the "myths" about vmalloc. The speed and scalability of
> >>vmap/vmalloc is a long solved problem - Nick Piggin fixed the worst
> >>of those problems 5-6 years ago - see the rewrite from 2008 that
> >>started with commit db64fe0 ("mm: rewrite vmap layer")....
> >This actually might be less true than one would hope. At least somewhat
> >recent studies by LLNL (https://jira.hpdd.intel.com/browse/LU-4008)
> >show that there's huge contention on vmlist_lock, so if you have vmalloc
> >intense workloads, you get penalized heavily. Granted, this is rhel6 kernel,
> >but that is still (albeit heavily modified) 2.6.32, which was released at
> >the end of 2009, way after 2008.
> >I see that vmlist_lock is gone now, but e.g. vmap_area_lock that is heavily
> >used is still in place.
> >
> >So of course with that in place there's every incentive to not use vmalloc
> >if at all possible. But if used, one would still hopes it would be at least
> >safe to do even if somewhat slow.
> >
> >Bye,
> >     Oleg
> 
> I was thinking back to this thread:
> https://lkml.org/lkml/2010/4/12/207
> 
> More recent than 2008, and although it resulted in a patch that
> apparently fixed the problem, I don't think it was ever applied on
> the basis that it was too risky and kmalloc was the proper solution
> anyway.... I've not tested recently, so it may have been fixed in
> the mean time,

IIUC, the problem was resolved with a different fix back in 2011 - a
lookaside cache that avoids the overhead of searching the entire
list on every vmalloc. 

commit 89699605fe7cfd8611900346f61cb6cbf179b10a
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Mar 22 16:30:36 2011 -0700

    mm: vmap area cache

    Provide a free area cache for the vmalloc virtual address allocator, based
    on the algorithm used by the user virtual memory allocator.

    This reduces the number of rbtree operations and linear traversals over
    the vmap extents in order to find a free area, by starting off at the last
    point that a free area was found.
....
    After this patch, the search will start from where it left off, giving
    closer to an amortized O(1).

    This is verified to solve regressions reported Steven in GFS2, and Avi in
    KVM.
....

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
