Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9317B6B0036
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 06:02:12 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id a1so1520050wgh.27
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:02:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mz11si10076963wic.29.2014.02.26.03.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 03:02:10 -0800 (PST)
Date: Wed, 26 Feb 2014 12:02:09 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [mmotm:master 64/350] fs/ocfs2/dlmglue.c:3184
 ocfs2_mark_lockres_freeing() error: double lock 'irqsave:flags'
Message-ID: <20140226110209.GB6989@quack.suse.cz>
References: <20140226104835.GY26776@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226104835.GY26776@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kbuild@01.org, Jan Kara <jack@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>

  Hi,

On Wed 26-02-14 13:48:35, Dan Carpenter wrote:
> [ False positive, this is not a bug, it's just that the second IRQ save
>   is unnecessary ].
> FYI, there are new smatch warnings show up in
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a6a1126d3535f0bd8d7c56810061541a4f5595af
> commit: c8acdd9e9cf2dd5a5f62034dfaf93c721b3f405d [64/350] ocfs2: avoid blocking in ocfs2_mark_lockres_freeing() in downconvert thread
> 
> fs/ocfs2/dlmglue.c:3184 ocfs2_mark_lockres_freeing() error: double lock 'irqsave:flags'
> fs/ocfs2/dlmglue.c:3204 ocfs2_mark_lockres_freeing() error: double unlock 'irqsave:flags'
  Yeah. I actually have an updated version of a patch which doesn't have
these two nested irqsafe calls. I'll send it to Andrew. Thanks for letting
me know.

									Honza


> git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
> git remote update mmotm
> git checkout c8acdd9e9cf2dd5a5f62034dfaf93c721b3f405d
> vim +3184 fs/ocfs2/dlmglue.c
> 
> c8acdd9e Jan Kara    2014-02-25  3178  		 *             ocfs2_clear_inode()
> c8acdd9e Jan Kara    2014-02-25  3179  		 *               ocfs2_mark_lockres_freeing()
> c8acdd9e Jan Kara    2014-02-25  3180  		 *                 ... blocks waiting for OCFS2_LOCK_QUEUED
> c8acdd9e Jan Kara    2014-02-25  3181  		 *                 since we are the downconvert thread which
> c8acdd9e Jan Kara    2014-02-25  3182  		 *                 should clear the flag.
> c8acdd9e Jan Kara    2014-02-25  3183  		 */
> c8acdd9e Jan Kara    2014-02-25 @3184  		spin_lock_irqsave(&osb->dc_task_lock, flags);
> c8acdd9e Jan Kara    2014-02-25  3185  		list_del_init(&lockres->l_blocked_list);
> c8acdd9e Jan Kara    2014-02-25  3186  		osb->blocked_lock_count--;
> c8acdd9e Jan Kara    2014-02-25  3187  		spin_unlock_irqrestore(&osb->dc_task_lock, flags);
> c8acdd9e Jan Kara    2014-02-25  3188  		lockres_clear_flags(lockres, OCFS2_LOCK_QUEUED);
> c8acdd9e Jan Kara    2014-02-25  3189  		goto out_unlock;
> c8acdd9e Jan Kara    2014-02-25  3190  	}
> ccd979bd Mark Fasheh 2005-12-15  3191  	while (lockres->l_flags & OCFS2_LOCK_QUEUED) {
> ccd979bd Mark Fasheh 2005-12-15  3192  		lockres_add_mask_waiter(lockres, &mw, OCFS2_LOCK_QUEUED, 0);
> ccd979bd Mark Fasheh 2005-12-15  3193  		spin_unlock_irqrestore(&lockres->l_lock, flags);
> ccd979bd Mark Fasheh 2005-12-15  3194  
> ccd979bd Mark Fasheh 2005-12-15  3195  		mlog(0, "Waiting on lockres %s\n", lockres->l_name);
> ccd979bd Mark Fasheh 2005-12-15  3196  
> ccd979bd Mark Fasheh 2005-12-15  3197  		status = ocfs2_wait_for_mask(&mw);
> ccd979bd Mark Fasheh 2005-12-15  3198  		if (status)
> ccd979bd Mark Fasheh 2005-12-15  3199  			mlog_errno(status);
> ccd979bd Mark Fasheh 2005-12-15  3200  
> ccd979bd Mark Fasheh 2005-12-15  3201  		spin_lock_irqsave(&lockres->l_lock, flags);
> ccd979bd Mark Fasheh 2005-12-15  3202  	}
> c8acdd9e Jan Kara    2014-02-25  3203  out_unlock:
> ccd979bd Mark Fasheh 2005-12-15 @3204  	spin_unlock_irqrestore(&lockres->l_lock, flags);
> ccd979bd Mark Fasheh 2005-12-15  3205  }
> ccd979bd Mark Fasheh 2005-12-15  3206  
> d680efe9 Mark Fasheh 2006-09-08  3207  void ocfs2_simple_drop_lockres(struct ocfs2_super *osb,
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
