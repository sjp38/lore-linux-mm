Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 04C2A6B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 20:30:14 -0500 (EST)
Received: by pablf10 with SMTP id lf10so23469371pab.6
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 17:30:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h3si7149859pdi.120.2015.02.22.17.30.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 17:30:12 -0800 (PST)
Date: Sun, 22 Feb 2015 17:29:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-Id: <20150222172930.6586516d.akpm@linux-foundation.org>
In-Reply-To: <20150223004521.GK12722@dastard>
References: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
	<201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
	<20150210151934.GA11212@phnom.home.cmpxchg.org>
	<201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
	<201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
	<20150217125315.GA14287@phnom.home.cmpxchg.org>
	<20150217225430.GJ4251@dastard>
	<20150219102431.GA15569@phnom.home.cmpxchg.org>
	<20150219225217.GY12722@dastard>
	<20150221235227.GA25079@phnom.home.cmpxchg.org>
	<20150223004521.GK12722@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, 23 Feb 2015 11:45:21 +1100 Dave Chinner <david@fromorbit.com> wrote:

> > > I really don't care about the OOM Killer corner cases - it's
> > > completely the wrong way line of development to be spending time on
> > > and you aren't going to convince me otherwise. The OOM killer a
> > > crutch used to justify having a memory allocation subsystem that
> > > can't provide forward progress guarantee mechanisms to callers that
> > > need it.
> > 
> > We can provide this.  Are all these callers able to preallocate?
> 
> Anything that allocates in transaction context (and therefor is
> GFP_NOFS by definition) can preallocate at transaction reservation
> time. However, preallocation is dumb, complex, CPU and memory
> intensive and will have a *massive* impact on performance.
> Allocating 10-100 pages to a reserve which we will almost *never
> use* and then free them again *on every single transaction* is a lot
> of unnecessary additional fast path overhead.  Hence a "preallocate
> for every context" reserve pool is not a viable solution.

Yup.

> Reservations are simply an *accounting* of the maximum amount of a
> reserve required by an operation to guarantee forwards progress. In
> filesystems, we do this for log space (transactions) and some do it
> for filesystem space (e.g. delayed allocation needs correct ENOSPC
> detection so we don't overcommit disk space).  The VM already has
> such concepts (e.g. watermarks and things like min_free_kbytes) that
> it uses to ensure that there are sufficient reserves for certain
> types of allocations to succeed.

Yes, as we do for __GFP_HIGH and PF_MEMALLOC etc.  Add a dynamic
reserve.  So to reserve N pages we increase the page allocator dynamic
reserve by N, do some reclaim if necessary then deposit N tokens into
the caller's task_struct (it'll be a set of zone/nr-pages tuples I
suppose).

When allocating pages the caller should drain its reserves in
preference to dipping into the regular freelist.  This guy has already
done his reclaim and shouldn't be penalised a second time.  I guess
Johannes's preallocation code should switch to doing this for the same
reason, plus the fact that snipping a page off
task_struct.prealloc_pages is super-fast and needs to be done sometime
anyway so why not do it by default.

Both reservation and preallocation are vulnerable to deadlocks - 10,000
tasks all trying to reserve/prealloc 100 pages, they all have 50 pages
and we ran out of memory.  Whoops.  We can undeadlock by returning
ENOMEM but I suspect there will still be problematic situations where
massive numbers of pages are temporarily AWOL.  Perhaps some form of
queuing and throttling will be needed, to limit the peak number of
reserved pages.  Per zone, I guess.

And it'll be a huge pain handling order>0 pages.  I'd be inclined to
make it order-0 only, and tell the lamer callers that
vmap-is-thattaway.  Alas, one lame caller is slub.


But the biggest issue is how the heck does a caller work out how many
pages to reserve/prealloc?  Even a single sb_bread() - it's sitting on
loop on a sparse NTFS file on loop on a five-deep DM stack on a
six-deep MD stack on loop on NFS on an eleventy-deep networking stack. 
And then there will be an unknown number of slab allocations of unknown
size with unknown slabs-per-page rules - how many pages needed for
them?  And to make it much worse, how many pages of which orders? 
Bless its heart, slub will go and use a 1-order page for allocations
which should have been in 0-order pages..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
