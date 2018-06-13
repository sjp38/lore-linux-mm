Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC5276B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:10:24 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so2002229plt.17
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:10:24 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e12-v6si2940009pgn.171.2018.06.13.13.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:10:22 -0700 (PDT)
Date: Wed, 13 Jun 2018 14:10:21 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v13 00/72] Convert page cache to XArray
Message-ID: <20180613201021.GA4801@linux.intel.com>
References: <20180611140639.17215-1-willy@infradead.org>
 <20180612104041.GB24375@twin.jikos.cz>
 <20180612113122.GA19433@bombadil.infradead.org>
 <20180612193741.GC28436@linux.intel.com>
 <20180612194619.GH19433@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180612194619.GH19433@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, dsterba@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Tue, Jun 12, 2018 at 12:46:19PM -0700, Matthew Wilcox wrote:
> On Tue, Jun 12, 2018 at 01:37:41PM -0600, Ross Zwisler wrote:
> > On Tue, Jun 12, 2018 at 04:31:22AM -0700, Matthew Wilcox wrote:
> > > On Tue, Jun 12, 2018 at 12:40:41PM +0200, David Sterba wrote:
> > > > [ 9875.174796] kernel BUG at fs/inode.c:513!
> > > 
> > > What the ...
> > > 
> > > Somehow the fix for that got dropped.  I spent most of last week chasing
> > > that problem!  This is the correct code:
> > > 
> > > http://git.infradead.org/users/willy/linux-dax.git/commitdiff/01177bb06761539af8a6c872416109e2c8b64559
> > > 
> > > I'll check over the patchset and see if anything else got dropped!
> > 
> > Can you please repost when you have this sorted?
> > 
> > I think the commit you've pointed to is in your xarray-20180601 branch, but I
> > see two more recent xarray branches in your tree (xarray-20180608 and
> > xarray-20180612).
> > 
> > Basically, I don't know what is stable and what's not, and what I should be
> > reviewing/testing.
> 
> Yup, I shall.  The xarray-20180612 is the most recent thing I've
> published, but I'm still going over the 0601 patchset looking for other
> little pieces I may have dropped.  I've found a couple, and I'm updating
> the 0612 branch each time I find another one.
> 
> If you want to start looking at the DAX patches on the 0612 branch,
> that wouldn't be a waste of your time.  Neither would testing; I don't
> think I dropped anything from the DAX patches.

I tested xarray-20180612 vs next-20180612, and your patches cause a new
deadlock with XFS + DAX + generic/269.  Here's the output from
"echo w > /proc/sysrq-trigger":

[  302.520590] sysrq: SysRq : Show Blocked State
[  302.521431]   task                        PC stack   pid father
[  302.522419] fsstress        D    0  1703   1660 0x00000004
[  302.523238] Call Trace:
[  302.523634]  __schedule+0x2c5/0xad0
[  302.524116]  schedule+0x36/0x90
[  302.524572]  get_unlocked_entry+0xce/0x120
[  302.525160]  ? dax_insert_entry+0x2a0/0x2a0
[  302.525859]  grab_mapping_entry+0x1c4/0x240
[  302.526515]  dax_iomap_pte_fault+0x115/0x1140
[  302.527181]  dax_iomap_fault+0x37/0x40
[  302.527697]  __xfs_filemap_fault+0x2de/0x310
[  302.528241]  xfs_filemap_fault+0x2c/0x30
[  302.528828]  __do_fault+0x26/0x160
[  302.529280]  __handle_mm_fault+0xc96/0x1320
[  302.529933]  handle_mm_fault+0x1ba/0x3c0
[  302.530560]  __do_page_fault+0x2b4/0x590
[  302.531105]  do_page_fault+0x38/0x2c0
[  302.531693]  do_async_page_fault+0x2c/0xb0
[  302.532274]  ? async_page_fault+0x8/0x30
[  302.532875]  async_page_fault+0x1e/0x30
[  302.533479] RIP: 0033:0x7f0224141c96
[  302.533966] Code: Bad RIP value.
[  302.534482] RSP: 002b:00007ffdcc5a5398 EFLAGS: 00010202
[  302.535217] RAX: 00007f0224c9b000 RBX: 00000000000bf000 RCX: 00007f0224c9b040
[  302.536335] RDX: 0000000000002f94 RSI: 0000000000000096 RDI: 00007f0224c9b000
[  302.537339] RBP: 000000001dcd6500 R08: 0000000000000003 R09: 00000000000bf000
[  302.538524] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000051eb851f
[  302.539708] R13: 000000000040ab80 R14: 0000000000002f94 R15: 0000000000000000
[  302.540875] fsstress        D    0  1764   1660 0x00000004
[  302.541680] Call Trace:
[  302.542061]  __schedule+0x2c5/0xad0
[  302.542619]  schedule+0x36/0x90
[  302.543091]  get_unlocked_entry+0xce/0x120
[  302.543763]  ? dax_insert_entry+0x2a0/0x2a0
[  302.544420]  __dax_invalidate_entry+0x65/0x120
[  302.545095]  dax_delete_mapping_entry+0x13/0x20
[  302.545654]  truncate_exceptional_pvec_entries.part.15+0x215/0x220
[  302.546520]  truncate_inode_pages_range+0x2b4/0x9d0
[  302.547277]  ? up_write+0x1f/0x90
[  302.547816]  ? unmap_mapping_pages+0x62/0x130
[  302.548535]  truncate_pagecache+0x48/0x70
[  302.549156]  truncate_setsize+0x32/0x40
[  302.549775]  xfs_setattr_size+0x167/0x530
[  302.550398]  xfs_vn_setattr_size+0x57/0x170
[  302.551013]  xfs_ioc_space+0x2c6/0x3a0
[  302.551621]  ? __might_fault+0x85/0x90
[  302.552195]  xfs_file_ioctl+0xcac/0xdf0
[  302.552856]  ? __might_sleep+0x4a/0x80
[  302.553464]  ? selinux_file_ioctl+0x131/0x1f0
[  302.554168]  do_vfs_ioctl+0xa9/0x6d0
[  302.554815]  ksys_ioctl+0x75/0x80
[  302.555365]  __x64_sys_ioctl+0x1a/0x20
[  302.555962]  do_syscall_64+0x65/0x220
[  302.556603]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  302.557341] RIP: 0033:0x7f022418e0f7
[  302.557916] Code: Bad RIP value.
[  302.558487] RSP: 002b:00007ffdcc5a5468 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[  302.559734] RAX: ffffffffffffffda RBX: 0000000000000541 RCX: 00007f022418e0f7
[  302.560825] RDX: 00007ffdcc5a5490 RSI: 0000000040305824 RDI: 0000000000000003
[  302.561882] RBP: 0000000000000003 R08: 0000000000000074 R09: 00007ffdcc5a547c
[  302.562943] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000071de5
[  302.563952] R13: 0000000000405650 R14: 0000000000000000 R15: 0000000000000000

This happens for me 100% of the time, and doesn't happen at all with
next-20180612.

- Ross
