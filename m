Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C27BD6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 11:44:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so20370115pfx.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 08:44:50 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v10si7862537pge.382.2017.03.02.08.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 08:44:49 -0800 (PST)
Date: Thu, 2 Mar 2017 08:44:38 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 1/2] xfs: allow kmem_zalloc_greedy to fail
Message-ID: <20170302164438.GC24806@birch.djwong.org>
References: <20170302153002.GG3213@bfoster.bfoster>
 <20170302154541.16155-1-mhocko@kernel.org>
 <20170302161606.GQ1404@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302161606.GQ1404@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Thu, Mar 02, 2017 at 05:16:06PM +0100, Michal Hocko wrote:
> I've just realized that Darrick was not on the CC list. Let's add him.
> I believe this patch should go in in the current cycle because
> 5d17a73a2ebe was merged in this merge window and it can be abused...
> 
> The other patch [1] is not that urgent.
> 
> [1] http://lkml.kernel.org/r/20170302154541.16155-2-mhocko@kernel.org

Both patches look ok to me.  I'll take both patches for rc2.
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

(Annoyingly I missed the whole thread yesterday due to vger slowness, in
case anyone was wondering why I didn't reply.)

--D

> 
> On Thu 02-03-17 16:45:40, Michal Hocko wrote:
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
> > -- 
> > 2.11.0
> > 
> 
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
