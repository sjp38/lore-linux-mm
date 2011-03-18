Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AFE2D8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 07:13:08 -0400 (EDT)
Date: Fri, 18 Mar 2011 11:13:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110318111300.GF707@csn.ul.ie>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
 <20110315135334.36e29414.akpm@linux-foundation.org>
 <4D7FEDDC.3020607@fiec.espol.edu.ec>
 <20110315161926.595bdb65.akpm@linux-foundation.org>
 <4D80D65C.5040504@fiec.espol.edu.ec>
 <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110317144727.87a461f9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Villac??s Lasso <avillaci@fiec.espol.edu.ec>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu, Mar 17, 2011 at 02:47:27PM -0700, Andrew Morton wrote:
> On Thu, 17 Mar 2011 16:27:29 -0500
> Alex Villac____s Lasso <avillaci@fiec.espol.edu.ec> wrote:
> 
> > > So it appears that the system is full of dirty pages against a slow
> > > device and your foreground processes have got stuck in direct reclaim
> > > ->  compaction ->  migration.   That's Mel ;)
> > >
> > > What happened to the plans to eliminate direct reclaim?
> > >
> > >
> > Browsing around bugzilla, I believe that bug 12309 looks very similar to the issue I am experiencing, especially from comment #525 onwards. Am I correct in this?
> 
> ah, the epic 12309.  https://bugzilla.kernel.org/show_bug.cgi?id=12309.
> If you're ever wondering how much we suck, go read that one.
> 

I'm reasonably sure over the last few series that we've taken a number of
steps to mitigate the problems described in #12309 although it's been a while
since I double checked. When I last stopped looking at it, we had reached
the stage where the dirty pages encountered by writeback was greatly reduced
which should have affected the stalls reported in that bug. I stopped working
on it further to see see how the IO-less dirty balancing being worked on by
Wu and Jan worked out because the next reasonable step was making sure the
flusher threads were behaving as expected. That is still a work in progress.

> I think what we're seeing in 31142 is a large amount of dirty data
> buffered against a slow device.  Innocent processes enter page reclaim
> and end up getting stuck trying to write to that heavily-queued and
> slow device.
> 
> If so, that's probably what some of the 12309 participants are seeing. 
> But there are lots of other things in that report too.
> 
> 
> Now, the problem you're seeing in 31142 isn't really supposed to
> happen.  In the direct-reclaim case the code will try to avoid
> initiation of blocking I/O against a congested device, via the
> bdi_write_congested() test in may_write_to_queue().  Although that code
> now looks a bit busted for the order>PAGE_ALLOC_COSTLY_ORDER case,
> whodidthat.
> 
> However in the case of the new(ish) compaction/migration code I don't
> think we're performing that test.  migrate_pages()->unmap_and_move()
> will get stuck behind that large&slow IO queue if page reclaim decided
> to pass it down sync==true, as it apparently has done.
> 
> IOW, Mel broke it ;)
> 

\o/ ... no wait, it's the other one - :(

If you look at the stack traces though, all of them had called
do_huge_pmd_anonymous_page() so while it looks similar to 12309, the trigger
is new because it's THP triggering compaction that is causing the stalls
rather than page reclaim doing direct writeback which was the culprit in
the past.

To confirm if this is the case, I'd be very interested in hearing if this
problem persists in the following cases

1. 2.6.38-rc8 with defrag disabled by
   echo never >/sys/kernel/mm/transparent_hugepage/defrag
   (this will stop THP allocations calling into compaction)
2. 2.6.38-rc8 with THP disabled by
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
   (if the problem still persists, then page reclaim is still a problem
    but we should still stop THP doing sync writes)
3. 2.6.37 vanilla
   (in case this is a new regression introduced since then)

Migration can do sync writes on dirty pages which is why it looks so similar
to page reclaim but this can be controlled by the value of sync_migration
passed into try_to_compact_pages(). If we find that option 1 above makes
the regression go away or at least helps a lot, then a reasonable fix may
be to never set sync_migration if __GFP_NO_KSWAPD which is always set for
THP allocations. I've added Andrea to the cc to see what he thinks.

Thanks for the report.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
