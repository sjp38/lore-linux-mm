In-reply-to: <20070218155916.0d3c73a9.akpm@linux-foundation.org> (message from
	Andrew Morton on Sun, 18 Feb 2007 15:59:16 -0800)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org>
Message-Id: <E1HIwLJ-0005N4-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 01:25:21 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > If so, writes to B will decrease the dirty memory threshold.
> > 
> > Yes, but not by enough.  Say A dirties a 1100 pages, limit is 1000.
> > Some pages queued for writeback (doesn't matter how much).  B writes
> > back 1, 1099 dirty remain in A, zero in B.  balance_dirty_pages() for
> > B doesn't know that there's nothing more to write back for B, it's
> > just waiting there for those 1099, which'll never get written.
> 
> hm, OK, arguable.  I guess something like this..

Doesn't help the fuse case, but does seem to help the loopback mount
one.

For fuse it's worse with the patch: now the write triggered by the
balance recurses into fuse, with disastrous results, since the fuse
writeback is now blocked on the userspace queue.

fusexmp_fh_no D 40136678     0   505    494           506   504 (NOTLB)
08982b78 00000001 00000000 08f9f9b4 0805d8cb 089a75f8 08982b78 08f98000
       08f98000 08f9f9dc 0805a38a 089a7100 08982680 08f9f9cc 08f98000 08f98000
       085d8300 08982680 089a7100 08f9fa34 08183006 089a7100 08982680 089a7100 Call Trace:
08f9f9a0:  [<0805d8cb>] switch_to_skas+0x3b/0x83
08f9f9b8:  [<0805a38a>] _switch_to+0x49/0x99
08f9f9e0:  [<08183006>] schedule+0x246/0x547
08f9fa38:  [<08103c7e>] fuse_get_req_wp+0xe9/0x14a
08f9fa70:  [<08103d2e>] fuse_writepage+0x4f/0x12c
08f9faac:  [<0809ce3f>] __writepage+0x1e/0x3d
08f9fac0:  [<0809cd39>] write_cache_pages+0x222/0x30a
08f9fb44:  [<0809ce8d>] generic_writepages+0x2f/0x35
08f9fb5c:  [<0809ced6>] do_writepages+0x43/0x45
08f9fb70:  [<080cb8d2>] __writeback_single_inode+0xbc/0x173
08f9fbb8:  [<080cbb30>] sync_sb_inodes+0x1a7/0x260
08f9fbe8:  [<080cbc54>] writeback_inodes+0x6b/0x81
08f9fc04:  [<0809c640>] balance_dirty_pages+0x55/0x153
08f9fc5c:  [<0809c7bf>] balance_dirty_pages_ratelimited_nr+0x43/0x45
08f9fc68:  [<080992b5>] generic_file_buffered_write+0x3e3/0x6f5
08f9fd20:  [<0809988e>] __generic_file_aio_write_nolock+0x2c7/0x5dd
08f9fda8:  [<08099cb6>] generic_file_aio_write+0x55/0xc7
08f9fddc:  [<080ea206>] ext3_file_write+0x39/0xaf
08f9fe04:  [<080b060b>] do_sync_write+0xd8/0x10e
08f9febc:  [<080b06e3>] vfs_write+0xa2/0x1cb
08f9feec:  [<080b09b8>] sys_pwrite64+0x65/0x69
08f9ff10:  [<0805dd54>] handle_syscall+0x90/0xbc
08f9ff64:  [<0806d56c>] handle_trap+0x27/0x121
08f9ff8c:  [<0806dc65>] userspace+0x1de/0x226
08f9ffe4:  [<0805da19>] fork_handler+0x76/0x88
08f9fffc:  [<00000000>] nosmp+0xf7fb7000/0x14


> but where's pdflush?  It should be busily transferring dirtiness from A to
> B.

The transfer of dirtyness from A to B goes through the narrow channel
of i_mutex.  And once that is plugged by the stuck balance_dirty_pages()
nothing else can pass through.

> > > The writeout code _should_ just sit there transferring dirtyiness from A to
> > > B and cleaning pages via B, looping around, alternating between both.
> > > 
> > > What does sysrq-t say?
> > 
> > This is the fuse daemon thread that got stuck.
> 
> Where's pdflsuh?

Doing nothing I guess.  The request queue for the fuse filesystem is
full, so writepage with wbc->nonblocking=1 will be skipped.

pdflush       D 40045401     0    23      5            24    12 (L-TLB)
088d5bf8 00000001 00000000 08907df8 0805d8cb 088d55f8 088d5bf8 08900000
       08900000 08907e20 0805a38a 088d5100 088d5700 08907e10 08900000 08900000
       0847c300 088d5700 088d5100 08907e78 08182fe6 088d5100 088d5700 088d5100 Call Trace:
08907de4:  [<0805d8cb>] switch_to_skas+0x3b/0x83
08907dfc:  [<0805a38a>] _switch_to+0x49/0x99
08907e24:  [<08182fe6>] schedule+0x246/0x547
08907e7c:  [<08183a03>] schedule_timeout+0x4e/0xb6
08907eb0:  [<08183991>] io_schedule_timeout+0x11/0x20
08907eb8:  [<080a0cf2>] congestion_wait+0x72/0x87
08907ee8:  [<0809c860>] background_writeout+0x35/0xa4
08907f38:  [<0809d41e>] __pdflush+0xae/0x152
08907f54:  [<0809d4f5>] pdflush+0x33/0x39
08907f84:  [<0808a03a>] kthread+0xa7/0xab
08907fb4:  [<0806a0f1>] run_kernel_thread+0x41/0x50
08907fe0:  [<0805d975>] new_thread_handler+0x62/0x8b
08907ffc:  [<00000000>] nosmp+0xf7fb7000/0x14

pdflush       D 40045401     0    24      5            25    23 (L-TLB)
081e1458 00000001 00000000 088ffe00 0805d8cb 088d5bf8 081e1458 088f8000
       088f8000 088ffe28 0805a38a 088d5700 081e0f60 088ffe18 088f8000 088f8000
       0847c300 081e0f60 088d5700 088ffe80 08182fe6 088d5700 081e0f60 088d5700 Call Trace:
088ffdec:  [<0805d8cb>] switch_to_skas+0x3b/0x83
088ffe04:  [<0805a38a>] _switch_to+0x49/0x99
088ffe2c:  [<08182fe6>] schedule+0x246/0x547
088ffe84:  [<08183a03>] schedule_timeout+0x4e/0xb6
088ffeb8:  [<08183991>] io_schedule_timeout+0x11/0x20
088ffec0:  [<080a0cf2>] congestion_wait+0x72/0x87
088ffef0:  [<0809c98c>] wb_kupdate+0x93/0xd9
088fff38:  [<0809d41e>] __pdflush+0xae/0x152
088fff54:  [<0809d4f5>] pdflush+0x33/0x39
088fff84:  [<0808a03a>] kthread+0xa7/0xab
088fffb4:  [<0806a0f1>] run_kernel_thread+0x41/0x50
088fffe0:  [<0805d975>] new_thread_handler+0x62/0x8b
088ffffc:  [<00000000>] nosmp+0xf7fb7000/0x14

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
