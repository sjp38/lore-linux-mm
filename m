Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8696B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 10:37:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so40695973wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 07:37:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si15313317wra.75.2017.03.03.07.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 07:37:55 -0800 (PST)
Date: Fri, 3 Mar 2017 10:37:21 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170303153720.GC21245@bfoster.bfoster>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303133950.GD31582@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 03, 2017 at 02:39:51PM +0100, Michal Hocko wrote:
> On Fri 03-03-17 19:48:30, Tetsuo Handa wrote:
> > Continued from http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp :
> > 
> > While I was testing a patch which avoids infinite too_many_isolated() loop in
> > shrink_inactive_list(), I hit a lockup where WQ_MEM_RECLAIM threads got stuck
> > waiting for memory allocation. I guess that we overlooked a basic thing about
> > WQ_MEM_RECLAIM.
> > 
> >   WQ_MEM_RECLAIM helps only when the cause of failing to complete
> >   a work item is lack of "struct task_struct" to run that work item, for
> >   WQ_MEM_RECLAIM preallocates one "struct task_struct" so that the workqueue
> >   will not be blocked waiting for memory allocation for "struct task_struct".
> > 
> >   WQ_MEM_RECLAIM does not help when "struct task_struct" running that work
> >   item is blocked waiting for memory allocation (or is indirectly blocked
> >   on a lock where the owner of that lock is blocked waiting for memory
> >   allocation). That is, WQ_MEM_RECLAIM users must guarantee forward progress
> >   if memory allocation (including indirect memory allocation via
> >   locks/completions) is needed.
> > 
> > In XFS, "xfs_mru_cache", "xfs-buf/%s", "xfs-data/%s", "xfs-conv/%s", "xfs-cil/%s",
> > "xfs-reclaim/%s", "xfs-log/%s", "xfs-eofblocks/%s", "xfsalloc" and "xfsdiscard"
> > workqueues are used, and all but "xfsdiscard" are WQ_MEM_RECLAIM workqueues.
> > 
> > What I observed is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
> > I guess that the key of this lockup is that xfs-data/sda1 and xfs-eofblocks/s
> > workqueues (which are RESCUER) got stuck waiting for memory allocation.
> 
> If those workers are really required for a further progress of the
> memory reclaim then they shouldn't block on allocation at all and either
> use pre allocated memory or use PF_MEMALLOC in case there is a guarantee
> that only very limited amount of memory is allocated from that context
> and there will be at least the same amount of memory freed as a result
> in a reasonable time.
> 
> This is something for xfs people to answer though. Please note that I
> didn't really have time to look through the below traces so the above
> note is rather generic. It would be really helpful if you could provide
> a high level dependency chains to see why those rescuers are necessary
> for the forward progress because it is really easy to get lost in so
> many traces.

Hmm, I can't claim to fully grok the wq internals, but my understanding
of the WQ_MEM_RECLAIM setting used on the XFS side was to create rescuer
threads for workqueues to deal with the case where the kthread
allocation required memory reclaim, and memory reclaim progress is made
via a workqueue item. IIRC, this was originally targeted for the
xfs-reclaim wq based on the report in commit 7a29ac474a ("xfs: give all
workqueues rescuer threads"), but it looks like that patch was modified
before it was committed to give all workqueues such a thread as well. I
don't know that we explicitly need this flag for all XFS wq's, but I
also don't recall particular meaning behind WQ_MEM_RECLAIM that
suggested the associated wq should guarantee progress, so perhaps that's
why it was added as such.

That aside, looking through some of the traces in this case...

- kswapd0 is waiting on an inode flush lock. This means somebody else
  flushed the inode and it won't be unlocked until the underlying buffer
  I/O is completed. This context is also holding pag_ici_reclaim_lock
  which is what probably blocks other contexts from getting into inode
  reclaim.
- xfsaild is in xfs_iflush(), which means it has the inode flush lock.
  It's waiting on reading the underlying inode buffer. The buffer read
  sets b_ioend_wq to the xfs-buf wq, which is ultimately going to be
  queued in xfs_buf_bio_end_io()->xfs_buf_ioend_async(). The associated
  work item is what eventually triggers the I/O completion in
  xfs_buf_ioend().

So at this point reclaim is waiting on a read I/O completion. It's not
clear to me whether the read had completed and the work item was queued
or not. I do see the following in the workqueue lockup BUG output:

[  273.412600] workqueue xfs-buf/sda1: flags=0xc
[  273.414486]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
[  273.416415]     pending: xfs_buf_ioend_work [xfs]

... which suggests that it was queued..? I suppose this could be one of
the workqueues waiting on a kthread, but xfs-buf also has a rescuer that
appears to be idle:

[ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
[ 1041.556813] Call Trace:
[ 1041.557796]  __schedule+0x336/0xe00
[ 1041.558983]  schedule+0x3d/0x90
[ 1041.560085]  rescuer_thread+0x322/0x3d0
[ 1041.561333]  kthread+0x10f/0x150
[ 1041.562464]  ? worker_thread+0x4b0/0x4b0
[ 1041.563732]  ? kthread_create_on_node+0x70/0x70
[ 1041.565123]  ret_from_fork+0x31/0x40

So shouldn't that thread pick up the work item if that is the case?

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
