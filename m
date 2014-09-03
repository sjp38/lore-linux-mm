Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDBB6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 23:10:41 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so10053877pdi.15
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 20:10:40 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id bx4si8534357pab.174.2014.09.02.20.10.38
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 20:10:40 -0700 (PDT)
Date: Wed, 3 Sep 2014 13:10:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] fs/super.c: do not shrink fs slab during direct memory
 reclaim
Message-ID: <20140903031023.GC20473@dastard>
References: <54004E82.3060608@huawei.com>
 <20140901235102.GI26465@dastard>
 <540587DF.6040302@huawei.com>
 <54067117.4060201@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54067117.4060201@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: xuejiufei@huawei.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>

On Wed, Sep 03, 2014 at 09:38:31AM +0800, Junxiao Bi wrote:
> Hi Jiufei,
> 
> On 09/02/2014 05:03 PM, Xue jiufei wrote:
> > Hi, Dave
> > On 2014/9/2 7:51, Dave Chinner wrote:
> >> On Fri, Aug 29, 2014 at 05:57:22PM +0800, Xue jiufei wrote:
> >>> The patch trys to solve one deadlock problem caused by cluster
> >>> fs, like ocfs2. And the problem may happen at least in the below
> >>> situations:
> >>> 1)Receiving a connect message from other nodes, node queues a
> >>> work_struct o2net_listen_work.
> >>> 2)o2net_wq processes this work and calls sock_alloc() to allocate
> >>> memory for a new socket.
> >>> 3)It would do direct memory reclaim when available memory is not
> >>> enough and trigger the inode cleanup. That inode being cleaned up
> >>> is happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
> >>> ->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
> >>> and wait for the unlock response from master.
> >>> 4)tcp layer received the response, call o2net_data_ready() and
> >>> queue sc_rx_work, waiting o2net_wq to process this work.
> >>> 5)o2net_wq is a single thread workqueue, it process the work one by
> >>> one. Right now it is still doing o2net_listen_work and cannot handle
> >>> sc_rx_work. so we deadlock.
> >>>
> >>> It is impossible to set GFP_NOFS for memory allocation in sock_alloc().
> >>> So we use PF_FSTRANS to avoid the task reentering filesystem when
> >>> available memory is not enough.
> >>>
> >>> Signed-off-by: joyce.xue <xuejiufei@huawei.com>
> >>
> >> For the second time: use memalloc_noio_save/memalloc_noio_restore.
> >> And please put a great big comment in the code explaining why you
> >> need to do this special thing with memory reclaim flags.
> >>
> >> Cheers,
> >>
> >> Dave.
> >>
> > Thanks for your reply. But I am afraid that memalloc_noio_save/
> > memalloc_noio_restore can not solve my problem. __GFP_IO is cleared
> > if PF_MEMALLOC_NOIO is set and can avoid doing IO in direct memory
> > reclaim. However, __GFP_FS is still set that can not avoid pruning
> > dcache and icache in memory allocation, resulting in the deadlock I
> > described.
> 
> You can use PF_MEMALLOC_NOIO to replace PF_FSTRANS, set this flag in
> ocfs2 and check it in sb shrinker.

No changes to the superblock shrinker, please. The flag should
modify the gfp_mask in the struct shrink_control passed to the
shrinker, just like the noio flag is used in the rest of the mm
code.

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
