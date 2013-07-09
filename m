Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id CAC1B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 17:39:36 -0400 (EDT)
Date: Tue, 9 Jul 2013 14:39:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-Id: <20130709143934.fcd643cc21405ec7b04900f3@linux-foundation.org>
In-Reply-To: <20130709175749.GA31848@dhcp22.suse.cz>
References: <20130701012558.GB27780@dastard>
	<20130701075005.GA28765@dhcp22.suse.cz>
	<20130701081056.GA4072@dastard>
	<20130702092200.GB16815@dhcp22.suse.cz>
	<20130702121947.GE14996@dastard>
	<20130702124427.GG16815@dhcp22.suse.cz>
	<20130703112403.GP14996@dastard>
	<20130704163643.GF7833@dhcp22.suse.cz>
	<20130708125352.GC20149@dhcp22.suse.cz>
	<20130709173242.GA9098@localhost.localdomain>
	<20130709175749.GA31848@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 9 Jul 2013 19:57:49 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-07-13 21:32:51, Glauber Costa wrote:
> [...]
> > You seem to have switched to XFS.
> 
> Yes, to make sure that the original hang is not fs specific. I can
> switch to other fs if it helps. This seems to be really hard to
> reproduce now so I would rather not change things if possible.
> 
> > Dave posted a patch two days ago fixing some missing conversions in
> > the XFS side. AFAIK, Andrew hasn't yet picked the patch.
> 
> Could you point me to those patches, please?

This one:

From: Dave Chinner <david@fromorbit.com>
Subject: xfs: fix dquot isolation hang

The new LRU list isolation code in xfs_qm_dquot_isolate() isn't
completely up to date.  Firstly, it needs conversion to return enum
lru_status values, not raw numbers. Secondly - most importantly - it
fails to unlock the dquot and relock the LRU in the LRU_RETRY path.
This leads to deadlocks in xfstests generic/232. Fix them.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/xfs/xfs_qm.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff -puN fs/xfs/xfs_qm.c~xfs-convert-dquot-cache-lru-to-list_lru-fix-dquot-isolation-hang fs/xfs/xfs_qm.c
--- a/fs/xfs/xfs_qm.c~xfs-convert-dquot-cache-lru-to-list_lru-fix-dquot-isolation-hang
+++ a/fs/xfs/xfs_qm.c
@@ -659,7 +659,7 @@ xfs_qm_dquot_isolate(
 		trace_xfs_dqreclaim_want(dqp);
 		list_del_init(&dqp->q_lru);
 		XFS_STATS_DEC(xs_qm_dquot_unused);
-		return 0;
+		return LRU_REMOVED;
 	}
 
 	/*
@@ -705,17 +705,19 @@ xfs_qm_dquot_isolate(
 	XFS_STATS_DEC(xs_qm_dquot_unused);
 	trace_xfs_dqreclaim_done(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaims);
-	return 0;
+	return LRU_REMOVED;
 
 out_miss_busy:
 	trace_xfs_dqreclaim_busy(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaim_misses);
-	return 2;
+	return LRU_SKIP;
 
 out_unlock_dirty:
 	trace_xfs_dqreclaim_busy(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaim_misses);
-	return 3;
+	xfs_dqunlock(dqp);
+	spin_lock(lru_lock);
+	return LRU_RETRY;
 }
 
 static unsigned long
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
