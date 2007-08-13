Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7DBXffe566354
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 11:33:41 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7DBXf0x1962186
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 13:33:41 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7DBXfRj018810
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 13:33:41 +0200
Date: Mon, 13 Aug 2007 13:33:40 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] dm: Fix deadlock under high i/o load in raid1 setup.
Message-ID: <20070813113340.GB30198@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, dm-devel@redhat.com
Cc: Daniel Kobras <kobras@linux.de>, Alasdair G Kergon <agk@redhat.com>, Stefan Weinhuber <wein@de.ibm.com>, Stefan Bader <shbader@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

the patch below went into 2.6.18. Now my question is: why doesn't it check
if kmalloc(..., GFP_NOIO) returns with a NULL pointer?
Did I miss anything that guarentees that this will always succeed or is it
just a bug?

commit c06aad854fdb9da38fcc22dccfe9d72919453e43
Author: Daniel Kobras <kobras@linux.de>
Date:   Sun Aug 27 01:23:24 2006 -0700

    [PATCH] dm: Fix deadlock under high i/o load in raid1 setup.
    
    On an nForce4-equipped machine with two SATA disk in raid1 setup using dmraid,
    we experienced frequent deadlock of the system under high i/o load.  'cat
    /dev/zero > ~/zero' was the most reliable way to reproduce them: Randomly
    after a few GB, 'cp' would be left in 'D' state along with kjournald and
    kmirrord.  The functions cp and kjournald were blocked in did vary, but
    kmirrord's wchan always pointed to 'mempool_alloc()'.  We've seen this pattern
    on 2.6.15 and 2.6.17 kernels.  http://lkml.org/lkml/2005/4/20/142 indicates
    that this problem has been around even before.
    
    So much for the facts, here's my interpretation: mempool_alloc() first tries
    to atomically allocate the requested memory, or falls back to hand out
    preallocated chunks from the mempool.  If both fail, it puts the calling
    process (kmirrord in this case) on a private waitqueue until somebody refills
    the pool.  Where the only 'somebody' is kmirrord itself, so we have a
    deadlock.
    
    I worked around this problem by falling back to a (blocking) kmalloc when
    before kmirrord would have ended up on the waitqueue.  This defeats part of
    the benefits of using the mempool, but at least keeps the system running.  And
    it could be done with a two-line change.  Note that mempool_alloc() clears the
    GFP_NOIO flag internally, and only uses it to decide whether to wait or return
    an error if immediate allocation fails, so the attached patch doesn't change
    behaviour in the non-deadlocking case.  Path is against current git
    (2.6.18-rc4), but should apply to earlier versions as well.  I've tested on
    2.6.15, where this patch makes the difference between random lockup and a
    stable system.
    
    Signed-off-by: Daniel Kobras <kobras@linux.de>
    Acked-by: Alasdair G Kergon <agk@redhat.com>
    Cc: <stable@kernel.org>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/drivers/md/dm-raid1.c b/drivers/md/dm-raid1.c
index be48ced..c54de98 100644
--- a/drivers/md/dm-raid1.c
+++ b/drivers/md/dm-raid1.c
@@ -255,7 +255,9 @@ static struct region *__rh_alloc(struct region_hash *rh, region_t region)
 	struct region *reg, *nreg;
 
 	read_unlock(&rh->hash_lock);
-	nreg = mempool_alloc(rh->region_pool, GFP_NOIO);
+	nreg = mempool_alloc(rh->region_pool, GFP_ATOMIC);
+	if (unlikely(!nreg))
+		nreg = kmalloc(sizeof(struct region), GFP_NOIO);
 	nreg->state = rh->log->type->in_sync(rh->log, region, 1) ?
 		RH_CLEAN : RH_NOSYNC;
 	nreg->rh = rh;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
