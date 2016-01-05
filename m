Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 41F286B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 06:13:59 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so23773013wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 03:13:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m132si4617465wmd.38.2016.01.05.03.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 03:13:57 -0800 (PST)
Date: Tue, 5 Jan 2016 12:13:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 4/7] dax: add support for fsync/msync
Message-ID: <20160105111346.GC2724@quack.suse.cz>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4jVJGPO8Yhz8WgSJTFw+o8=5n6yx17zchXA6C+wEKcajg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jVJGPO8Yhz8WgSJTFw+o8=5n6yx17zchXA6C+wEKcajg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Sun 03-01-16 10:13:06, Dan Williams wrote:
> On Wed, Dec 23, 2015 at 11:39 AM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > To properly handle fsync/msync in an efficient way DAX needs to track dirty
> > pages so it is able to flush them durably to media on demand.
> >
> > The tracking of dirty pages is done via the radix tree in struct
> > address_space.  This radix tree is already used by the page writeback
> > infrastructure for tracking dirty pages associated with an open file, and
> > it already has support for exceptional (non struct page*) entries.  We
> > build upon these features to add exceptional entries to the radix tree for
> > DAX dirty PMD or PTE pages at fault time.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> I'm hitting the following report with the ndctl dax test [1] on
> next-20151231.  I bisected it to
>  commit 3cb108f941de "dax-add-support-for-fsync-sync-v6".  I'll take a
> closer look tomorrow, but in case someone can beat me to it, here's
> the back-trace:
> 
> ------------[ cut here ]------------
> kernel BUG at fs/inode.c:497!

I suppose this is the check that mapping->nr_exceptional is zero, isn't it?
Hum, I don't see how that could happen given we call
truncate_inode_pages_final() just before the clear_inode() call which
removes all the exceptional entries from the radix tree.  And there's not
much room for a race during umount... Does the radix tree really contain
any entry or is it an accounting bug?

								Honza

> [..]
> CPU: 1 PID: 3001 Comm: umount Tainted: G           O    4.4.0-rc7+ #2412
> Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> task: ffff8800da2a5a00 ti: ffff880307794000 task.ti: ffff880307794000
> RIP: 0010:[<ffffffff81280171>]  [<ffffffff81280171>] clear_inode+0x71/0x80
> RSP: 0018:ffff880307797d50  EFLAGS: 00010002
> RAX: ffff8800da2a5a00 RBX: ffff8800ca2e7328 RCX: ffff8800da2a5a28
> RDX: 0000000000000001 RSI: 0000000000000005 RDI: ffff8800ca2e7530
> RBP: ffff880307797d60 R08: ffffffff82900ae0 R09: 0000000000000000
> R10: ffff8800ca2e7548 R11: 0000000000000000 R12: ffff8800ca2e7530
> R13: ffff8800ca2e7328 R14: ffff8800da2e88d0 R15: ffff8800da2e88d0
> FS:  00007f2b22f4a880(0000) GS:ffff88031fc40000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00005648abd933e8 CR3: 000000007f3fc000 CR4: 00000000000006e0
> Stack:
> ffff8800ca2e7328 ffff8800ca2e7000 ffff880307797d88 ffffffffa01c18af
> ffff8800ca2e7328 ffff8800ca2e74d0 ffffffffa01ec740 ffff880307797db0
> ffffffff81281038 ffff8800ca2e74c0 ffff880307797e00 ffff8800ca2e7328
> Call Trace:
> [<ffffffffa01c18af>] xfs_fs_evict_inode+0x5f/0x110 [xfs]
> [<ffffffff81281038>] evict+0xb8/0x180
> [<ffffffff8128113b>] dispose_list+0x3b/0x50
> [<ffffffff81282014>] evict_inodes+0x144/0x170
> [<ffffffff8126447f>] generic_shutdown_super+0x3f/0xf0
> [<ffffffff81264837>] kill_block_super+0x27/0x70
> [<ffffffff81264a53>] deactivate_locked_super+0x43/0x70
> [<ffffffff81264e9c>] deactivate_super+0x5c/0x60
> [<ffffffff81285aff>] cleanup_mnt+0x3f/0x90
> [<ffffffff81285b92>] __cleanup_mnt+0x12/0x20
> [<ffffffff810c4f26>] task_work_run+0x76/0x90
> [<ffffffff81003e3a>] syscall_return_slowpath+0x20a/0x280
> [<ffffffff8192671a>] int_ret_from_sys_call+0x25/0x9f
> Code: 48 8d 93 30 03 00 00 48 39 c2 75 23 48 8b 83 d0 00 00 00 a8 20
> 74 1a a8 40 75 18 48 c7 8
> 3 d0 00 00 00 60 00 00 00 5b 41 5c 5d c3 <0f> 0b 0f 0b 0f 0b 0f 0b 0f
> 0b 0f 1f 44 00 00 0f 1f
> 44 00 00 55
> RIP  [<ffffffff81280171>] clear_inode+0x71/0x80
> RSP <ffff880307797d50>
> ---[ end trace 3b1d8898a94a4fc1 ]---
> 
> [1]: git://git@github.com:pmem/ndctl.git pending
> make TESTS="test/dax.sh" check
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
