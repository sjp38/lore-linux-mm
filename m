Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 322E76B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 09:12:02 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so2528672pab.29
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 06:12:01 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id qf4si115236pbb.163.2014.08.28.06.11.59
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 06:12:00 -0700 (PDT)
Date: Thu, 28 Aug 2014 23:11:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: A deadlock when direct memory reclaim in network filesystem
Message-ID: <20140828131139.GE26465@dastard>
References: <53FF1538.60809@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53FF1538.60809@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xue jiufei <xuejiufei@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 28, 2014 at 07:40:40PM +0800, Xue jiufei wrote:
> Hi all,
> We found there may exist a deadlock during direct memory reclaim in
> network filesystem.
> Here's one example in ocfs2, maybe other network filesystems has
> this problems too.
> 
> 1)Receiving a connect message from other nodes, Node queued
> o2net_listen_work.
> 2)o2net_wq processed this work and try to allocate memory for a
> new socket.
> 3)Syetem has no more memory, it would do direct memory reclaim
> and trigger the inode cleanup. That inode being cleaned up is
> happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
> ->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
> and wait for the response.
> 4)tcp layer received the response, call o2net_data_ready() and
> queue sc_rx_work, waiting o2net_wq to process this work.
> 5)o2net_wq is a single thread workqueue, it process the work one by
> one. Right now is is still doing o2net_listen_work and cannot handle
> sc_rx_work. so we deadlock.
> 
> To avoid deadlock like this, caller should perform a GFP_NOFS
> allocation attempt(see the comments of shrink_dcache_memory and
> shrink_icache_memory).
> However, in the situation I described above, it is impossible to
> add GFP_NOFS flag unless we modify the socket create interface.
> 
> To fix this deadlock, we would not like to shrink inode and dentry
> slab during direct memory reclaim. Kswapd would do this job for us.
> So we want to force add __GFP_FS when call
> __alloc_pages_direct_reclaim() in __alloc_pages_slowpath().
> Is that OK or any better advice?

memalloc_noio_save/memalloc_noio_restore

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
