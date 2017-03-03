Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19F9E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 12:29:07 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n141so24542488qke.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 09:29:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n13si85607qkn.204.2017.03.03.09.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 09:29:06 -0800 (PST)
Date: Fri, 3 Mar 2017 12:29:04 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170303172904.GE21245@bfoster.bfoster>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303153720.GC21245@bfoster.bfoster>
 <20170303155258.GJ31499@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303155258.GJ31499@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 03, 2017 at 04:52:58PM +0100, Michal Hocko wrote:
> On Fri 03-03-17 10:37:21, Brian Foster wrote:
> [...]
> > That aside, looking through some of the traces in this case...
> > 
> > - kswapd0 is waiting on an inode flush lock. This means somebody else
> >   flushed the inode and it won't be unlocked until the underlying buffer
> >   I/O is completed. This context is also holding pag_ici_reclaim_lock
> >   which is what probably blocks other contexts from getting into inode
> >   reclaim.
> > - xfsaild is in xfs_iflush(), which means it has the inode flush lock.
> >   It's waiting on reading the underlying inode buffer. The buffer read
> >   sets b_ioend_wq to the xfs-buf wq, which is ultimately going to be
> >   queued in xfs_buf_bio_end_io()->xfs_buf_ioend_async(). The associated
> >   work item is what eventually triggers the I/O completion in
> >   xfs_buf_ioend().
> > 
> > So at this point reclaim is waiting on a read I/O completion. It's not
> > clear to me whether the read had completed and the work item was queued
> > or not. I do see the following in the workqueue lockup BUG output:
> > 
> > [  273.412600] workqueue xfs-buf/sda1: flags=0xc
> > [  273.414486]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
> > [  273.416415]     pending: xfs_buf_ioend_work [xfs]
> > 
> > ... which suggests that it was queued..? I suppose this could be one of
> > the workqueues waiting on a kthread, but xfs-buf also has a rescuer that
> > appears to be idle:
> > 
> > [ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
> > [ 1041.556813] Call Trace:
> > [ 1041.557796]  __schedule+0x336/0xe00
> > [ 1041.558983]  schedule+0x3d/0x90
> > [ 1041.560085]  rescuer_thread+0x322/0x3d0
> > [ 1041.561333]  kthread+0x10f/0x150
> > [ 1041.562464]  ? worker_thread+0x4b0/0x4b0
> > [ 1041.563732]  ? kthread_create_on_node+0x70/0x70
> > [ 1041.565123]  ret_from_fork+0x31/0x40
> > 
> > So shouldn't that thread pick up the work item if that is the case?
> 
> Is it possible that the progress is done but tediously slow? Keep in
> mind that the test case is doing write from 1k processes while one
> process basically consumes all the memory. So I wouldn't be surprised
> if this just made system to crawl on any attempt to do an IO.

That would seem like a possibility to me.. either waiting on an actual
I/O (no guarantee that the pending xfs-buf item is the one we care about
I suppose) completion or waiting for whatever needs to happen for the wq
infrastructure to kick off the rescuer. Though I think that's probably
something Tetsuo would ultimately have to confirm on his setup..

Brian

> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
