Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A193F6B0099
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:30:08 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBG5DMGQ022484
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:13:22 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E6E6D4DE8042
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:27:54 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBG5U2bC336942
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:30:02 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBG5U06a023193
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:30:02 -0500
Date: Wed, 15 Dec 2010 21:29:58 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: linux-next early user mode crash (Was: Re: Transparent
 Hugepage Support #33)
Message-ID: <20101216052958.GA2161@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20101215051540.GP5638@random.random>
 <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
 <20101215171809.0e0bc3d5.akpm@linux-foundation.org>
 <20101216130251.12dbe8d8.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101216130251.12dbe8d8.sfr@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 01:02:51PM +1100, Stephen Rothwell wrote:
> Hi Andrew,
> 
> On Wed, 15 Dec 2010 17:18:09 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > That might take a while - linux-next is a screwed-up catastrophe and I
> > suppose some sucker has some bisecting to do.
> 
> Yeah, all 6 of my boot tests failed last night.  This from a machine with
> 2G of memory (early after starting user mode):
> 
> pidof invoked oom-killer: gfp_mask=0x840d0, order=0, oom_adj=0, oom_score_adj=0
> pidof cpuset=/ mems_allowed=0
> Call Trace:
> [c000000001c62fc0] [c000000000012214] .show_stack+0x7c/0x184 (unreliable)
> [c000000001c63070] [c000000000129380] .dump_header.clone.2+0xd0/0x230
> [c000000001c63170] [c00000000012955c] .oom_kill_process.clone.0+0x7c/0x304
> [c000000001c63250] [c000000000129c78] .out_of_memory+0x494/0x54c
> [c000000001c63340] [c00000000012ecb8] .__alloc_pages_nodemask+0x550/0x714
> [c000000001c634c0] [c0000000001690f8] .alloc_pages_current+0xc4/0x104
> [c000000001c63560] [c00000000016ea70] .new_slab+0xdc/0x2c8
> [c000000001c63600] [c00000000016ef5c] .__slab_alloc+0x300/0x484
> [c000000001c636d0] [c000000000170754] .kmem_cache_alloc+0x88/0x17c
> [c000000001c63780] [c0000000001db3b4] .proc_alloc_inode+0x30/0xa8
> [c000000001c63820] [c000000000196fe8] .alloc_inode+0x48/0xf8
> [c000000001c638b0] [c0000000001974e0] .new_inode+0x28/0xa8
> [c000000001c63930] [c0000000001dd0e8] .proc_pid_make_inode+0x24/0xe8
> [c000000001c639d0] [c0000000001e0980] .proc_pid_instantiate+0x2c/0x104
> [c000000001c63a60] [c0000000001dca1c] .proc_fill_cache+0x104/0x1f4
> [c000000001c63b40] [c0000000001e1180] .proc_pid_readdir+0x134/0x228
> [c000000001c63c30] [c0000000001dc2a8] .proc_root_readdir+0x58/0x78
> [c000000001c63cc0] [c00000000018d778] .vfs_readdir+0xa4/0x108
> [c000000001c63d70] [c00000000018d964] .SyS_getdents+0x84/0x128
> [c000000001c63e30] [c000000000008628] syscall_exit+0x0/0x40
> Mem-Info:
> Node 0 DMA per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  24
> CPU    1: hi:  186, btch:  31 usd:  60
> active_anon:204 inactive_anon:15 isolated_anon:0
>  active_file:0 inactive_file:0 isolated_file:0
>  unevictable:7032 dirty:0 writeback:0 unstable:0
>  free:1425 slab_reclaimable:34092 slab_unreclaimable:309770
>  mapped:380 shmem:19 pagetables:20 bounce:0
> Node 0 DMA free:5700kB min:5752kB low:7188kB high:8628kB active_anon:816kB inactive_anon:60kB active_file:0kB inactive_file:0kB unevictable:28128kB isolated(anon):0kB isolated(file):0kB present:2068480kB mlocked:0kB dirty:0kB writeback:0kB mapped:1520kB shmem:76kB slab_reclaimable:136368kB slab_unreclaimable:1239080kB kernel_stack:612912kB pagetables:80kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:14 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Node 0 DMA: 81*4kB 84*8kB 36*16kB 15*32kB 11*64kB 23*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB = 5700kB
> 7072 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 524288 pages RAM
> 15987 pages reserved
> 623 pages shared
> 391424 pages non-shared
> [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [ 1913]     0  1913     1290      365   1       0             0 plymouthd
> [ 7152]     0  7152      617      144   1       0             0 pidof
> Out of memory: Kill process 1913 (plymouthd) score 1 or sacrifice child
> Killed process 1913 (plymouthd) total-vm:5160kB, anon-rss:392kB, file-rss:1068kB
> 
> it went on to say this:
> 
> Kernel panic - not syncing: Out of memory and no killable processes...
> 
> Next-20101214 booted fine.

RCU problems would normally take longer to run the system out of memory,
but who knows?

I did a push into -rcu in the suspect time frame, so have pulled it.  I am
sure that kernel.org will push this change to its mirrors at some point.
Just in case tree-by-tree bisecting is faster than commit-by-commit
bisecting.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
