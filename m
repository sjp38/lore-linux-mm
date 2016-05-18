Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 306FD6B0261
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:20:14 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 190so88099409iow.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:20:14 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id f199si2171747ioe.128.2016.05.18.00.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 00:20:13 -0700 (PDT)
Date: Wed, 18 May 2016 09:20:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160518072005.GA3193@twins.programming.kicks-ass.net>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517223549.GV26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> > 
> > Thanks for writing all that down Dave!
> > 
> > On Tue, May 17, 2016 at 09:10:56AM +1000, Dave Chinner wrote:
> > 
> > > The reason we don't have lock clases for the ilock is that we aren't
> > > supposed to call memory reclaim with that lock held in exclusive
> > > mode. This is because reclaim can run transactions, and that may
> > > need to flush dirty inodes to make progress. Flushing dirty inode
> > > requires taking the ilock in shared mode.
> > > 
> > > In the code path that was reported, we hold the ilock in /shared/
> > > mode with no transaction context (we are doing a read-only
> > > operation). This means we can run transactions in memory reclaim
> > > because a) we can't deadlock on the inode we hold locks on, and b)
> > > transaction reservations will be able to make progress as we don't
> > > hold any locks it can block on.
> > 
> > Just to clarify; I read the above as that we cannot block on recursive
> > shared locks, is this correct?
> > 
> > Because we can in fact block on down_read()+down_read() just fine, so if
> > you're assuming that, then something's busted.
> 
> The transaction reservation path will run down_read_trylock() on the
> inode, not down_read(). Hence if there are no pending writers, it
> will happily take the lock twice and make progress, otherwise it
> will skip the inode and there's no deadlock.  If there's a pending
> writer, then we have another context that is already in a
> transaction context and has already pushed the item, hence it is
> only in the scope of the current push because IO hasn't completed
> yet and removed it from the list.
> 
> > Otherwise, I'm not quite reading it right, which is, given the
> > complexity of that stuff, entirely possible.
> 
> There's a maze of dark, grue-filled twisty passages here...

I'm sure. Thanks for the extra detail; yes the down_read_trylock() thing
will work.

> > In any case; would something like this work for you? Its entirely
> > untested, but the idea is to mark an entire class to skip reclaim
> > validation, instead of marking individual sites.
> 
> Probably would, but it seems like swatting a fly with runaway
> train. I'd much prefer a per-site annotation (e.g. as a GFP_ flag)
> so that we don't turn off something that will tell us we've made a
> mistake while developing new code...

Fair enough; if the mm folks don't object to 'wasting' a GFP flag on
this the below ought to do I think.

---
 include/linux/gfp.h      | 9 ++++++++-
 kernel/locking/lockdep.c | 3 +++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..7b5b9db4c821 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -41,6 +41,7 @@ struct vm_area_struct;
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
 #define ___GFP_KSWAPD_RECLAIM	0x2000000u
+#define ___GFP_NOVALIDATE	0x4000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -146,6 +147,11 @@ struct vm_area_struct;
  *   return NULL when direct reclaim and memory compaction have failed to allow
  *   the allocation to succeed.  The OOM killer is not called with the current
  *   implementation.
+ *
+ * __GFP_NOVALIDATE: lockdep annotation; do not use this allocation to set
+ *   LOCK_USED_IN_RECLAIM_FS and thereby avoid possible false positives.
+ *   Use of this flag should have a comment explaining the false positive
+ *   in detail.
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
@@ -155,6 +161,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
+#define __GFP_NOVALIDATE ((__force gfp_t)___GFP_NOVALIDATE)
 
 /*
  * Action modifiers
@@ -188,7 +195,7 @@ struct vm_area_struct;
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE)
 
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT 26
+#define __GFP_BITS_SHIFT 27
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /*
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 81f1a7107c0e..88bf43c3bf76 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2853,6 +2853,9 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
 	if (unlikely(!debug_locks))
 		return;
 
+	if (gfp_mask & __GFP_NOVALIDATE)
+		return;
+
 	/* no reclaim without waiting on it */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
