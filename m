Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1585568101F
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:21:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so40157767pgi.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:21:35 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id w31si8221815pla.66.2017.02.16.14.21.32
        for <linux-mm@kvack.org>;
        Thu, 16 Feb 2017 14:21:33 -0800 (PST)
Date: Fri, 17 Feb 2017 09:21:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170216222129.GB15349@dastard>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
 <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
 <20170215160538.GA62565@bfoster.bfoster>
 <a055abbf-a471-d111-9491-dc5b00208228@beget.ru>
 <20170215180859.GB62565@bfoster.bfoster>
 <07ee50bc-8220-dda8-07f9-369758603df9@beget.ru>
 <20170216172034.GC11750@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216172034.GC11750@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Alexander Polakov <apolyakov@beget.ru>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Feb 16, 2017 at 12:20:34PM -0500, Brian Foster wrote:
> On Thu, Feb 16, 2017 at 01:56:30PM +0300, Alexander Polakov wrote:
> > On 02/15/2017 09:09 PM, Brian Foster wrote:
> > > Ah, Ok. It sounds like this allows the reclaim thread to carry on into
> > > other shrinkers and free up memory that way, perhaps. This sounds kind
> > > of similar to the issue brought up previously here[1], but not quite the
> > > same in that instead of backing off of locking to allow other shrinkers
> > > to progress, we back off of memory allocations required to free up
> > > inodes (memory).
> > > 
> > > In theory, I think something analogous to a trylock for inode to buffer
> > > mappings that are no longer cached (or more specifically, cannot
> > > currently be allocated) may work around this, but it's not immediately
> > > clear to me whether that's a proper fix (it's also probably not a
> > > trivial change either). I'm still kind of curious why we end up with
> > > dirty inodes with reclaimed buffers. If this problem repeats, is it
> > > always with a similar stack (i.e., reclaim -> xfs_iflush() ->
> > > xfs_imap_to_bp())?
> > 
> > Looks like it is.
> > 
> > > How many independent filesystems are you running this workload against?
> > 
> > storage9 : ~ [0] # mount|grep storage|grep xfs|wc -l
> > 15
> > storage9 : ~ [0] # mount|grep storage|grep ext4|wc -l
> > 44
> > 
> 
> So a decent number of fs', more ext4 than XFS. Are the XFS fs' all of
> similar size/geometry? If so, can you send representative xfs_info
> output for the fs'?
> 
> I'm reading back through that reclaim thread[1] and it appears this
> indeed is not a straightforward issue. It sounds like the summary is
> Chris hit the same general behavior you have and is helped by bypassing
> the synchronous nature of the shrinker. This allows other shrinkers to
> proceed, but this is not a general solution because other workloads
> depend on the synchronous shrinker behavior to throttle direct reclaim.
> I can't say I understand all of the details and architecture of how/why
> that is the case.

It's complicated, made worse by the state of flux of the mm reclaim
subsystem and the frequent regressions in behaviour that come and
go. This makes testing modifications to the shrinker behaviour
extremely challenging - trying to separate shirnker artifacts from
"something else has changed in memory reclaim" takes a lot of
time....

> FWIW, it sounds like the first order problem is that we generally don't
> want to find/flush dirty inodes from reclaim.

Right. because that forces out-of-order inode writeback and it
degenerates into blocking small random writes.

> A couple things that might
> help avoid this situation are more aggressive
> /proc/sys/fs/xfs/xfssyncd_centisecs tuning or perhaps considering a
> smaller log size would cause more tail pushing pressure on the AIL
> instead of pressure originating from memory reclaim. The latter might
> not be so convenient if this is an already populated backup server,
> though.
> 
> Beyond that, there's Chris' patch, another patch that Dave proposed[2],
> and obviously your hack here to defer inode reclaim entirely to the
> workqueue (I've CC'd Dave since it sounds like he might have been
> working on this further..).

I was working on a more solid set of changes, but every time I
updated the kernel tree I used as my base for development, the
baseline kernel reclaim behaviour would change. I'd isolate the
behavioural change, upgrade to the kernel that contained the fix,
and then trip over some new whacky behaviour that made no sense. I
spent more time in this loop than actually trying to fix the XFS
problem - chasing a moving target makes finding the root cause of
the reclaim stalls just about impossible. 

Brian, I can send you what I have but it's really just a bag of
bolts at this point because I was never able to validate that any of
the patches made a measurable improvement to reclaim behaviour under
any workload I ran.....

FWIW, the major problem with removing the blocking in inode reclaim
is the ease with which you can then trigger the OOM killer from
userspace.  The high level memory reclaim algorithms break down when
there are hundreds of direct reclaim processes hammering on reclaim
and reclaim stops making progress because it's skipping dirty
objects.  Direct reclaim ends up insufficiently throttled, so rather
than blocking it winds up reclaim priority and then declares OOM
because reclaim runs out of retries before sufficient memory has
been freed.

That, right now, looks to be an unsolvable problem without a major
rework of direct reclaim.  I've pretty much given up on ever getting
the unbound direct reclaim concurrency problem that is causing us
these problems fixed, so we are left to handle it in the subsystem
shrinkers as best we can. That leaves us with an unfortunate choice: 

	a) throttle excessive concurrency in the shrinker to prevent
	   IO breakdown, thereby causing reclaim latency bubbles
	   under load but having a stable, reliable system; or
	b) optimise for minimal reclaim latency and risk userspace
	   memory demand triggering the OOM killer whenever there
	   are lots of dirty inodes in the system.

Quite frankly, there's only one choice we can make in this
situation: reliability is always more important than performance.

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
