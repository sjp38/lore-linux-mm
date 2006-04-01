Date: Fri, 31 Mar 2006 17:25:18 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-Id: <20060331172518.40a5b03d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
	<20060331150120.21fad488.akpm@osdl.org>
	<Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
	<20060331153235.754deb0c.akpm@osdl.org>
	<Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
	<20060331160032.6e437226.akpm@osdl.org>
	<Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
>  Some traces:
> 
>     Stack traceback for pid 16836
>          0xe00000380bc68000    16836        1  1    6   R  
>          0xa00000020b8e6050 [xfs]xfs_iextract+0x190
>          0xa00000020b8e63a0 [xfs]xfs_ireclaim+0x80
>          0xa00000020b921c70 [xfs]xfs_finish_reclaim+0x330
>          0xa00000020b921fa0 [xfs]xfs_reclaim+0x140
>          0xa00000020b93f820 [xfs]linvfs_clear_inode+0x260
>          0xa0000001001855f0 clear_inode+0x310
>          0xa000000100185f70 dispose_list+0x90
>          0xa000000100186c40 shrink_icache_memory+0x480
>          0xa000000100105bb0 shrink_slab+0x290
>          0xa000000100107cc0 try_to_free_pages+0x380
>          0xa0000001000f9f70 __alloc_pages+0x330
>          0xa0000001000ed940 page_cache_alloc_cold+0x160
>          0xa0000001000fe3a0 __do_page_cache_readahead+0x120
>          0xa0000001000fe820 blockable_page_cache_readahead+0xe0
>          0xa0000001000fea50 make_ahead_window+0x150
>          0xa0000001000fee30 page_cache_readahead+0x390
>          0xa0000001000ee730 do_generic_mapping_read+0x190
>          0xa0000001000efd80 __generic_file_aio_read+0x2c0
>          0xa00000020b93c190 [xfs]xfs_read+0x3b0
>          0xa00000020b934170 [xfs]linvfs_aio_read+0x130

OK, thanks.   Is that a typical trace?

It appears that we're being busy in xfs_iextract(), but it would be sad if
the problem was really lock contention in xfs_iextract(), and we just
happened to catch it when it was running.

Or maybe xfs_iextract is just slow.  So this is one thing we need to get to
the bottom of (profiles might tell us).

Assuming that there's nothing we can do to improve the XFS situation, our
options appear to be, in order of preference:

a) move some/all of dispose_list() outside iprune_mutex.

b) make iprune_mutex an rwlock, take it for reading around
   dispose_list(), for writing elsewhere.

c) go back to single-threading shrink_slab (or just shrink_icache_memory())

   For this one we'd need to understand which observations prompted Nick
   to make shrinker_rwsem an rwsem?


We also need to understand why this has become worse.  Perhaps xfs_iextract
got slower (cc's Nathan).  Do you have any idea whenabout in kernel history
this started happening?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
