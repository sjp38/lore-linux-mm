Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2BA6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:19:26 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 77so3496011pgc.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 15:19:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y84si11601877pfd.160.2017.03.03.15.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 15:19:25 -0800 (PST)
Date: Fri, 3 Mar 2017 15:19:12 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 1/2] xfs: allow kmem_zalloc_greedy to fail
Message-ID: <20170303231912.GA5073@birch.djwong.org>
References: <20170302153002.GG3213@bfoster.bfoster>
 <20170302154541.16155-1-mhocko@kernel.org>
 <20170303225444.GH17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303225444.GH17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Sat, Mar 04, 2017 at 09:54:44AM +1100, Dave Chinner wrote:
> On Thu, Mar 02, 2017 at 04:45:40PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Even though kmem_zalloc_greedy is documented it might fail the current
> > code doesn't really implement this properly and loops on the smallest
> > allowed size for ever. This is a problem because vzalloc might fail
> > permanently - we might run out of vmalloc space or since 5d17a73a2ebe
> > ("vmalloc: back off when the current task is killed") when the current
> > task is killed. The later one makes the failure scenario much more
> > probable than it used to be because it makes vmalloc() failures
> > permanent for tasks with fatal signals pending.. Fix this by bailing out
> > if the minimum size request failed.
> > 
> > This has been noticed by a hung generic/269 xfstest by Xiong Zhou.
> > 
> > fsstress: vmalloc: allocation failure, allocated 12288 of 20480 bytes, mode:0x14080c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_ZERO), nodemask=(null)
> > fsstress cpuset=/ mems_allowed=0-1
> > CPU: 1 PID: 23460 Comm: fsstress Not tainted 4.10.0-master-45554b2+ #21
> > Hardware name: HP ProLiant DL380 Gen9/ProLiant DL380 Gen9, BIOS P89 10/05/2016
> > Call Trace:
> >  dump_stack+0x63/0x87
> >  warn_alloc+0x114/0x1c0
> >  ? alloc_pages_current+0x88/0x120
> >  __vmalloc_node_range+0x250/0x2a0
> >  ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
> >  ? free_hot_cold_page+0x21f/0x280
> >  vzalloc+0x54/0x60
> >  ? kmem_zalloc_greedy+0x2b/0x40 [xfs]
> >  kmem_zalloc_greedy+0x2b/0x40 [xfs]
> >  xfs_bulkstat+0x11b/0x730 [xfs]
> >  ? xfs_bulkstat_one_int+0x340/0x340 [xfs]
> >  ? selinux_capable+0x20/0x30
> >  ? security_capable+0x48/0x60
> >  xfs_ioc_bulkstat+0xe4/0x190 [xfs]
> >  xfs_file_ioctl+0x9dd/0xad0 [xfs]
> >  ? do_filp_open+0xa5/0x100
> >  do_vfs_ioctl+0xa7/0x5e0
> >  SyS_ioctl+0x79/0x90
> >  do_syscall_64+0x67/0x180
> >  entry_SYSCALL64_slow_path+0x25/0x25
> > 
> > fsstress keeps looping inside kmem_zalloc_greedy without any way out
> > because vmalloc keeps failing due to fatal_signal_pending.
> > 
> > Reported-by: Xiong Zhou <xzhou@redhat.com>
> > Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/xfs/kmem.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > index 339c696bbc01..ee95f5c6db45 100644
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -34,6 +34,8 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> >  	size_t		kmsize = maxsize;
> >  
> >  	while (!(ptr = vzalloc(kmsize))) {
> > +		if (kmsize == minsize)
> > +			break;
> >  		if ((kmsize >>= 1) <= minsize)
> >  			kmsize = minsize;
> >  	}
> 
> Seems wrong to me - this function used to have lots of callers and
> over time we've slowly removed them or replaced them with something
> else. I'd suggest removing it completely, replacing the call sites
> with kmem_zalloc_large().

Heh.  I thought the reason why _greedy still exists (for its sole user
bulkstat) is that bulkstat had the flexibility to deal with receiving
0, 1, or 4 pages.  So yeah, we could just kill it.

But thinking even more stingily about memory, are there applications
that care about being able to bulkstat 16384 inodes at once?  How badly
does bulkstat need to be able to bulk-process more than a page's worth
of inobt records, anyway?

--D

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
