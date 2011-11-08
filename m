Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAE76B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 08:19:38 -0500 (EST)
Date: Tue, 8 Nov 2011 14:19:32 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with IO-less throttling?
Message-ID: <20111108131932.GA9658@quack.suse.cz>
References: <20111107233657.GL15796@quack.suse.cz>
 <20111108073857.GA1363@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111108073857.GA1363@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>

  Hello Fengguang,

On Tue 08-11-11 15:38:57, Wu Fengguang wrote:
> On Tue, Nov 08, 2011 at 07:36:57AM +0800, Jan Kara wrote:
> >   today I was testing some patch with Linus' kernel from today (commit
> > 31555213f03bca37d2c02e10946296052f4ecfcd)  and I rather easily tripped
> > out-of-memory messages and processes got killed.
> > 
> > The unusual thing I'm doing is that I'm using user-mode-linux and
> > the started virtual machine has relatively low amount of memory (I was
> > tripping OOM immediately with mem=64M or mem=128M, I could still hit it
> > after a while with mem=256M). The load I was running was just "dd
> > if=/dev/zero of=/tmp/file bs=128k". The backing filesystem was ext3. Now
> > with older kernel (e.g. 3.1) running even with mem=64M was fine.
> > 
> > Example of an OOM message:
> > 
> > dd invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0,
> > oom_score_adj=0
> > Call Trace: 
> > 6ff5b868:  [<602f550d>] _raw_spin_unlock+0x9/0xb
> > 6ff5b878:  [<6005ad53>] dump_header.clone.2+0xba/0x1b6
> > 6ff5b8b8:  [<6005af77>] oom_kill_process.clone.0+0x45/0x236
> > 6ff5b928:  [<6005b506>] out_of_memory+0x25c/0x305
> > 6ff5b9a8:  [<6005e563>] __alloc_pages_nodemask+0x558/0x5fd
> > 6ff5ba08:  [<60270a2b>] radix_tree_lookup_slot+0xe/0x10
> > 6ff5ba88:  [<60065933>] shmem_getpage_gfp+0x269/0x475
> > 6ff5bb18:  [<60065b72>] shmem_write_begin+0x33/0x35
> > 6ff5bb28:  [<60059fa4>] generic_file_buffered_write+0x132/0x28f
> > 6ff5bbf8:  [<6005a47a>] __generic_file_aio_write+0x379/0x3b5
> > 6ff5bcb8:  [<6005a53a>] generic_file_aio_write+0x84/0xdd
> > 6ff5bd28:  [<6007fb09>] do_sync_write+0xd1/0x10e
> > 6ff5bdc8:  [<600174c1>] segv+0x8f/0x24a
> > 6ff5be58:  [<6007fc0b>] vfs_write+0xc5/0x16d
> > 6ff5be98:  [<6007fd64>] sys_write+0x45/0x6c
> > 6ff5bed8:  [<60017e48>] handle_syscall+0x50/0x70
> > 6ff5bef8:  [<60024ae6>] userspace+0x320/0x3d6
> > 6ff5bfc8:  [<600151ac>] fork_handler+0x7d/0x84
> > 
> > Mem-Info:
> > Normal per-cpu:
> > CPU    0: hi:   90, btch:  15 usd:   0
> > active_anon:850 inactive_anon:59583 isolated_anon:0
> >  active_file:0 inactive_file:16 isolated_file:0
> >  unevictable:0 dirty:0 writeback:0 unstable:0
> >  free:510 slab_reclaimable:540 slab_unreclaimable:461
> >  mapped:0 shmem:59685 pagetables:111 bounce:0
> > Normal free:2040kB min:2032kB low:2540kB high:3048kB active_anon:3400kB
> > inactive_anon:238332kB active_file:0kB inactive_file:64kB unevictable:0kB
> > isolated(anon):0kB isolated(file):0kB present:258560kB mlocked:0kB
> > dirty:0kB writeback:0kB mapped:0kB shmem:238740kB slab_reclaimable:2160kB
> 
> It looks most present pages are consumed by shmem/inactive_anon. Do
> you have idea what's the shmem used for?
  Hmm, I must have messed up something during my testing. It looks as if I
was writing to some tmpfs filesystem instead of the test filesystem I
wanted to use (and that brought the system OOM). Now when I use the right
filesystem, I'm not able to hit the OOM anymore. So sorry for the noise.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
