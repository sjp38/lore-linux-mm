Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BAE876B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 11:12:07 -0400 (EDT)
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <20090502080405.GA6432@localhost>
References: <20090430020004.GA1898@localhost>
	 <20090429191044.b6fceae2.akpm@linux-foundation.org>
	 <1241097573.6020.7.camel@localhost.localdomain>
	 <20090430134821.GB8644@localhost> <20090430142807.GA13931@localhost>
	 <1241103132.6020.17.camel@localhost.localdomain>
	 <20090502022515.GB29422@localhost>  <20090502080405.GA6432@localhost>
Content-Type: text/plain
Date: Sat, 02 May 2009 11:11:12 -0400
Message-Id: <1241277072.3086.47.camel@dhcp231-142.rdu.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-05-02 at 16:04 +0800, Wu Fengguang wrote:
> On Sat, May 02, 2009 at 10:25:15AM +0800, Wu Fengguang wrote:

> > Eric: this patch worked for me. Till now it has undergone many read,
> > write, reboot, halt cycles without triggering the lockdep warnings :-)
>  
> Bad news: the warning turns up again:
> 
> [12979.538333] nfsd: last server has exited, flushing export cache
> [12982.962058]
> [12982.962062] ======================================================
> [12982.965486] [ INFO: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected ]
> [12982.965486] 2.6.30-rc2-next-20090417 #218
> [12982.965486] ------------------------------------------------------
> [12982.965486] umount/3574 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
> [12982.965486]  (&inode->inotify_mutex){+.+.+.}, at: [<ffffffff81134ada>] inotify_unmount_inodes+0xda/0x1f0
> [12982.965486]
> [12982.965486] and this task is already holding:
> [12982.965486]  (iprune_mutex){+.+.-.}, at: [<ffffffff811160da>] invalidate_inodes+0x3a/0x170
> [12982.965486] which would create a new lock dependency:
> [12982.965486]  (iprune_mutex){+.+.-.} -> (&inode->inotify_mutex){+.+.+.}
> [12982.965486]
> [12982.965486] but this new dependency connects a RECLAIM_FS-irq-safe lock:
> [12982.965486]  (iprune_mutex){+.+.-.}
> [12982.965486] ... which became RECLAIM_FS-irq-safe at:
> [12982.965486]   [<ffffffff8107b172>] __lock_acquire+0xc62/0x1ae0
> [12982.965486]   [<ffffffff8107c0d1>] lock_acquire+0xe1/0x120
> [12982.965486]   [<ffffffff81569353>] mutex_lock_nested+0x63/0x420
> [12982.965486]   [<ffffffff81115e24>] shrink_icache_memory+0x84/0x300
> [12982.965486]   [<ffffffff810d5d75>] shrink_slab+0x125/0x180
> [12982.965486]   [<ffffffff810d6f66>] try_to_free_pages+0x276/0x400
> [12982.965486]   [<ffffffff810cdf96>] __alloc_pages_internal+0x2b6/0x650
> [12982.965486]   [<ffffffff810f819c>] alloc_pages_current+0x8c/0xe0
> [12982.965486]   [<ffffffff810c5920>] __page_cache_alloc+0x10/0x20
> [12982.965486]   [<ffffffff810d0add>] __do_page_cache_readahead+0x11d/0x260
> [12982.965486]   [<ffffffff810d0f4b>] ondemand_readahead+0x1cb/0x250
> [12982.965486]   [<ffffffff810d1079>] page_cache_async_readahead+0xa9/0xc0
> [12982.965486]   [<ffffffff810c7763>] generic_file_aio_read+0x493/0x7c0
> [12982.965486]   [<ffffffff810fe1a9>] do_sync_read+0xf9/0x140
> [12982.965486]   [<ffffffff810ff233>] vfs_read+0x113/0x1d0
> [12982.965486]   [<ffffffff810ff407>] sys_read+0x57/0xb0
> [12982.965486]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
> [12982.965486]   [<ffffffffffffffff>] 0xffffffffffffffff
> [12982.965486]
> [12982.965486] to a RECLAIM_FS-irq-unsafe lock:
> [12982.965486]  (&inode->inotify_mutex){+.+.+.}
> [12982.965486] ... which became RECLAIM_FS-irq-unsafe at:
> [12982.965486] ...  [<ffffffff810791b8>] mark_held_locks+0x68/0x90
> [12982.965486]   [<ffffffff810792d5>] lockdep_trace_alloc+0xf5/0x100
> [12982.965486]   [<ffffffff810fa561>] __kmalloc_node+0x31/0x1e0
> [12982.965486]   [<ffffffff811359c2>] kernel_event+0xe2/0x190
> [12982.965486]   [<ffffffff81135b96>] inotify_dev_queue_event+0x126/0x230
> [12982.965486]   [<ffffffff811343a6>] inotify_inode_queue_event+0xc6/0x110
> [12982.965486]   [<ffffffff8110974d>] vfs_create+0xcd/0x140
> [12982.965486]   [<ffffffff8110d55d>] do_filp_open+0x88d/0xa20
> [12982.965486]   [<ffffffff810fbe68>] do_sys_open+0x98/0x140
> [12982.965486]   [<ffffffff810fbf50>] sys_open+0x20/0x30
> [12982.965486]   [<ffffffff8100c272>] system_call_fastpath+0x16/0x1b
> [12982.965486]   [<ffffffffffffffff>] 0xffffffffffffffff

So this is a completely different message than the original report, and
one that is kind of cool and interesting.  I think it could be triggered
today.  Again I think it's a false positive, since the inodes in
question are being kicked out of kernel because the fs is being
unmounted, but I'll poke someone to make sure I understand what lockdep
is telling me and we can shut this one up too if we care....

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
