Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD166B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 06:43:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j14-v6so15115018wro.7
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:43:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33-v6si99254edf.53.2018.06.12.03.43.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jun 2018 03:43:31 -0700 (PDT)
Date: Tue, 12 Jun 2018 12:40:41 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v13 00/72] Convert page cache to XArray
Message-ID: <20180612104041.GB24375@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180611140639.17215-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Mon, Jun 11, 2018 at 07:05:27AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The XArray is a replacement for the radix tree.  For the moment it uses
> the same data structures, enabling a gradual replacement.  This patch
> set implements the XArray and converts the page cache to use it.
> 
> A version of these patches has been running under xfstests for over 48
> hours, so I have some confidence in them.  The DAX changes are untested.
> This is based on next-20180608 and is available as a git tree at
> git://git.infradead.org/users/willy/linux-dax.git xarray-20180608

I've hit a crash, triggered by fstests/btrfs/141 and with ext4 on the stack.
The test itself does not use ext4, so it must be the root partition of the VM
(qemu 2G ram, 4 cpus). Other tests up to that point were ok.

[ 9875.174796] kernel BUG at fs/inode.c:513!
[ 9875.176519] invalid opcode: 0000 [#1] PREEMPT SMP
[ 9875.177532] CPU: 3 PID: 30077 Comm: 141 Not tainted 4.17.0-next-20180608-default+ #1
[ 9875.179235] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[ 9875.181152] RIP: 0010:clear_inode+0x7a/0x90
[ 9875.185414] RSP: 0018:ffffae6b49893c40 EFLAGS: 00010086
[ 9875.186381] RAX: 0000000000000000 RBX: ffff8f427d3024a0 RCX: 0000000000000000
[ 9875.187629] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff8f427d302608
[ 9875.188838] RBP: ffff8f427d302608 R08: 0000000000000000 R09: ffffffffffffffff
[ 9875.190061] R10: ffffae6b49893a28 R11: ffffffffffffffff R12: ffffffff83a338c0
[ 9875.191348] R13: ffff8f427bfd9000 R14: 000000000000011f R15: 0000000000000000
[ 9875.192750] FS:  00007fde1859ab80(0000) GS:ffff8f427fd80000(0000) knlGS:0000000000000000
[ 9875.194370] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 9875.195504] CR2: 000055c95307e1a0 CR3: 000000007be57000 CR4: 00000000000006e0
[ 9875.196957] Call Trace:
[ 9875.197593]  ext4_clear_inode+0x16/0x80
[ 9875.198519]  ext4_evict_inode+0x44/0x510
[ 9875.199458]  evict+0xcd/0x190
[ 9875.200205]  dispose_list+0x48/0x60
[ 9875.201050]  prune_icache_sb+0x42/0x50
[ 9875.201943]  super_cache_scan+0x124/0x1a0
[ 9875.202896]  shrink_slab+0x1c9/0x3d0
[ 9875.203760]  drop_slab_node+0x22/0x50
[ 9875.204636]  drop_caches_sysctl_handler+0x47/0xb0
[ 9875.205707]  proc_sys_call_handler+0xb5/0xd0
[ 9875.206671]  __vfs_write+0x23/0x150
[ 9875.207322]  ? set_close_on_exec+0x30/0x70
[ 9875.208062]  vfs_write+0xad/0x1e0
[ 9875.208762]  ksys_write+0x42/0x90
[ 9875.209487]  do_syscall_64+0x4f/0xe0
[ 9875.210272]  entry_SYSCALL_64_after_hwframe+0x44/0xa9

 504 void clear_inode(struct inode *inode)
 505 {
 506         /*
 507          * We have to cycle the i_pages lock here because reclaim can be in the
 508          * process of removing the last page (in __delete_from_page_cache())
 509          * and we must not free the mapping under it.
 510          */
 511         xa_lock_irq(&inode->i_data.i_pages);
 512         BUG_ON(inode->i_data.nrpages);
 513         BUG_ON(inode->i_data.nrexceptional);

'exceptional' is from the page cache realm so I think it's not an ext4 bug.
