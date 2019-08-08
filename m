Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDAB3C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 949DC217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:20:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 949DC217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BF636B0008; Thu,  8 Aug 2019 12:20:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26EB26B000D; Thu,  8 Aug 2019 12:20:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1378C6B000E; Thu,  8 Aug 2019 12:20:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E745A6B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:20:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id m25so85732013qtn.18
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:20:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MxTE/+oxCefbdlHmbdDUrpFZur160jUZHoFCaid+s0I=;
        b=uYmkhpPSzT50J4tKmjRY7+D6iKgmD38woEfhX2URocuPVsq6y9sUlzjBBDmBlz0wXn
         4yq82HBHQ49xj+tqaWRlNEpqJpwBx2cusZyjWVZ/Xth+sEvH4dJ/3H4j0/VNSsSxxrpT
         BSOD0WUPfOzRPeOlkapRu9sgXKv32db2EY044aMczXpZM7yCLWdu46XOz593Z0QHTD3L
         2mi7dvaHYaCMiINRkFW3mKcyrBSc4P9hReEE8TM9hC2IEuLUEQfrEadKjobzCeoe63WI
         jKzqScmuwxsGqNgAIWeDEpjYIZRiyIUwU8Om3sgbyH8mc/Di5LDZjYDorYh51Q48hZ3f
         tzkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWoWdDTTBJJ/wDHcBf0ZjQLD+SB9yakJiqPffHTrqtWQphHlWSO
	vPj3O3P/MmZI7wCkunYhw8o0kMm/k06eJ6afCX/JrfRViKGbYg171arpD8Z18C2rXmBmepEeRRB
	ahf2X4ivApS/8PYk4G1cKw9cN4eR/FQOKfKuJ+8jSX4V+ftjbuS7U0d+AAgUt188lzw==
X-Received: by 2002:a37:4bcc:: with SMTP id y195mr14138372qka.55.1565281251661;
        Thu, 08 Aug 2019 09:20:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb4e5WfMkmw4PC72ng5+IGqcJ0/H8Axm2yeZiEAPzwukIyihIKxr3BUP6CnSYWzYiWF7yX
X-Received: by 2002:a37:4bcc:: with SMTP id y195mr14138268qka.55.1565281250451;
        Thu, 08 Aug 2019 09:20:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565281250; cv=none;
        d=google.com; s=arc-20160816;
        b=mmV5BKp5+p3ZyUeqoAL/QUEPPbjOpX7l+tXNhetAbZzHYINbHcwgj8IJC5pxF32jno
         3RJHK5a/i782m4NqNM4dnv5G+9j5IdqOM7PBKc/w9GECa6wOLNb3vWdkVXiTAuhjI0SB
         vID/L/lpiM6gqaKkLXcvlljeLR+wcbE7rzBxwNp64N3sKPaFg4hed1Z6W7GWvBIbV6PK
         g5VDkvcX6MtQv6BrIGyM0gEyGMaYsrMClnzQ3ukCKwQO+Vuy5wIMETNv6Bm1YtQw8f4W
         Gi3ABxYYTKWCpu0U54TqlqJcGRtS5ZsxDkxjyrzY/O6eVZzUzfdk53Xkx20abid8wZ5K
         isLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MxTE/+oxCefbdlHmbdDUrpFZur160jUZHoFCaid+s0I=;
        b=P4HWCKbkNYD1J0UXCKRwmzXGAfxr6i97Sn9xgigpM0QW0byt/JAdTFgVEW3kHf5xdN
         /KgF0I3UJQlXOXveoosaWhXkYbQlZA3OE751OorbATeovpWwoOy5MCq/YJCeb6ykE8MJ
         R0hs+BQW9Y7gXySOAbjHAcehtXOBKYx388h7tZe9A/O+uYuhiWGWsLPDod5gFueq2yUa
         MXHK0UHJo2ggJOugn2fIHgfMgvoqlUkSxJv85bCj7CepXsf8QScZ3fa9sUQqY/VHNqBi
         B/RZbZlHQohqAAfhRj/qPYzc10MkQLg5oEm7tzJ0kLZVMwoy+FOuUxPJ9Sa2rmL+NZZl
         /6pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y198si52515503qka.85.2019.08.08.09.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:20:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A8A0F88302;
	Thu,  8 Aug 2019 16:20:49 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 145EF60BAD;
	Thu,  8 Aug 2019 16:20:48 +0000 (UTC)
