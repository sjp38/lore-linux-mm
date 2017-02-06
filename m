Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A01766B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:42:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so19754455wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:42:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l205si8291653wmf.162.2017.02.06.06.42.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 06:42:24 -0800 (PST)
Date: Mon, 6 Feb 2017 15:42:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170206144221.GE10298@dhcp22.suse.cz>
References: <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145009.GB19325@dhcp22.suse.cz>
 <20170203172403.GG45388@bfoster.bfoster>
 <201702061529.ABC60444.FFFJOOHLVQSMtO@I-love.SAKURA.ne.jp>
 <20170206143533.GC57865@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206143533.GC57865@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org

On Mon 06-02-17 09:35:33, Brian Foster wrote:
> On Mon, Feb 06, 2017 at 03:29:24PM +0900, Tetsuo Handa wrote:
> > Brian Foster wrote:
> > > On Fri, Feb 03, 2017 at 03:50:09PM +0100, Michal Hocko wrote:
> > > > [Let's CC more xfs people]
> > > > 
> > > > On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> > > > [...]
> > > > > (1) I got an assertion failure.
> > > > 
> > > > I suspect this is a result of
> > > > http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org
> > > > I have no idea what the assert means though.
> > > > 
> > > > > 
> > > > > [  969.626518] Killed process 6262 (oom-write) total-vm:2166856kB, anon-rss:1128732kB, file-rss:4kB, shmem-rss:0kB
> > > > > [  969.958307] oom_reaper: reaped process 6262 (oom-write), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  972.114644] XFS: Assertion failed: oldlen > newlen, file: fs/xfs/libxfs/xfs_bmap.c, line: 2867
> > > 
> > > Indirect block reservation underrun on delayed allocation extent merge.
> > > These are extra blocks are used for the inode bmap btree when a delalloc
> > > extent is converted to physical blocks. We're in a case where we expect
> > > to only ever free excess blocks due to a merge of extents with
> > > independent reservations, but a situation occurs where we actually need
> > > blocks and hence the assert fails. This can occur if an extent is merged
> > > with one that has a reservation less than the expected worst case
> > > reservation for its size (due to previous extent splits due to hole
> > > punches, for example). Therefore, I think the core expectation that
> > > xfs_bmap_add_extent_hole_delay() will always have enough blocks
> > > pre-reserved is invalid.
> > > 
> > > Can you describe the workload that reproduces this? FWIW, I think the
> > > way xfs_bmap_add_extent_hole_delay() currently works is likely broken
> > > and have a couple patches to fix up indlen reservation that I haven't
> > > posted yet. The diff that deals with this particular bit is appended.
> > > Care to give that a try?
> > 
> > The workload is to write to a single file on XFS from 10 processes demonstrated at
> > http://lkml.kernel.org/r/201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp
> > using "while :; do ./oom-write; done" loop on a VM with 4CPUs / 2048MB RAM.
> > With this XFS_FILBLKS_MIN() change applied, I no longer hit assertion failures.
> > 
> 
> Thanks for testing. Well, that's an interesting workload. I couldn't
> reproduce on a few quick tries in a similarly configured vm.
> 
> Normally I'd expect to see this kind of thing on a hole punching
> workload or dealing with large, sparse files that make use of
> speculative preallocation (post-eof blocks allocated in anticipation of
> file extending writes). I'm wondering if what is happening here is that
> the appending writes and file closes due to oom kills are generating
> speculative preallocs and prealloc truncates, respectively, and that
> causes prealloc extents at the eof boundary to be split up and then
> re-merged by surviving appending writers.

Can those preallocs be affected by
http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org ?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
