Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6B26B0073
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 05:32:17 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so2065367wiv.8
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 02:32:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kn5si1527780wjb.116.2014.12.12.02.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 02:32:15 -0800 (PST)
Date: Fri, 12 Dec 2014 11:32:13 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [RFC PATCH v3 0/7] btrfs: implement swap file support
Message-ID: <20141212103213.GL27601@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1418173063.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 09, 2014 at 05:45:41PM -0800, Omar Sandoval wrote:
> After some discussion on the mailing list, I decided that for simplicity and
> reliability, it's best to simply disallow COW files and files with shared
> extents (like files with extents shared with a snapshot). From a user's
> perspective, this means that a snapshotted subvolume cannot be used for a swap
> file, but keeping the swap file in a separate subvolume that is never
> snapshotted seems entirely reasonable to me.

Well, there are enough special cases how to do things on btrfs and I'd
like to avoid introducing another one.

> An alternative suggestion was to
> allow swap files to be snapshotted and to do an implied COW on swap file
> activation, which I was ready to implement until I realized that we can't permit
> snapshotting a subvolume with an active swap file, so this creates a surprising
> inconsistency for users (in my opinion).

I still don't see why it's not possible to do the snapshot with an
active swapfile.

> As with before, this functionality is tenuously tested in a virtual machine with
> some artificial workloads, but it "works for me". I'm pretty happy with the
> results on my end, so please comment away.

The non-btrfs changes can go independently and do not have to wait until
we resolve the swap vs snapshot problem.

I did a simple test and it crashed instantly, lockep complains:

memory: 2G
swap file: 1G
kernel: 3.17 + v3

[  739.790731] Adding 1054716k swap on /mnt/test-swap/mnt/swapfile.  Priority:-1 extents:1 across:1054716k
[  751.848607]
[  751.851852] =====================================
[  751.852161] [ BUG: bad unlock balance detected! ]
[  751.852161] 3.17.0-default+ #199 Not tainted
[  751.852161] -------------------------------------
[  751.852161] heavy_swap/4119 is trying to release lock (&sb->s_type->i_mutex_key) at:
[  751.852161] [<ffffffff81a4f0ce>] mutex_unlock+0xe/0x10
[  751.852161] but there are no more locks to release!
[  751.852161]
[  751.852161] other info that might help us debug this:
[  751.852161] 1 lock held by heavy_swap/4119:
[  751.852161]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81043ba9>] __do_page_fault+0x149/0x560
[  751.852161]
[  751.852161] stack backtrace:
[  751.852161] CPU: 1 PID: 4119 Comm: heavy_swap Not tainted 3.17.0-default+ #199
[  751.852161] Hardware name: Intel Corporation Santa Rosa platform/Matanzas, BIOS TSRSCRB1.86C.0047.B00.0610170821 10/17/06
[  751.852161]  ffffffff81a4f0ce ffff880075dbb3d8 ffffffff81a4b268 0000000000000001
[  751.852161]  ffff8800775e0000 ffff880075dbb408 ffffffff810b51a9 0000000000000000
[  751.852161]  ffff8800775e0000 00000000ffffffff ffff8800763c9d00 ffff880075dbb4a8
[  751.852161] Call Trace:
[  751.852161]  [<ffffffff81a4f0ce>] ? mutex_unlock+0xe/0x10
[  751.852161]  [<ffffffff81a4b268>] dump_stack+0x51/0x71
[  751.852161]  [<ffffffff810b51a9>] print_unlock_imbalance_bug+0xf9/0x100
[  751.852161]  [<ffffffff810b8bcf>] lock_release_non_nested+0x2cf/0x3e0
[  751.852161]  [<ffffffff81a541ed>] ? ftrace_call+0x5/0x2f
[  751.852161]  [<ffffffff81a4f0ce>] ? mutex_unlock+0xe/0x10
[  751.852161]  [<ffffffff81a4f0ce>] ? mutex_unlock+0xe/0x10
[  751.852161]  [<ffffffff810b8da9>] lock_release+0xc9/0x240
[  751.852161]  [<ffffffff81a4eef0>] __mutex_unlock_slowpath+0x80/0x190
[  751.852161]  [<ffffffff81a4f0c9>] ? mutex_unlock+0x9/0x10
[  751.852161]  [<ffffffff81a4f0ce>] mutex_unlock+0xe/0x10
[  751.852161]  [<ffffffffa0037c88>] btrfs_direct_IO+0x2b8/0x310 [btrfs]
[  751.852161]  [<ffffffff810acf4d>] ? __wake_up_bit+0xd/0x50
[  751.852161]  [<ffffffff8117e03b>] __swap_writepage+0x10b/0x270
[  751.852161]  [<ffffffff81180723>] ? page_swapcount+0x53/0x70
[  751.852161]  [<ffffffff8117e1d7>] swap_writepage+0x37/0x60
[  751.852161]  [<ffffffff8115a072>] shmem_writepage+0x2a2/0x2e0
[  751.852161]  [<ffffffff811554ae>] shrink_page_list+0x44e/0x9d0
[  751.852161]  [<ffffffff81a51b50>] ? _raw_spin_unlock_irq+0x30/0x40
[  751.852161]  [<ffffffff811560cd>] shrink_inactive_list+0x26d/0x4f0
[  751.852161]  [<ffffffff813adcc9>] ? blk_start_plug+0x9/0x50
[  751.852161]  [<ffffffff81156918>] shrink_lruvec+0x5c8/0x6c0
[  751.852161]  [<ffffffff81165f09>] ? compaction_suitable+0x19/0xc0
[  751.852161]  [<ffffffff81165f09>] ? compaction_suitable+0x19/0xc0
[  751.852161]  [<ffffffff81156a5d>] shrink_zone+0x4d/0x120
[  751.852161]  [<ffffffff811577ea>] do_try_to_free_pages+0x19a/0x3a0
[  751.852161]  [<ffffffff81152a7d>] ? pfmemalloc_watermark_ok+0xd/0xc0
[  751.852161]  [<ffffffff81157b42>] try_to_free_pages+0xb2/0x160
[  751.852161]  [<ffffffff81a4bb79>] ? _cond_resched+0x9/0x30
[  751.852161]  [<ffffffff8114adfb>] __alloc_pages_nodemask+0x5eb/0xa90
[  751.852161]  [<ffffffff81a541ed>] ? ftrace_call+0x5/0x2f
[  751.852161]  [<ffffffff811784f1>] ? anon_vma_prepare+0x21/0x190
[  751.852161]  [<ffffffff811916a8>] do_huge_pmd_anonymous_page+0xe8/0x330
[  751.852161]  [<ffffffff811783c9>] ? is_vma_temporary_stack+0x9/0x30
[  751.852161]  [<ffffffff8116edd5>] handle_mm_fault+0x135/0xb60
[  751.852161]  [<ffffffff81172015>] ? find_vma+0x15/0x80
[  751.852161]  [<ffffffff81166c6d>] ? vmacache_find+0xd/0xd0
[  751.852161]  [<ffffffff81097c2e>] ? __might_sleep+0xe/0x110
[  751.852161]  [<ffffffff81043c0d>] __do_page_fault+0x1ad/0x560
[  751.852161]  [<ffffffff81073000>] ? do_fork+0xe0/0x420
[  751.852161]  [<ffffffff81a53f43>] ? error_sti+0x5/0x6
[  751.852161]  [<ffffffff813e660d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  751.852161]  [<ffffffff810440cc>] do_page_fault+0xc/0x10
[  751.852161]  [<ffffffff81a53d42>] page_fault+0x22/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