Date: Thu, 8 Aug 2019 12:20:47 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 20/24] xfs: use AIL pushing for inode reclaim IO
Message-ID: <20190808162047.GA24551@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-21-david@fromorbit.com>
 <20190807180915.GA20425@bfoster>
 <20190807231044.GR7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807231044.GR7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 08 Aug 2019 16:20:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 09:10:44AM +1000, Dave Chinner wrote:
> On Wed, Aug 07, 2019 at 02:09:15PM -0400, Brian Foster wrote:
> > On Thu, Aug 01, 2019 at 12:17:48PM +1000, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > Inode reclaim currently issues it's own inode IO when it comes
> > > across dirty inodes. This is used to throttle direct reclaim down to
> > > the rate at which we can reclaim dirty inodes. Failure to throttle
> > > in this manner results in the OOM killer being trivial to trigger
> > > even when there is lots of free memory available.
> > > 
> > > However, having direct reclaimers issue IO causes an amount of
> > > IO thrashing to occur. We can have up to the number of AGs in the
> > > filesystem concurrently issuing IO, plus the AIL pushing thread as
> > > well. This means we can many competing sources of IO and they all
> > > end up thrashing and competing for the request slots in the block
> > > device.
> > > 
> > > Similar to dirty page throttling and the BDI flusher thread, we can
> > > use the AIL pushing thread the sole place we issue inode writeback
> > > from and everything else waits for it to make progress. To do this,
> > > reclaim will skip over dirty inodes, but in doing so will record the
> > > lowest LSN of all the dirty inodes it skips. It will then push the
> > > AIL to this LSN and wait for it to complete that work.
> > > 
> > > In doing so, we block direct reclaim on the IO of at least one IO,
> > > thereby providing some level of throttling for when we encounter
> > > dirty inodes. However we gain the ability to scan and reclaim
> > > clean inodes in a non-blocking fashion. This allows us to
> > > remove all the per-ag reclaim locking that avoids excessive direct
> > > reclaim, as repeated concurrent direct reclaim will hit the same
> > > dirty inodes on block waiting on the same IO to complete.
> > > 
...
> > > -restart:
> > > -	error = 0;
> > >  	/*
> > >  	 * Don't try to flush the inode if another inode in this cluster has
> > >  	 * already flushed it after we did the initial checks in
> > >  	 * xfs_reclaim_inode_grab().
> > >  	 */
> > > -	if (sync_mode & SYNC_TRYLOCK) {
> > > -		if (!xfs_ilock_nowait(ip, XFS_ILOCK_EXCL))
> > > -			goto out;
> > > -		if (!xfs_iflock_nowait(ip))
> > > -			goto out_unlock;
> > > -	} else {
> > > -		xfs_ilock(ip, XFS_ILOCK_EXCL);
> > > -		if (!xfs_iflock_nowait(ip)) {
> > > -			if (!(sync_mode & SYNC_WAIT))
> > > -				goto out_unlock;
> > > -			xfs_iflock(ip);
> > > -		}
> > > -	}
> > > +	if (!xfs_ilock_nowait(ip, XFS_ILOCK_EXCL))
> > > +		goto out;
> > > +	if (!xfs_iflock_nowait(ip))
> > > +		goto out_unlock;
> > >  
> > 
> > Do we even need the flush lock here any more if we're never going to
> > flush from this context?
> 
> Ideally, no. But the inode my currently be being flushed, in which
> case the incore inode is clean, but we can't reclaim it yet. Hence
> we need the flush lock to serialise against IO completion.
> 

