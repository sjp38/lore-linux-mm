Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECD56B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 07:52:53 -0500 (EST)
Received: by pablf10 with SMTP id lf10so15054651pab.6
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 04:52:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id dd1si16240574pdb.227.2015.02.21.04.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Feb 2015 04:52:51 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150219102431.GA15569@phnom.home.cmpxchg.org>
	<20150219225217.GY12722@dastard>
	<201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
	<20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
In-Reply-To: <20150221032000.GC7922@thunk.org>
Message-Id: <201502212100.IBG78151.QLHSOMJFVOtFFO@I-love.SAKURA.ne.jp>
Date: Sat, 21 Feb 2015 21:00:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu
Cc: david@fromorbit.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

Theodore Ts'o wrote:
> So at this point, it seems we have two choices.  We can either revert
> 9879de7373fc, or I can add a whole lot more GFP_FAIL flags to ext4's
> memory allocations and submit them as stable bug fixes.

Can you absorb this side effect by simply adding GFP_NOFAIL to only
ext4's memory allocations? Don't you also depend on lower layers which
use GFP_NOIO?

BTW, while you are using open-coded GFP_NOFAIL retry loop for GFP_NOFS
allocation in jbd2, you are already using GFP_NOFAIL for GFP_NOFS
allocation in jbd. Failure check being there for GFP_NOFAIL seems
redundant.

---------- linux-3.19/fs/jbd2/transaction.c ----------
257 static int start_this_handle(journal_t *journal, handle_t *handle,
258                              gfp_t gfp_mask)
259 {
260         transaction_t   *transaction, *new_transaction = NULL;
261         int             blocks = handle->h_buffer_credits;
262         int             rsv_blocks = 0;
263         unsigned long ts = jiffies;
264 
265         /*
266          * 1/2 of transaction can be reserved so we can practically handle
267          * only 1/2 of maximum transaction size per operation
268          */
269         if (WARN_ON(blocks > journal->j_max_transaction_buffers / 2)) {
270                 printk(KERN_ERR "JBD2: %s wants too many credits (%d > %d)\n",
271                        current->comm, blocks,
272                        journal->j_max_transaction_buffers / 2);
273                 return -ENOSPC;
274         }
275 
276         if (handle->h_rsv_handle)
277                 rsv_blocks = handle->h_rsv_handle->h_buffer_credits;
278 
279 alloc_transaction:
280         if (!journal->j_running_transaction) {
281                 new_transaction = kmem_cache_zalloc(transaction_cache,
282                                                     gfp_mask);
283                 if (!new_transaction) {
284                         /*
285                          * If __GFP_FS is not present, then we may be
286                          * being called from inside the fs writeback
287                          * layer, so we MUST NOT fail.  Since
288                          * __GFP_NOFAIL is going away, we will arrange
289                          * to retry the allocation ourselves.
290                          */
291                         if ((gfp_mask & __GFP_FS) == 0) {
292                                 congestion_wait(BLK_RW_ASYNC, HZ/50);
293                                 goto alloc_transaction;
294                         }
295                         return -ENOMEM;
296                 }
297         }
298 
299         jbd_debug(3, "New handle %p going live.\n", handle);
---------- linux-3.19/fs/jbd2/transaction.c ----------

---------- linux-3.19/fs/jbd/transaction.c ----------
 84 static int start_this_handle(journal_t *journal, handle_t *handle)
 85 {
 86         transaction_t *transaction;
 87         int needed;
 88         int nblocks = handle->h_buffer_credits;
 89         transaction_t *new_transaction = NULL;
 90         int ret = 0;
 91 
 92         if (nblocks > journal->j_max_transaction_buffers) {
 93                 printk(KERN_ERR "JBD: %s wants too many credits (%d > %d)\n",
 94                        current->comm, nblocks,
 95                        journal->j_max_transaction_buffers);
 96                 ret = -ENOSPC;
 97                 goto out;
 98         }
 99 
100 alloc_transaction:
101         if (!journal->j_running_transaction) {
102                 new_transaction = kzalloc(sizeof(*new_transaction),
103                                                 GFP_NOFS|__GFP_NOFAIL);
104                 if (!new_transaction) {
105                         ret = -ENOMEM;
106                         goto out;
107                 }
108         }
109 
110         jbd_debug(3, "New handle %p going live.\n", handle);
---------- linux-3.19/fs/jbd/transaction.c ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
