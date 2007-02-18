In-reply-to: <20070218145929.547c21c7.akpm@linux-foundation.org> (message from
	Andrew Morton on Sun, 18 Feb 2007 14:59:29 -0800)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu> <20070218145929.547c21c7.akpm@linux-foundation.org>
Message-Id: <E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 19 Feb 2007 00:22:11 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > I was testing the new fuse shared writable mmap support, and finding
> > > > that bash-shared-mapping deadlocks (which isn't so strange ;).  What
> > > > is more strange is that this is not an OOM situation at all, with
> > > > plenty of free and cached pages.
> > > > 
> > > > A little more investigation shows that a similar deadlock happens
> > > > reliably with bash-shared-mapping on a loopback mount, even if only
> > > > half the total memory is used.
> > > > 
> > > > The cause is slightly different in the two cases:
> > > > 
> > > >   - loopback mount: allocation by the underlying filesystem is stalled
> > > >     on throttle_vm_writeout()
> > > > 
> > > >   - fuse-loop: page dirtying on the underlying filesystem is stalled on
> > > >     balance_dirty_pages()
> > > > 
> > > > In both cases the underlying fs is totally innocent, with no
> > > > dirty/writback pages, yet it's waiting for the global dirty+writeback
> > > > to go below the threshold, which obviously won't, until the
> > > > allocation/dirtying succeeds.
> > > > 
> > > > I'm not quite sure what the solution is, and asking for thoughts.
> > > 
> > > But....  these things don't just throttle.  They also perform large amounts
> > > of writeback, which causes the dirty levels to subside.
> > > 
> > > >From your description it appears that this writeback isn't happening, or
> > > isn't working.  How come?
> > 
> >  - filesystems A and B
> >  - write to A will end up as write to B
> >  - dirty pages in A manage to go over dirty_threshold
> >  - page writeback is started from A
> >  - this triggers writeback for a couple of pages in B
> >  - writeback finishes normally, but dirty+writeback pages are still
> >    over threshold
> >  - balance_dirty_pages in B gets stuck, nothing ever moves after this
> > 
> > At least this is my theory for what happens.
> > 
> 
> Is B a real filesystem?

Yes.

> If so, writes to B will decrease the dirty memory threshold.

Yes, but not by enough.  Say A dirties a 1100 pages, limit is 1000.
Some pages queued for writeback (doesn't matter how much).  B writes
back 1, 1099 dirty remain in A, zero in B.  balance_dirty_pages() for
B doesn't know that there's nothing more to write back for B, it's
just waiting there for those 1099, which'll never get written.

> The writeout code _should_ just sit there transferring dirtyiness from A to
> B and cleaning pages via B, looping around, alternating between both.
> 
> What does sysrq-t say?

This is the fuse daemon thread that got stuck.  There are lots of
others that are stuck on some ext3 mutex as a result of this.

fusexmp_fh_no D 40045401     0   527    493           533   495 (NOTLB)
088d55f8 00000001 00000000 08dcfb14 0805d8cb 08a09b78 088d55f8 08dc8000
       08dc8000 08dcfb3c 0805a38a 08a09680 088d5100 08dcfb2c 08dc8000 08dc8000
       0847c300 088d5100 08a09680 08dcfb94 08182fe6 08a09680 088d5100 08a09680 Call Trace:
08dcfb00:  [<0805d8cb>] switch_to_skas+0x3b/0x83
08dcfb18:  [<0805a38a>] _switch_to+0x49/0x99
08dcfb40:  [<08182fe6>] schedule+0x246/0x547
08dcfb98:  [<08183a03>] schedule_timeout+0x4e/0xb6
08dcfbcc:  [<08183991>] io_schedule_timeout+0x11/0x20
08dcfbd4:  [<080a0cf2>] congestion_wait+0x72/0x87
08dcfc04:  [<0809c693>] balance_dirty_pages+0xa8/0x153
08dcfc5c:  [<0809c7bf>] balance_dirty_pages_ratelimited_nr+0x43/0x45
08dcfc68:  [<080992b5>] generic_file_buffered_write+0x3e3/0x6f5
08dcfd20:  [<0809988e>] __generic_file_aio_write_nolock+0x2c7/0x5dd
08dcfda8:  [<08099cb6>] generic_file_aio_write+0x55/0xc7
08dcfddc:  [<080ea1e6>] ext3_file_write+0x39/0xaf
08dcfe04:  [<080b060b>] do_sync_write+0xd8/0x10e
08dcfebc:  [<080b06e3>] vfs_write+0xa2/0x1cb
08dcfeec:  [<080b09b8>] sys_pwrite64+0x65/0x69
08dcff10:  [<0805dd54>] handle_syscall+0x90/0xbc
08dcff64:  [<0806d56c>] handle_trap+0x27/0x121
08dcff8c:  [<0806dc65>] userspace+0x1de/0x226
08dcffe4:  [<0805da19>] fork_handler+0x76/0x88
08dcfffc:  [<d4cf0007>] 0xd4cf0007

/proc/vmstat:

nr_anon_pages 668
nr_mapped 3168
nr_file_pages 5191
nr_slab_reclaimable 173
nr_slab_unreclaimable 494
nr_page_table_pages 65
nr_dirty 2174
nr_writeback 10
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
pgpgin 10955
pgpgout 421091
pswpin 0
pswpout 0
pgalloc_dma 0
pgalloc_normal 268761
pgfree 269709
pgactivate 128287
pgdeactivate 31253
pgfault 237350
pgmajfault 4340
pgrefill_dma 0
pgrefill_normal 127899
pgsteal_dma 0
pgsteal_normal 46892
pgscan_kswapd_dma 0
pgscan_kswapd_normal 47104
pgscan_direct_dma 0
pgscan_direct_normal 36544
pginodesteal 0
slabs_scanned 2048
kswapd_steal 25083
kswapd_inodesteal 335
pageoutrun 656
allocstall 423
pgrotated 0

Breakpoint 3, balance_dirty_pages (mapping=0xa01feb0)
    at mm/page-writeback.c:202
202                             dirty_exceeded = 1;
(gdb) p dirty_thresh
$1 = 2113
(gdb)

For completeness' sake, here's the backtrace for the stuck loopback as
well:

loop0         D BFFFE101     0   499      5           500    59 (L-TLB)
088cc578 00000001 00000000 09197c4c 0805d8cb 084fe6f8 088cc578 09190000
       09190000 09197c74 0805a38a 084fe200 088cc080 09197c64 09190000 09190000
       086d9c80 088cc080 084fe200 09197ccc 08182ab6 084fe200 088cc080 084fe200 Call Trace:
09197c38:  [<0805d8cb>] switch_to_skas+0x3b/0x83
09197c50:  [<0805a38a>] _switch_to+0x49/0x99
09197c78:  [<08182ab6>] schedule+0x246/0x547
09197cd0:  [<081834d3>] schedule_timeout+0x4e/0xb6
09197d04:  [<08183461>] io_schedule_timeout+0x11/0x20
09197d0c:  [<080a0c62>] congestion_wait+0x72/0x87
09197d3c:  [<0809c7e8>] throttle_vm_writeout+0x27/0x6a
09197d60:  [<0809faec>] shrink_zone+0xaf/0x103
09197d8c:  [<0809fbb2>] shrink_zones+0x72/0x8a
09197db0:  [<0809fc87>] try_to_free_pages+0xbd/0x185
09197dfc:  [<0809ba76>] __alloc_pages+0x155/0x335
09197e50:  [<080975eb>] find_or_create_page+0x85/0x99
09197e78:  [<0812785e>] do_lo_send_aops+0x8d/0x233
09197ee4:  [<08127c56>] lo_send+0x92/0x10d
09197f20:  [<08127ee6>] do_bio_filebacked+0x6d/0x74
09197f44:  [<081280e0>] loop_thread+0x89/0x188
09197f84:  [<0808a03a>] kthread+0xa7/0xab
09197fb4:  [<0806a0f1>] run_kernel_thread+0x41/0x50
09197fe0:  [<0805d975>] new_thread_handler+0x62/0x8b
09197ffc:  [<00000000>] nosmp+0xf7fb7000/0x14

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