Ok, so xfs_inode_clean() checks ili_fields and that state is cleared at
flush time (under the flush lock). Hmm, so xfs_inode_clean() basically
determines whether the inode needs flushing or not, not necessarily
whether the in-core inode is clean with respect to the on-disk inode. I
wonder if we could enhance that or provide a new helper variant to cover
the latter as well, perhaps by also looking at ->ili_last_fields (with a
separate lock). Anyways, that's a matter for a separate patch..

> > The shutdown case just below notwithstanding
> > (which I'm also wondering if we should just drop given we abort from
> > xfs_iflush() on shutdown), the pin count is an atomic and the dirty
> > state changes under ilock.
> 
> The shutdown case has to handle pinned inodes, not just inodes being
> flushed.
> 
> > Maybe I'm missing something else, but the reason I ask is that the
> > increased flush lock contention in codepaths that don't actually flush
> > once it's acquired gives me a bit of concern that we could reduce
> > effectiveness of the one task that actually does (xfsaild).
> 
> The flush lock isn't a contended lock - it's actually a bit that is
> protected by the i_flags_lock, so if we are contending on anything
> it will be the flags lock. And, well, see the LRU isolate function
> conversion of this code, becuase it changes how the flags lock is
> used for reclaim but I haven't seen any contention as a result of
> that change....
> 

True, but I guess it's not so much the lock contention I'm concerned
about as opposed to the resulting impact of increased nonblocking
reclaim scanning on xfsaild. As of right now reclaim activity is highly
throttled and if a direct reclaimer does ultimatly acquire the flush
lock, it will perform the flush.

With reduced blocking/throttling and no reclaim flushing, I'm wondering
how possible it is for a bunch of direct reclaimers to come in and
effectively cycle over the same batch of dirty inodes repeatedly and
faster than xfsaild to the point where xfsaild can't make progress
actually flushing some of these inodes. Looking again, the combination
of the unlocked dirty check before grabbing the inode and sync AIL push
after each pass might be enough to prevent this from being a problem.
The former allows a direct reclaimer to skip the lock cycle if the inode
is obviously dirty and if the lock cycle was necessary to detect dirty
state, the associated task will wait for a while before coming around
again.

