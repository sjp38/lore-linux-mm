Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 51C4D6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 02:39:02 -0500 (EST)
Date: Tue, 8 Nov 2011 15:38:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Problems with IO-less throttling?
Message-ID: <20111108073857.GA1363@localhost>
References: <20111107233657.GL15796@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111107233657.GL15796@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>

Hi Jan,

On Tue, Nov 08, 2011 at 07:36:57AM +0800, Jan Kara wrote:
>   Hello,
> 
>   today I was testing some patch with Linus' kernel from today (commit
> 31555213f03bca37d2c02e10946296052f4ecfcd)  and I rather easily tripped
> out-of-memory messages and processes got killed.
> 
> The unusual thing I'm doing is that I'm using user-mode-linux and
> the started virtual machine has relatively low amount of memory (I was
> tripping OOM immediately with mem=64M or mem=128M, I could still hit it
> after a while with mem=256M). The load I was running was just "dd
> if=/dev/zero of=/tmp/file bs=128k". The backing filesystem was ext3. Now
> with older kernel (e.g. 3.1) running even with mem=64M was fine.
> 
> Example of an OOM message:
> 
> dd invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0,
> oom_score_adj=0
> Call Trace: 
> 6ff5b868:  [<602f550d>] _raw_spin_unlock+0x9/0xb
> 6ff5b878:  [<6005ad53>] dump_header.clone.2+0xba/0x1b6
> 6ff5b8b8:  [<6005af77>] oom_kill_process.clone.0+0x45/0x236
> 6ff5b928:  [<6005b506>] out_of_memory+0x25c/0x305
> 6ff5b9a8:  [<6005e563>] __alloc_pages_nodemask+0x558/0x5fd
> 6ff5ba08:  [<60270a2b>] radix_tree_lookup_slot+0xe/0x10
> 6ff5ba88:  [<60065933>] shmem_getpage_gfp+0x269/0x475
> 6ff5bb18:  [<60065b72>] shmem_write_begin+0x33/0x35
> 6ff5bb28:  [<60059fa4>] generic_file_buffered_write+0x132/0x28f
> 6ff5bbf8:  [<6005a47a>] __generic_file_aio_write+0x379/0x3b5
> 6ff5bcb8:  [<6005a53a>] generic_file_aio_write+0x84/0xdd
> 6ff5bd28:  [<6007fb09>] do_sync_write+0xd1/0x10e
> 6ff5bdc8:  [<600174c1>] segv+0x8f/0x24a
> 6ff5be58:  [<6007fc0b>] vfs_write+0xc5/0x16d
> 6ff5be98:  [<6007fd64>] sys_write+0x45/0x6c
> 6ff5bed8:  [<60017e48>] handle_syscall+0x50/0x70
> 6ff5bef8:  [<60024ae6>] userspace+0x320/0x3d6
> 6ff5bfc8:  [<600151ac>] fork_handler+0x7d/0x84
> 
> Mem-Info:
> Normal per-cpu:
> CPU    0: hi:   90, btch:  15 usd:   0
> active_anon:850 inactive_anon:59583 isolated_anon:0
>  active_file:0 inactive_file:16 isolated_file:0
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:510 slab_reclaimable:540 slab_unreclaimable:461
>  mapped:0 shmem:59685 pagetables:111 bounce:0
> Normal free:2040kB min:2032kB low:2540kB high:3048kB active_anon:3400kB
> inactive_anon:238332kB active_file:0kB inactive_file:64kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:258560kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:0kB shmem:238740kB slab_reclaimable:2160kB

It looks most present pages are consumed by shmem/inactive_anon. Do
you have idea what's the shmem used for?

Thanks,
Fengguang

> slab_unreclaimable:1844kB kernel_stack:272kB pagetables:444kB unstable:0kB
> bounce:0kB writeback_tmp:0kB pages_scanned:46434 all_unreclaimable? yes
> lowmem_reserve[]: 0 0
> Normal: 498*4kB 4*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
> 0*2048kB 0*4096kB = 2040kB
> 59701 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 65536 pages RAM
> 3222 pages reserved
> 16 pages shared
> 61703 pages non-shared
> [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [  670]     0   670     1489       37   0       0             0 syslogd
> [  676]     0   676      682       21   0       0             0 klogd
> [  720]     0   720     5597       94   0       0             0 exim4
> [  725]     0   725      680       18   0       0             0 inetd
> [  739]     0   739     2282       36   0       0             0 atd
> [  745]     0   745     2890       47   0       0             0 cron
> [  762]     0   762     6338       75   0       0             0 login
> [  763]     0   763     6338       74   0       0             0 login
> [  764]     0   764     2593      131   0       0             0 bash
> [  772]     0   772     2590      129   0       0             0 bash
> [  805]     0   805     1262       58   0       0             0 dd
> Out of memory: Kill process 670 (syslogd) score 1 or sacrifice child
> Killed process 670 (syslogd) total-vm:5956kB, anon-rss:148kB, file-rss:0kB
> 
> I'd be suspecting new IO-less throttling code but from the OOM report it
> seems there are no dirty or writeback pages so that seems to speak against
> that theory.
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
