Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA496B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 18:59:20 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:58:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch] fs: turn iprune_mutex into rwsem
Message-Id: <20090814155847.860dd23f.akpm@linux-foundation.org>
In-Reply-To: <20090814152504.GA19195@wotan.suse.de>
References: <20090814152504.GA19195@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009 17:25:05 +0200
Nick Piggin <npiggin@suse.de> wrote:

> 
> We have had a report of memory allocation hangs during DVD-RAM (UDF) writing.
> 
> Jan tracked the cause of this down to UDF inode reclaim blocking:
> 
> gnome-screens D ffff810006d1d598     0 20686      1
>  ffff810006d1d508 0000000000000082 ffff810037db6718 0000000000000800
>  ffff810006d1d488 ffffffff807e4280 ffffffff807e4280 ffff810006d1a580
>  ffff8100bccbc140 ffff810006d1a8c0 0000000006d1d4e8 ffff810006d1a8c0
> Call Trace:
>  [<ffffffff804477f3>] io_schedule+0x63/0xa5
>  [<ffffffff802c2587>] sync_buffer+0x3b/0x3f
>  [<ffffffff80447d2a>] __wait_on_bit+0x47/0x79
>  [<ffffffff80447dc6>] out_of_line_wait_on_bit+0x6a/0x77
>  [<ffffffff802c24f6>] __wait_on_buffer+0x1f/0x21
>  [<ffffffff802c442a>] __bread+0x70/0x86
>  [<ffffffff88de9ec7>] :udf:udf_tread+0x38/0x3a
>  [<ffffffff88de0fcf>] :udf:udf_update_inode+0x4d/0x68c
>  [<ffffffff88de26e1>] :udf:udf_write_inode+0x1d/0x2b
>  [<ffffffff802bcf85>] __writeback_single_inode+0x1c0/0x394
>  [<ffffffff802bd205>] write_inode_now+0x7d/0xc4
>  [<ffffffff88de2e76>] :udf:udf_clear_inode+0x3d/0x53
>  [<ffffffff802b39ae>] clear_inode+0xc2/0x11b
>  [<ffffffff802b3ab1>] dispose_list+0x5b/0x102
>  [<ffffffff802b3d35>] shrink_icache_memory+0x1dd/0x213
>  [<ffffffff8027ede3>] shrink_slab+0xe3/0x158
>  [<ffffffff8027fbab>] try_to_free_pages+0x177/0x232
>  [<ffffffff8027a578>] __alloc_pages+0x1fa/0x392
>  [<ffffffff802951fa>] alloc_page_vma+0x176/0x189
>  [<ffffffff802822d8>] __do_fault+0x10c/0x417
>  [<ffffffff80284232>] handle_mm_fault+0x466/0x940
>  [<ffffffff8044b922>] do_page_fault+0x676/0xabf
> 
> Which blocks with the inode lock held, which then blocks other
> reclaimers:
> 
> X             D ffff81009d47c400     0 17285  14831
>  ffff8100844f3728 0000000000000086 0000000000000000 ffff81000000e288
>  ffff81000000da00 ffffffff807e4280 ffffffff807e4280 ffff81009d47c400
>  ffffffff805ff890 ffff81009d47c740 00000000844f3808 ffff81009d47c740
> Call Trace:
>  [<ffffffff80447f8c>] __mutex_lock_slowpath+0x72/0xa9
>  [<ffffffff80447e1a>] mutex_lock+0x1e/0x22
>  [<ffffffff802b3ba1>] shrink_icache_memory+0x49/0x213
>  [<ffffffff8027ede3>] shrink_slab+0xe3/0x158
>  [<ffffffff8027fbab>] try_to_free_pages+0x177/0x232
>  [<ffffffff8027a578>] __alloc_pages+0x1fa/0x392
>  [<ffffffff8029507f>] alloc_pages_current+0xd1/0xd6
>  [<ffffffff80279ac0>] __get_free_pages+0xe/0x4d
>  [<ffffffff802ae1b7>] __pollwait+0x5e/0xdf
>  [<ffffffff8860f2b4>] :nvidia:nv_kern_poll+0x2e/0x73
>  [<ffffffff802ad949>] do_select+0x308/0x506
>  [<ffffffff802adced>] core_sys_select+0x1a6/0x254
>  [<ffffffff802ae0b7>] sys_select+0xb5/0x157

That isn't a hang.  When the bread() completes, everything proceeds.

> Now I think the main problem is having the filesystem block (and do IO
> in inode reclaim. The problem is that this doesn't get accounted well
> and penalizes a random allocator with a big latency spike caused by
> work generated from elsewhere.

Yes.  Why does UDF do all that stuff in ->clear_inode()?  Other
filesystems have very simple, non-blocking, non-IO-doing
->clear_inode() implementations.  This sounds like a design problem
within UDF.

> I think the best idea would be to avoid this. By design if possible,
> or by deferring the hard work to an asynchronous context. If the latter,
> then the fs would probably want to throttle creation of new work with
> queue size of the deferred work, but let's not get into those details.
> 
> Anyway, another obvious thing we looked at is the iprune_mutex which
> is causing the cascading blocking. We could turn this into an rwsem to
> improve concurrency. It is unreasonable to totally ban all potentially
> slow or blocking operations in inode reclaim, so I think this is a cheap
> way to get a small improvement.
> 
> This doesn't solve the whole problem of course. The process doing inode
> reclaim will still take the latency hit, and concurrent processes may
> end up contending on filesystem locks. So fs developers should keep
> these problems in mind please (or discuss alternatives).
> 
> Jan points out this has the potential to uncover concurrency bugs in fs
> code.
> 
> Comments?

I bet you found that nice comment over iprune_mutex to be useful, no?

That comment needs updating by this patch, btw.

> -	mutex_unlock(&iprune_mutex);
> +	up_write(&iprune_sem);

yup, the patch looks OK.  inode_lock protects the lists and each thread
will make each inode ineligible for lookup by other threads, so it's
hard to see how there could be races in the VFS code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
