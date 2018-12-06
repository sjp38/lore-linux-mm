Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35AA76B7CAE
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:24:46 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so1516030pfe.10
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:24:46 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id h31si1112908pgl.482.2018.12.06.14.24.43
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 14:24:44 -0800 (PST)
Date: Fri, 7 Dec 2018 09:24:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/4][V4] drop the mmap_sem when doing IO in the fault path
Message-ID: <20181206222440.GA19305@dastard>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181204144931.03566f7e21615e3c2c1b18e8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204144931.03566f7e21615e3c2c1b18e8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Tue, Dec 04, 2018 at 02:49:31PM -0800, Andrew Morton wrote:
> On Fri, 30 Nov 2018 14:58:08 -0500 Josef Bacik <josef@toxicpanda.com> wrote:
> 
> > Now that we have proper isolation in place with cgroups2 we have started going
> > through and fixing the various priority inversions.  Most are all gone now, but
> > this one is sort of weird since it's not necessarily a priority inversion that
> > happens within the kernel, but rather because of something userspace does.
> > 
> > We have giant applications that we want to protect, and parts of these giant
> > applications do things like watch the system state to determine how healthy the
> > box is for load balancing and such.  This involves running 'ps' or other such
> > utilities.  These utilities will often walk /proc/<pid>/whatever, and these
> > files can sometimes need to down_read(&task->mmap_sem).  Not usually a big deal,
> > but we noticed when we are stress testing that sometimes our protected
> > application has latency spikes trying to get the mmap_sem for tasks that are in
> > lower priority cgroups.
> > 
> > This is because any down_write() on a semaphore essentially turns it into a
> > mutex, so even if we currently have it held for reading, any new readers will
> > not be allowed on to keep from starving the writer.  This is fine, except a
> > lower priority task could be stuck doing IO because it has been throttled to the
> > point that its IO is taking much longer than normal.  But because a higher
> > priority group depends on this completing it is now stuck behind lower priority
> > work.
> > 
> > In order to avoid this particular priority inversion we want to use the existing
> > retry mechanism to stop from holding the mmap_sem at all if we are going to do
> > IO.  This already exists in the read case sort of, but needed to be extended for
> > more than just grabbing the page lock.  With io.latency we throttle at
> > submit_bio() time, so the readahead stuff can block and even page_cache_read can
> > block, so all these paths need to have the mmap_sem dropped.
> > 
> > The other big thing is ->page_mkwrite.  btrfs is particularly shitty here
> > because we have to reserve space for the dirty page, which can be a very
> > expensive operation.  We use the same retry method as the read path, and simply
> > cache the page and verify the page is still setup properly the next pass through
> > ->page_mkwrite().
> 
> Seems reasonable.  I have a few minorish changeloggish comments.
> 
> We're at v4 and no acks have been gathered?

I looked at previous versions and had a bunch of questions and
change requests. I haven't had time to look at this version yet,
but seeing as the page_mkwrite() stuff has been dropped from this
version it isn't useful anymore for solving the problem I had in
mind when reviewing it originally...

What I really want is unconditionally retriable page faults so the
filesystem can cause the page fault to be restarted from scratch. We
have a requirement for DAX and shared data extents (reflink) to
work, and that requires changing the faulted page location during
page_mkwrite. i.e. we get a fault on a read mapped shared page, then
we have to do a copy-on-write operation to break physical data
sharing and so the page with the file data in it physically changes
during ->page_mkwrite (because DAX). Hence we need to restart the
page fault to map the new page correctly because the file no longer
points at the page that was originally faulted.

With this stashed-page-and-retry mechanism implemented for
->page_mkwrite, we could stash the new page in the vmf and tell the
fault to retry, and everything would just work. Without
->page_mkwrite support, it's just not that interesting and I have
higher priority things to deal with right now....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
