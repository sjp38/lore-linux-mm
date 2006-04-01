Date: Fri, 31 Mar 2006 16:22:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
In-Reply-To: <20060331160032.6e437226.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
 <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
 <20060331153235.754deb0c.akpm@osdl.org> <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
 <20060331160032.6e437226.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Mar 2006, Andrew Morton wrote:

> > A build server. Lots of scripts running, compilers etc etc.
> 
> Interesting.    Many CPUs?

12 processors. 6 nodes.

> A plain old sysrq-T would be great.  That'll tell us who owns iprune_sem,
> and what he's up to while holding it.  Actually five-odd sysrq-T's would be
> better.

Some traces:

   Stack traceback for pid 16836
        0xe00000380bc68000    16836        1  1    6   R  
        0xa00000020b8e6050 [xfs]xfs_iextract+0x190
        0xa00000020b8e63a0 [xfs]xfs_ireclaim+0x80
        0xa00000020b921c70 [xfs]xfs_finish_reclaim+0x330
        0xa00000020b921fa0 [xfs]xfs_reclaim+0x140
        0xa00000020b93f820 [xfs]linvfs_clear_inode+0x260
        0xa0000001001855f0 clear_inode+0x310
        0xa000000100185f70 dispose_list+0x90
        0xa000000100186c40 shrink_icache_memory+0x480
        0xa000000100105bb0 shrink_slab+0x290
        0xa000000100107cc0 try_to_free_pages+0x380
        0xa0000001000f9f70 __alloc_pages+0x330
        0xa0000001000ed940 page_cache_alloc_cold+0x160
        0xa0000001000fe3a0 __do_page_cache_readahead+0x120
        0xa0000001000fe820 blockable_page_cache_readahead+0xe0
        0xa0000001000fea50 make_ahead_window+0x150
        0xa0000001000fee30 page_cache_readahead+0x390
        0xa0000001000ee730 do_generic_mapping_read+0x190
        0xa0000001000efd80 __generic_file_aio_read+0x2c0
        0xa00000020b93c190 [xfs]xfs_read+0x3b0
        0xa00000020b934170 [xfs]linvfs_aio_read+0x130

        Stack traceback for pid 19357
        0xe000003815dc0000    19357    19108  0   10   D  
        0xa000000100524b80 schedule+0x2940
        0xa000000100521ee0 __down+0x260
        0xa000000100186880 shrink_icache_memory+0xc0
        0xa000000100105bb0 shrink_slab+0x290
        0xa000000100107cc0 try_to_free_pages+0x380
        0xa0000001000f9f70 __alloc_pages+0x330
        0xa00000010012e7d0 alloc_page_vma+0x150
        0xa0000001001108d0 __handle_mm_fault+0x390
        0xa00000010052c520 ia64_do_page_fault+0x280
        0xa00000010000caa0 ia64_leave_kernel
        0xa0000001000f29b0 file_read_actor+0xb0
        0xa0000001000ee830 do_generic_mapping_read+0x290
        0xa0000001000efd80 __generic_file_aio_read+0x2c0
        0xa00000020b93c190 [xfs]xfs_read+0x3b0
        0xa00000020b934170 [xfs]linvfs_aio_read+0x130
        0xa000000100146430 do_sync_read+0x170
        0xa000000100147f20 vfs_read+0x200
        0xa000000100148790 sys_read+0x70
        0xa00000010000c830 ia64_trace_syscall+0xd0

        Stack traceback for pid 12033
        0xe000003414cd0000    12033    18401  0   10   D  
        0xa000000100524b80 schedule+0x2940
        0xa000000100521ee0 __down+0x260
        0xa000000100186880 shrink_icache_memory+0xc0
        0xa000000100105bb0 shrink_slab+0x290
        0xa000000100107cc0 try_to_free_pages+0x380
        0xa0000001000f9f70 __alloc_pages+0x330
        0xa00000010012e7d0 alloc_page_vma+0x150
        0xa0000001001108d0 __handle_mm_fault+0x390
        0xa00000010052c520 ia64_do_page_fault+0x280
        0xa00000010000caa0 ia64_leave_kernel
        0xa0000001000f29b0 file_read_actor+0xb0
        0xa0000001000ee830 do_generic_mapping_read+0x290
        0xa0000001000efd80 __generic_file_aio_read+0x2c0
        0xa00000020b93c190 [xfs]xfs_read+0x3b0
        0xa00000020b934170 [xfs]linvfs_aio_read+0x130
        0xa000000100146430 do_sync_read+0x170
        0xa000000100147f20 vfs_read+0x200
        0xa000000100148790 sys_read+0x70
        0xa00000010000c830 ia64_trace_syscall+0xd0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
