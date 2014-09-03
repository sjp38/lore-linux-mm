Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 09F476B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 21:02:23 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so9860336pdj.32
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 18:02:23 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id fe1si8117875pbb.201.2014.09.02.18.02.21
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 18:02:23 -0700 (PDT)
Date: Wed, 3 Sep 2014 11:02:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] fs/super.c: do not shrink fs slab during direct memory
 reclaim
Message-ID: <20140903010206.GB20473@dastard>
References: <54004E82.3060608@huawei.com>
 <20140901235102.GI26465@dastard>
 <540587DF.6040302@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <540587DF.6040302@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xue jiufei <xuejiufei@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>, Junxiao Bi <junxiao.bi@oracle.com>

On Tue, Sep 02, 2014 at 05:03:27PM +0800, Xue jiufei wrote:
> Hi, Dave
> On 2014/9/2 7:51, Dave Chinner wrote:
> > On Fri, Aug 29, 2014 at 05:57:22PM +0800, Xue jiufei wrote:
> >> The patch trys to solve one deadlock problem caused by cluster
> >> fs, like ocfs2. And the problem may happen at least in the below
> >> situations:
> >> 1)Receiving a connect message from other nodes, node queues a
> >> work_struct o2net_listen_work.
> >> 2)o2net_wq processes this work and calls sock_alloc() to allocate
> >> memory for a new socket.
> >> 3)It would do direct memory reclaim when available memory is not
> >> enough and trigger the inode cleanup. That inode being cleaned up
> >> is happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
> >> ->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
> >> and wait for the unlock response from master.
> >> 4)tcp layer received the response, call o2net_data_ready() and
> >> queue sc_rx_work, waiting o2net_wq to process this work.
> >> 5)o2net_wq is a single thread workqueue, it process the work one by
> >> one. Right now it is still doing o2net_listen_work and cannot handle
> >> sc_rx_work. so we deadlock.
> >>
> >> It is impossible to set GFP_NOFS for memory allocation in sock_alloc().
> >> So we use PF_FSTRANS to avoid the task reentering filesystem when
> >> available memory is not enough.
> >>
> >> Signed-off-by: joyce.xue <xuejiufei@huawei.com>
> > 
> > For the second time: use memalloc_noio_save/memalloc_noio_restore.
> > And please put a great big comment in the code explaining why you
> > need to do this special thing with memory reclaim flags.
> > 
> > Cheers,
> > 
> > Dave.
> > 
> Thanks for your reply. But I am afraid that memalloc_noio_save/
> memalloc_noio_restore can not solve my problem. __GFP_IO is cleared
> if PF_MEMALLOC_NOIO is set and can avoid doing IO in direct memory
> reclaim.

Well, yes. It sets a process flag that is used to avoid re-entrancy
issues in direct reclaim. Direct reclaim is more than just the
superblock shrinker - there are lots of other shrinkers, page
reclaim, etc and I bet there are other paths that can trigger the
deadlock you are seeing. We need to protect against all those
cases, not just the one shrinker you see a problem with. i.e. we
need to clear __GPF_FS from *all* reclaim, not just the superblock
shrinker.

Also, PF_FSTRANS is used internally by filesystems, not the
generic code.  If we start spreading it through generic code like
this, we start breaking filesystems that rely on it having a
specific, filesystem internal meaning.  So it's a NACK on that basis
as well.

> However, __GFP_FS is still set that can not avoid pruning
> dcache and icache in memory allocation, resulting in the deadlock I
> described.

You have a deadlock in direct reclaim, and we already have a
template for setting a process flag that is used to indirectly
control direct reclaim behaviour. If the current process flag
doesn't provide precisely the coverage, then use that implementation
as the template to do exactly what is needed for your case.

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