...
> > >  	while ((pag = xfs_perag_get_tag(mp, ag, XFS_ICI_RECLAIM_TAG))) {
> > >  		unsigned long	first_index = 0;
> > >  		int		done = 0;
> > >  		int		nr_found = 0;
> > >  
> > >  		ag = pag->pag_agno + 1;
> > > -
> > > -		if (trylock) {
> > > -			if (!mutex_trylock(&pag->pag_ici_reclaim_lock)) {
> > > -				skipped++;
> > > -				xfs_perag_put(pag);
> > > -				continue;
> > > -			}
> > > -			first_index = pag->pag_ici_reclaim_cursor;
> > > -		} else
> > > -			mutex_lock(&pag->pag_ici_reclaim_lock);
> > 
> > I understand that the eliminated blocking drops a dependency on the
> > perag reclaim exclusion as described by the commit log, but I'm not sure
> > it's enough to justify removing it entirely. For one, the reclaim cursor
> > management looks potentially racy.
> 
> We really don't care if the cursor updates are racy. All that will
> result in is some inode ranges being scanned twice in quick
> succession. All this does now is prevent reclaim from starting at
> the start of the AG every time it runs, so we end up with most
> reclaimers iterating over previously unscanned inodes.
> 

That might happen, sure, but a racing update may also cause a reclaimer
in progress to jump backwards and rescan a set of inodes it just
finished with (assuming some were dirty and left around). If that
happens once or twice it's probably not a big deal, but if you have a
bunch of reclaimer threads repeatedly stammering over the same ranges
over and over again, ISTM the whole thing could slow down to a crawl and
do quite a bit less real scanning work than request by the shrinker
core.

> > Also, doesn't this exclusion provide
> > some balance for reclaim across AGs? E.g., if a bunch of reclaim threads
> > come in at the same time, this allows them to walk across AGs instead of
> > potentially stumbling over eachother in the batching/grabbing code.
> 
> What they do now is leapfrog each other and work through the same
> AGs much faster. The overall pattern of reclaim doesn't actually
> change much, just the speed at which individual AGs are scanned.
> 
> But that was not what the locking was put in place for. THe locking
> was put in place to be able to throttle the number of concurrent
> reclaimers issuing IO. If the reclaimers leapfrogged like they do
> without the locking, then we end up with non-sequential inode
> writeback patterns, and writeback performance goes really bad,
> really quickly. Hence the locking is there to ensure we get
> sequential inode writeback patterns from each AG that is being
> reclaimed from. That can be optimised by block layer merging, and so
> even though we might have a lot of concurrent reclaimers, we get
> lots of large, well-formed IOs from each of them.
> 
> IOWs, the locking was all about preventing the IO patterns from
> breaking down under memory pressure, not about optimising how
> reclaimers interact with each other.
> 

I don't dispute any of that, but that doesn't necessarily mean that code
added since the locking was added doesn't depend on the serialization
that was already in place at the time to function sanely. I'm not asking
for performance/optimization here.

> > I see again that most of this code seems to ultimately go away, replaced
> > by an LRU mechanism so we no longer operate on a per-ag basis. I can see
> > how this becomes irrelevant with that mechanism, but I think it might
> > make more sense to drop this locking along with the broader mechanism in
> > the last patch or two of the series rather than doing it here.
> 
> Fundamentally, this patch is all about shifting the IO and blocking
> mechanisms to the AIL. This locking is no longer necessary, and it
> actually gets in the way of doing non-blocking reclaim and shifting
> the IO to the AIL. i.e. we block where we no longer need to, and
> that causes more problems for this change than it solves.
> 

I could see the issue of blocking where we no longer need to, but this
patch could also change the contextual blocking behavior without
necessarily removing the lock entirely. Or better yet, drop the trylock
and reduce the scope of the lock to the inode grabbing and cursor update
(and re-sample the cursor on each iteration). The cursor update index
doesn't change after we grab the last inode we're going to try and
reclaim, but we currently hold the lock across the entire batch reclaim.
Doing the lookup and grab under the lock and then releasing it once we
start to reclaim allows multiple threads to drive reclaim of the same AG
as you want, but prevents those tasks from disrupting eachother. We
still would have a blocking lock in this path, but it's purely
structural and we'd only block for what would otherwise be time spent
scanning over already handled inodes (i.e.  wasted CPU time). IOW, if
there's contention on the lock, then by definition some other task has
the same lookup index.

> > If
> > nothing else, that eliminates the need for the reviewer to consider this
> > transient "old mechanism + new locking" state as opposed to reasoning
> > about the old mechanism vs. new mechanism and why the old locking simply
> > no longer applies.
> 
> I think you're putting to much "make every step of the transition
> perfect" focus on this. We've got to drop this locking to make
> reclaim non-blocking, and we have to make reclaim non-blocking
> before we can move to a LRU mechanisms that relies on LRU removal
> being completely non-blocking and cannot issue IO. It's a waste of
> time trying to break this down further and further into "perfect"
> patches - it works well enough and without functional regressions so
> it does not create landmines for people doing bisects, and that's
> largely all that matters in the middle of a large patchset that is
> making large algorithm changes...
> 

I'm not really worried about maintaining perfection throughout every
step of this series. I just think this patch is a bit too fast and
loose.

In logistical terms, this patch and the next few continue to modify the
perag based reclaim mechanism, the second to last patch adds a new
reclaim mechanism to reclaim via the newly added LRU, and the final
patch removes the old/unused perag bits. The locking we're talking about
here is part of that old/unused mechanism that is ripped out in the
final patch, not common code shared between the two, so I don't see a
problem with either leaving it or changing it around as described above.
An untested patch (based on top of this one) for the latter is appended
for reference..

Brian

--- 8< ---

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 4c4c5bc12147..87f3ca86dfd1 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1210,12 +1210,14 @@ xfs_reclaim_inodes_ag(
 		int		nr_found = 0;
 
 		ag = pag->pag_agno + 1;
-		first_index = pag->pag_ici_reclaim_cursor;
 
 		do {
 			struct xfs_inode *batch[XFS_LOOKUP_BATCH];
 			int	i;
 
+			mutex_lock(&pag->pag_ici_reclaim_lock);
+			first_index = pag->pag_ici_reclaim_cursor;
+
 			rcu_read_lock();
 			nr_found = radix_tree_gang_lookup_tag(
 					&pag->pag_ici_root,
@@ -1225,6 +1227,7 @@ xfs_reclaim_inodes_ag(
 			if (!nr_found) {
 				done = 1;
 				rcu_read_unlock();
+				mutex_unlock(&pag->pag_ici_reclaim_lock);
 				break;
 			}
 
@@ -1266,6 +1269,11 @@ xfs_reclaim_inodes_ag(
 
 			/* unlock now we've grabbed the inodes. */
 			rcu_read_unlock();
+			if (!done)
+				pag->pag_ici_reclaim_cursor = first_index;
+			else
+				pag->pag_ici_reclaim_cursor = 0;
+			mutex_unlock(&pag->pag_ici_reclaim_lock);
 
 			for (i = 0; i < nr_found; i++) {
 				if (!batch[i])
@@ -1281,10 +1289,6 @@ xfs_reclaim_inodes_ag(
 
 		} while (nr_found && !done && nr_to_scan > 0);
 
-		if (!done)
-			pag->pag_ici_reclaim_cursor = first_index;
-		else
-			pag->pag_ici_reclaim_cursor = 0;
 		xfs_perag_put(pag);
 	}
 
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index bcf8f64d1b1f..a1805021c92f 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -148,6 +148,7 @@ xfs_free_perag(
 		ASSERT(atomic_read(&pag->pag_ref) == 0);
 		xfs_iunlink_destroy(pag);
 		xfs_buf_hash_destroy(pag);
+		mutex_destroy(&pag->pag_ici_reclaim_lock);
 		call_rcu(&pag->rcu_head, __xfs_free_perag);
 	}
 }
@@ -199,6 +200,7 @@ xfs_initialize_perag(
 		pag->pag_agno = index;
 		pag->pag_mount = mp;
 		spin_lock_init(&pag->pag_ici_lock);
+		mutex_init(&pag->pag_ici_reclaim_lock);
 		INIT_RADIX_TREE(&pag->pag_ici_root, GFP_ATOMIC);
 		if (xfs_buf_hash_init(pag))
 			goto out_free_pag;
@@ -240,6 +242,7 @@ xfs_initialize_perag(
 out_hash_destroy:
 	xfs_buf_hash_destroy(pag);
 out_free_pag:
+	mutex_destroy(&pag->pag_ici_reclaim_lock);
 	kmem_free(pag);
 out_unwind_new_pags:
 	/* unwind any prior newly initialized pags */
@@ -249,6 +252,7 @@ xfs_initialize_perag(
 			break;
 		xfs_buf_hash_destroy(pag);
 		xfs_iunlink_destroy(pag);
+		mutex_destroy(&pag->pag_ici_reclaim_lock);
 		kmem_free(pag);
 	}
 	return error;
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 3ed6d942240f..a585860eaa94 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -390,6 +390,7 @@ typedef struct xfs_perag {
 	spinlock_t	pag_ici_lock;	/* incore inode cache lock */
 	struct radix_tree_root pag_ici_root;	/* incore inode cache root */
 	int		pag_ici_reclaimable;	/* reclaimable inodes */
+	struct mutex	pag_ici_reclaim_lock;	/* serialisation point */
 	unsigned long	pag_ici_reclaim_cursor;	/* reclaim restart point */
 
 	/* buffer cache index */

