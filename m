Subject: Re: mm: soft lockup in 2.6.23-6636. caused by drop_caches ?
From: richard kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <1193148210.16944.1.camel@twins>
References: <1193147728.3044.18.camel@castor.rsk.org>
	 <1193148210.16944.1.camel@twins>
Content-Type: text/plain
Date: Tue, 23 Oct 2007 22:53:41 +0100
Message-Id: <1193176421.3126.14.camel@castor.rsk.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-23 at 16:03 +0200, Peter Zijlstra wrote:
> On Tue, 2007-10-23 at 14:55 +0100, richard kennedy wrote:
> > on git v2.6.23-6636-g557ebb7 I'm getting a soft lockup when running a
> > simple disk write test case on AMD64X2, sata hd &  ext3.
> > 
> > the test does this
> > sync
> > echo 3 > /proc/sys/vm/drop_caches
> > for (( i=0; $i < $count; i=$i+1 )) ; do
> > dd if=large_file of=copy_file_$i bs=4k &
> > done
> 
> have you tried with lockdep enabled?
> 
> Also, doesn't really surprise me since its known that drop_caches has a
> deadlock in it.
> 
Thanks for suggestion, of course it took a lot longer to fail with all
the debug turned on.

But, lockdep gives a possible circular lock dependency between
journal->j_list_lock and inode_lock

drop_pagecache_sb takes the inode_lock and calls down into
journal_try_to_free_buffers which takes the journal->j_list_lock

while in kjournald, journal_commit_transaction take the j_list_lock and
calls __journal_unfile_buffer that takes the inode_lock.

I'm not sure how to fix this, but hope this helps someone else ;)
Here's the full info.

Cheers
Richard


=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.23 #2
-------------------------------------------------------
bash/3535 is trying to acquire lock:
 (&journal->j_list_lock){--..}, at: [<ffffffff88023b58>] journal_try_to_free_buffers+0x7e/0x131 [jbd]

but task is already holding lock:
 (inode_lock){--..}, at: [<ffffffff810b5574>] drop_pagecache+0x4d/0xeb

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (inode_lock){--..}:
       [<ffffffff81056026>] __lock_acquire+0xac8/0xcf0
       [<ffffffff810b4f2e>] __mark_inode_dirty+0xe2/0x174
       [<ffffffff810562d2>] lock_acquire+0x84/0xa8
       [<ffffffff810b4f2e>] __mark_inode_dirty+0xe2/0x174
       [<ffffffff8125564a>] _spin_lock+0x1e/0x27
       [<ffffffff810b4f2e>] __mark_inode_dirty+0xe2/0x174
       [<ffffffff810b8c2a>] __set_page_dirty+0x118/0x124
       [<ffffffff88022238>] __journal_unfile_buffer+0x9/0x13 [jbd]
       [<ffffffff880248c5>] journal_commit_transaction+0xbd1/0xde8 [jbd]
       [<ffffffff880278f1>] kjournald+0xc6/0x1f1 [jbd]
       [<ffffffff8104b87a>] autoremove_wake_function+0x0/0x2e
       [<ffffffff810550bd>] trace_hardirqs_on+0x11e/0x149
       [<ffffffff8802782b>] kjournald+0x0/0x1f1 [jbd]
       [<ffffffff8104b760>] kthread+0x47/0x73
       [<ffffffff8125512e>] trace_hardirqs_on_thunk+0x35/0x3a
       [<ffffffff8100cdf8>] child_rip+0xa/0x12
       [<ffffffff8100c50f>] restore_args+0x0/0x30
       [<ffffffff8104b719>] kthread+0x0/0x73
       [<ffffffff8100cdee>] child_rip+0x0/0x12
       [<ffffffffffffffff>] 0xffffffffffffffff

-> #0 (&journal->j_list_lock){--..}:
       [<ffffffff8105479f>] print_circular_bug_header+0xcc/0xd3
       [<ffffffff81055f2b>] __lock_acquire+0x9cd/0xcf0
       [<ffffffff88023b58>] journal_try_to_free_buffers+0x7e/0x131 [jbd]
       [<ffffffff810562d2>] lock_acquire+0x84/0xa8
       [<ffffffff88023b58>] journal_try_to_free_buffers+0x7e/0x131 [jbd]
       [<ffffffff8125564a>] _spin_lock+0x1e/0x27
       [<ffffffff88023b58>] journal_try_to_free_buffers+0x7e/0x131 [jbd]
       [<ffffffff810785db>] __invalidate_mapping_pages+0x81/0x103
       [<ffffffff810b559d>] drop_pagecache+0x76/0xeb
       [<ffffffff810b562c>] drop_caches_sysctl_handler+0x1a/0x2e
       [<ffffffff810d9407>] proc_sys_write+0x7c/0xa4
       [<ffffffff81099619>] vfs_write+0xc6/0x16f
       [<ffffffff81099bd6>] sys_write+0x45/0x6e
       [<ffffffff8100c05a>] tracesys+0xdc/0xe1
       [<ffffffffffffffff>] 0xffffffffffffffff

other info that might help us debug this:

2 locks held by bash/3535:
 #0:  (&type->s_umount_key#17){----}, at: [<ffffffff810b5561>] drop_pagecache+0x3a/0xeb
 #1:  (inode_lock){--..}, at: [<ffffffff810b5574>] drop_pagecache+0x4d/0xeb

stack backtrace:

Call Trace:
 [<ffffffff81054369>] print_circular_bug_tail+0x69/0x72
 [<ffffffff8105479f>] print_circular_bug_header+0xcc/0xd3
 [<ffffffff81055f2b>] __lock_acquire+0x9cd/0xcf0
 [<ffffffff88023b58>] :jbd:journal_try_to_free_buffers+0x7e/0x131
 [<ffffffff810562d2>] lock_acquire+0x84/0xa8
 [<ffffffff88023b58>] :jbd:journal_try_to_free_buffers+0x7e/0x131
 [<ffffffff8125564a>] _spin_lock+0x1e/0x27
 [<ffffffff88023b58>] :jbd:journal_try_to_free_buffers+0x7e/0x131
 [<ffffffff810785db>] __invalidate_mapping_pages+0x81/0x103
 [<ffffffff810b559d>] drop_pagecache+0x76/0xeb
 [<ffffffff810b562c>] drop_caches_sysctl_handler+0x1a/0x2e
 [<ffffffff810d9407>] proc_sys_write+0x7c/0xa4
 [<ffffffff81099619>] vfs_write+0xc6/0x16f
 [<ffffffff81099bd6>] sys_write+0x45/0x6e
 [<ffffffff8100c05a>] tracesys+0xdc/0xe1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
