Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6B36B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 19:51:33 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id z10so7088604pdj.38
        for <linux-mm@kvack.org>; Mon, 01 Sep 2014 16:51:32 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id yr5si3123121pbc.161.2014.09.01.16.51.30
        for <linux-mm@kvack.org>;
        Mon, 01 Sep 2014 16:51:32 -0700 (PDT)
Date: Tue, 2 Sep 2014 09:51:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] fs/super.c: do not shrink fs slab during direct memory
 reclaim
Message-ID: <20140901235102.GI26465@dastard>
References: <54004E82.3060608@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54004E82.3060608@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xue jiufei <xuejiufei@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>, Junxiao Bi <junxiao.bi@oracle.com>

On Fri, Aug 29, 2014 at 05:57:22PM +0800, Xue jiufei wrote:
> The patch trys to solve one deadlock problem caused by cluster
> fs, like ocfs2. And the problem may happen at least in the below
> situations:
> 1)Receiving a connect message from other nodes, node queues a
> work_struct o2net_listen_work.
> 2)o2net_wq processes this work and calls sock_alloc() to allocate
> memory for a new socket.
> 3)It would do direct memory reclaim when available memory is not
> enough and trigger the inode cleanup. That inode being cleaned up
> is happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
> ->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
> and wait for the unlock response from master.
> 4)tcp layer received the response, call o2net_data_ready() and
> queue sc_rx_work, waiting o2net_wq to process this work.
> 5)o2net_wq is a single thread workqueue, it process the work one by
> one. Right now it is still doing o2net_listen_work and cannot handle
> sc_rx_work. so we deadlock.
> 
> It is impossible to set GFP_NOFS for memory allocation in sock_alloc().
> So we use PF_FSTRANS to avoid the task reentering filesystem when
> available memory is not enough.
> 
> Signed-off-by: joyce.xue <xuejiufei@huawei.com>

For the second time: use memalloc_noio_save/memalloc_noio_restore.
And please put a great big comment in the code explaining why you
need to do this special thing with memory reclaim flags.

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
