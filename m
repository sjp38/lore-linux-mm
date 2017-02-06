Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E49E56B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 10:47:35 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y207so41397468qkb.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:47:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v35si747842qtc.203.2017.02.06.07.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 07:47:35 -0800 (PST)
Date: Mon, 6 Feb 2017 10:47:32 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170206154732.GE57865@bfoster.bfoster>
References: <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145009.GB19325@dhcp22.suse.cz>
 <20170203172403.GG45388@bfoster.bfoster>
 <201702061529.ABC60444.FFFJOOHLVQSMtO@I-love.SAKURA.ne.jp>
 <20170206143533.GC57865@bfoster.bfoster>
 <20170206144221.GE10298@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206144221.GE10298@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org

On Mon, Feb 06, 2017 at 03:42:22PM +0100, Michal Hocko wrote:
> On Mon 06-02-17 09:35:33, Brian Foster wrote:
> > On Mon, Feb 06, 2017 at 03:29:24PM +0900, Tetsuo Handa wrote:
> > > Brian Foster wrote:
> > > > On Fri, Feb 03, 2017 at 03:50:09PM +0100, Michal Hocko wrote:
> > > > > [Let's CC more xfs people]
> > > > > 
> > > > > On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> > > > > [...]
> > > > > > (1) I got an assertion failure.
> > > > > 
> > > > > I suspect this is a result of
> > > > > http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org
> > > > > I have no idea what the assert means though.
> > > > > 
> > > > > > 
> > > > > > [  969.626518] Killed process 6262 (oom-write) total-vm:2166856kB, anon-rss:1128732kB, file-rss:4kB, shmem-rss:0kB
> > > > > > [  969.958307] oom_reaper: reaped process 6262 (oom-write), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > > > [  972.114644] XFS: Assertion failed: oldlen > newlen, file: fs/xfs/libxfs/xfs_bmap.c, line: 2867
> > > > 
> > > > Indirect block reservation underrun on delayed allocation extent merge.
> > > > These are extra blocks are used for the inode bmap btree when a delalloc
> > > > extent is converted to physical blocks. We're in a case where we expect
> > > > to only ever free excess blocks due to a merge of extents with
> > > > independent reservations, but a situation occurs where we actually need
> > > > blocks and hence the assert fails. This can occur if an extent is merged
> > > > with one that has a reservation less than the expected worst case
> > > > reservation for its size (due to previous extent splits due to hole
> > > > punches, for example). Therefore, I think the core expectation that
> > > > xfs_bmap_add_extent_hole_delay() will always have enough blocks
> > > > pre-reserved is invalid.
> > > > 
> > > > Can you describe the workload that reproduces this? FWIW, I think the
> > > > way xfs_bmap_add_extent_hole_delay() currently works is likely broken
> > > > and have a couple patches to fix up indlen reservation that I haven't
> > > > posted yet. The diff that deals with this particular bit is appended.
> > > > Care to give that a try?
> > > 
> > > The workload is to write to a single file on XFS from 10 processes demonstrated at
> > > http://lkml.kernel.org/r/201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp
> > > using "while :; do ./oom-write; done" loop on a VM with 4CPUs / 2048MB RAM.
> > > With this XFS_FILBLKS_MIN() change applied, I no longer hit assertion failures.
> > > 
> > 
> > Thanks for testing. Well, that's an interesting workload. I couldn't
> > reproduce on a few quick tries in a similarly configured vm.
> > 
> > Normally I'd expect to see this kind of thing on a hole punching
> > workload or dealing with large, sparse files that make use of
> > speculative preallocation (post-eof blocks allocated in anticipation of
> > file extending writes). I'm wondering if what is happening here is that
> > the appending writes and file closes due to oom kills are generating
> > speculative preallocs and prealloc truncates, respectively, and that
> > causes prealloc extents at the eof boundary to be split up and then
> > re-merged by surviving appending writers.
> 
> Can those preallocs be affected by
> http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org ?
> 

Hmm, I wouldn't expect that to make much of a difference wrt to the core
problem. The prealloc is created on a file extending write that requires
block allocation (we basically just tack on extra blocks to an extending
alloc based on some heuristics like the size of the file and the
previous extent). Whether that allocation occurs on one iomap iteration
or another due to a short write and retry, I wouldn't expect to matter
that much.

I suppose it could change the behavior of specialized workload though.
E.g., if it caused a write() call to return quicker and thus lead to a
file close(). We do use file release as an indication that prealloc will
not be used and can reclaim it at that point (presumably causing an
extent split with pre-eof blocks).

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
