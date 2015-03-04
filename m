Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBC06B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 06:03:40 -0500 (EST)
Received: by pabli10 with SMTP id li10so32602384pab.13
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 03:03:40 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id ay5si3731094pbb.176.2015.03.04.03.03.38
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 03:03:39 -0800 (PST)
Date: Wed, 4 Mar 2015 22:03:34 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304110334.GS18360@dastard>
References: <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
 <20150302223154.GJ18360@dastard>
 <54F57B20.3090803@suse.cz>
 <20150304013346.GP18360@dastard>
 <54F6C772.3050806@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F6C772.3050806@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Mar 04, 2015 at 09:50:58AM +0100, Vlastimil Babka wrote:
> On 03/04/2015 02:33 AM, Dave Chinner wrote:
> >On Tue, Mar 03, 2015 at 10:13:04AM +0100, Vlastimil Babka wrote:
> >>>
> >>>Preallocated reserves do not allow for unbound demand paging of
> >>>reclaimable objects within reserved allocation contexts.
> >>
> >>OK I think I get the point now.
> >>
> >>So, lots of the concerns by me and others were about the wasted memory due to
> >>reservations, and increased pressure on the rest of the system. I was thinking,
> >>are you able, at the beginning of the transaction (for this purposes, I think of
> >>transaction as the work that starts with the memory reservation, then it cannot
> >>rollback and relies on the reserves, until it commits and frees the memory),
> >>determine whether the transaction cannot be blocked in its progress by any other
> >>transaction, and the only thing that would block it would be inability to
> >>allocate memory during its course?
> >
> >No. e.g. any transaction that requires allocation or freeing of an
> >inode or extent can get stuck behind any other transaction that is
> >allocating/freeing and inode/extent. And this will happen when
> >holding inode locks, which means other transactions on that inode
> >will then get stuck on the inode lock, and so on. Blocking
> >dependencies within transactions are everywhere and cannot be
> >avoided.
> 
> Hm, I see. I thought that perhaps to avoid deadlocks between
> transactions (which you already have to do somehow),

Of course, by following lock ordering rules, rules about holding
locks over transaction reservations, allowing bulk reservations for
rolling transactions that don't unlock objects between transaction
commits, having allocation group ordering rules, block allocation
ordering rules, transactional lock recursion suport to prevent
transaction deadlocking walking over objects already locked into the
transaction, etc.

By following those rules, we guarantee forwards progress in the
transaction subsystem. If we can also guarantee forwards progress in
memory allocation inside transaction context (like Irix did all
those years ago :P), then we can guarantee that transactions will
always complete unless there is a bug or corruption is detected
during an operation...

> either the
> dependencies have to be structured in a way that there's always some
> transaction that can't block on others. Or you have a way to detect
> potential deadlocks before they happen, and stall somebody who tries
> to lock.

$ git grep ASSERT fs/xfs |wc -l
1716

About 3% of the code in XFS is ASSERT statements used to verify
context specific state is correct in CONFIG_XFS_DEBUG=y builds.

FYI, from cloc:

Subsystem      files          blank        comment	   code
-------------------------------------------------------------------------------
fs/xfs		157          10841          25339          69140
mm/		 97          13923          25534          67870
fs/btrfs	 86          14443          15097          85065

Cheers,

Dave.

PS: XFS userspace has another 110,000 lines of code in xfsprogs and
60,000 lines of code in xfsdump, and there's also 80,000 lines of
test code in xfstests.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
