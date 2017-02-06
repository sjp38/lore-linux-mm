Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7A906B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 01:31:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d185so97736423pgc.2
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 22:31:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g21si28139540pgj.268.2017.02.05.22.31.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Feb 2017 22:31:12 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170130085546.GF8443@dhcp22.suse.cz>
	<20170202101415.GE22806@dhcp22.suse.cz>
	<201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
	<20170203145009.GB19325@dhcp22.suse.cz>
	<20170203172403.GG45388@bfoster.bfoster>
In-Reply-To: <20170203172403.GG45388@bfoster.bfoster>
Message-Id: <201702061529.ABC60444.FFFJOOHLVQSMtO@I-love.SAKURA.ne.jp>
Date: Mon, 6 Feb 2017 15:29:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bfoster@redhat.com, mhocko@kernel.org
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org

Brian Foster wrote:
> On Fri, Feb 03, 2017 at 03:50:09PM +0100, Michal Hocko wrote:
> > [Let's CC more xfs people]
> > 
> > On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> > [...]
> > > (1) I got an assertion failure.
> > 
> > I suspect this is a result of
> > http://lkml.kernel.org/r/20170201092706.9966-2-mhocko@kernel.org
> > I have no idea what the assert means though.
> > 
> > > 
> > > [  969.626518] Killed process 6262 (oom-write) total-vm:2166856kB, anon-rss:1128732kB, file-rss:4kB, shmem-rss:0kB
> > > [  969.958307] oom_reaper: reaped process 6262 (oom-write), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > [  972.114644] XFS: Assertion failed: oldlen > newlen, file: fs/xfs/libxfs/xfs_bmap.c, line: 2867
> 
> Indirect block reservation underrun on delayed allocation extent merge.
> These are extra blocks are used for the inode bmap btree when a delalloc
> extent is converted to physical blocks. We're in a case where we expect
> to only ever free excess blocks due to a merge of extents with
> independent reservations, but a situation occurs where we actually need
> blocks and hence the assert fails. This can occur if an extent is merged
> with one that has a reservation less than the expected worst case
> reservation for its size (due to previous extent splits due to hole
> punches, for example). Therefore, I think the core expectation that
> xfs_bmap_add_extent_hole_delay() will always have enough blocks
> pre-reserved is invalid.
> 
> Can you describe the workload that reproduces this? FWIW, I think the
> way xfs_bmap_add_extent_hole_delay() currently works is likely broken
> and have a couple patches to fix up indlen reservation that I haven't
> posted yet. The diff that deals with this particular bit is appended.
> Care to give that a try?

The workload is to write to a single file on XFS from 10 processes demonstrated at
http://lkml.kernel.org/r/201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp
using "while :; do ./oom-write; done" loop on a VM with 4CPUs / 2048MB RAM.
With this XFS_FILBLKS_MIN() change applied, I no longer hit assertion failures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
