Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B59BC6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 07:42:08 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so2226521pab.37
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 04:42:07 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id u2si6074910pdo.76.2014.08.28.04.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 04:42:03 -0700 (PDT)
Message-ID: <53FF1538.60809@huawei.com>
Date: Thu, 28 Aug 2014 19:40:40 +0800
From: Xue jiufei <xuejiufei@huawei.com>
Reply-To: <xuejiufei@huawei.com>
MIME-Version: 1.0
Subject: A deadlock when direct memory reclaim in network filesystem
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi all,
We found there may exist a deadlock during direct memory reclaim in
network filesystem.
Here's one example in ocfs2, maybe other network filesystems has
this problems too.

1)Receiving a connect message from other nodes, Node queued
o2net_listen_work.
2)o2net_wq processed this work and try to allocate memory for a
new socket.
3)Syetem has no more memory, it would do direct memory reclaim
and trigger the inode cleanup. That inode being cleaned up is
happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
and wait for the response.
4)tcp layer received the response, call o2net_data_ready() and
queue sc_rx_work, waiting o2net_wq to process this work.
5)o2net_wq is a single thread workqueue, it process the work one by
one. Right now is is still doing o2net_listen_work and cannot handle
sc_rx_work. so we deadlock.

To avoid deadlock like this, caller should perform a GFP_NOFS
allocation attempt(see the comments of shrink_dcache_memory and
shrink_icache_memory).
However, in the situation I described above, it is impossible to
add GFP_NOFS flag unless we modify the socket create interface.

To fix this deadlock, we would not like to shrink inode and dentry
slab during direct memory reclaim. Kswapd would do this job for us.
So we want to force add __GFP_FS when call
__alloc_pages_direct_reclaim() in __alloc_pages_slowpath().
Is that OK or any better advice?

Thanks,
Xuejiufei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
