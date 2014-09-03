Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F1D246B003A
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 21:54:37 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so16052281pab.23
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 18:54:37 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id pd4si8335163pdb.173.2014.09.02.18.54.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 18:54:37 -0700 (PDT)
Message-ID: <54067486.2000105@huawei.com>
Date: Wed, 3 Sep 2014 09:53:10 +0800
From: Xue jiufei <xuejiufei@huawei.com>
Reply-To: <xuejiufei@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fs/super.c: do not shrink fs slab during direct memory
 reclaim
References: <54004E82.3060608@huawei.com> <20140901235102.GI26465@dastard> <540587DF.6040302@huawei.com> <20140903010206.GB20473@dastard>
In-Reply-To: <20140903010206.GB20473@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>, Junxiao Bi <junxiao.bi@oracle.com>

Hi, Dave
On 2014/9/3 9:02, Dave Chinner wrote:
> On Tue, Sep 02, 2014 at 05:03:27PM +0800, Xue jiufei wrote:
>> Hi, Dave
>> On 2014/9/2 7:51, Dave Chinner wrote:
>>> On Fri, Aug 29, 2014 at 05:57:22PM +0800, Xue jiufei wrote:
>>>> The patch trys to solve one deadlock problem caused by cluster
>>>> fs, like ocfs2. And the problem may happen at least in the below
>>>> situations:
>>>> 1)Receiving a connect message from other nodes, node queues a
>>>> work_struct o2net_listen_work.
>>>> 2)o2net_wq processes this work and calls sock_alloc() to allocate
>>>> memory for a new socket.
>>>> 3)It would do direct memory reclaim when available memory is not
>>>> enough and trigger the inode cleanup. That inode being cleaned up
>>>> is happened to be ocfs2 inode, so call evict()->ocfs2_evict_inode()
>>>> ->ocfs2_drop_lock()->dlmunlock()->o2net_send_message_vec(),
>>>> and wait for the unlock response from master.
>>>> 4)tcp layer received the response, call o2net_data_ready() and
>>>> queue sc_rx_work, waiting o2net_wq to process this work.
>>>> 5)o2net_wq is a single thread workqueue, it process the work one by
>>>> one. Right now it is still doing o2net_listen_work and cannot handle
>>>> sc_rx_work. so we deadlock.
>>>>
>>>> It is impossible to set GFP_NOFS for memory allocation in sock_alloc().
>>>> So we use PF_FSTRANS to avoid the task reentering filesystem when
>>>> available memory is not enough.
>>>>
>>>> Signed-off-by: joyce.xue <xuejiufei@huawei.com>
>>>
>>> For the second time: use memalloc_noio_save/memalloc_noio_restore.
>>> And please put a great big comment in the code explaining why you
>>> need to do this special thing with memory reclaim flags.
>>>
>>> Cheers,
>>>
>>> Dave.
>>>
>> Thanks for your reply. But I am afraid that memalloc_noio_save/
>> memalloc_noio_restore can not solve my problem. __GFP_IO is cleared
>> if PF_MEMALLOC_NOIO is set and can avoid doing IO in direct memory
>> reclaim.
> 
> Well, yes. It sets a process flag that is used to avoid re-entrancy
> issues in direct reclaim. Direct reclaim is more than just the
> superblock shrinker - there are lots of other shrinkers, page
> reclaim, etc and I bet there are other paths that can trigger the
> deadlock you are seeing. We need to protect against all those
> cases, not just the one shrinker you see a problem with. i.e. we
> need to clear __GPF_FS from *all* reclaim, not just the superblock
> shrinker.
> 
> Also, PF_FSTRANS is used internally by filesystems, not the
> generic code.  If we start spreading it through generic code like
> this, we start breaking filesystems that rely on it having a
> specific, filesystem internal meaning.  So it's a NACK on that basis
> as well.
> 
>> However, __GFP_FS is still set that can not avoid pruning
>> dcache and icache in memory allocation, resulting in the deadlock I
>> described.
> 
> You have a deadlock in direct reclaim, and we already have a
> template for setting a process flag that is used to indirectly
> control direct reclaim behaviour. If the current process flag
> doesn't provide precisely the coverage, then use that implementation
> as the template to do exactly what is needed for your case.
> 
> Cheers,
> 
> Dave.
> 
Thanks very much for your advise. I will send another patch later.

Thanks,
Xuejiufei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
