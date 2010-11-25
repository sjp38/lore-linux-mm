Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5BA5A8D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 15:04:27 -0500 (EST)
Date: Thu, 25 Nov 2010 12:04:24 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Lock contention from flush processes for NFS mounts take all cpu
	[2.6.36, NFSv3]
Message-ID: <20101125200424.GA23598@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello!

I'm not sure what triggers this off, but at certain times, we see this on
shared hosting servers with storage over NFSv3:

top - 13:24:35 up 8 days,  6:47,  2 users,  load average: 69.23, 77.59, 85.53
Tasks: 1318 total,  11 running, 1303 sleeping,   0 stopped,   4 zombie
Cpu(s):  2.5%us, 96.6%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.9%si,  0.0%st
Mem:   4055836k total,  3746576k used,   309260k free,    39348k buffers
Swap:   979960k total,   104868k used,   875092k free,  1558432k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 5558 root      20   0     0    0    0 R   38  0.0  22:30.23 flush-0:58
 5683 root      20   0     0    0    0 R   38  0.0  53:06.24 flush-0:76
13076 root      20   0     0    0    0 R   38  0.0  30:03.96 flush-0:62
13265 mysql     20   0 1763m 128m 5632 S   38  3.3   8:21.47 mysqld                                                                                                                                              
25419 root      20   0     0    0    0 R   38  0.0  12:17.28 flush-0:38
 5783 root      20   0     0    0    0 R   32  0.0  43:32.78 flush-0:78
12725 root      20   0     0    0    0 R   32  0.0  29:45.53 flush-0:72
 5676 root      20   0     0    0    0 R   32  0.0  41:18.64 flush-0:82
24034 root      20   0     0    0    0 R   32  0.0  30:26.86 flush-0:32
32192 root      20   0     0    0    0 R   32  0.0  24:36.93 flush-0:81
 8465 root      20   0     0    0    0 R   31  0.0  19:26.43 flush-0:83
29379 root      20   0 30228 3076 1560 R    2  0.1   0:00.25 top

# cat /proc/5676/stack
[<ffffffff81203fed>] nfs_writepages+0xed/0x160
[<ffffffff8136b320>] _atomic_dec_and_lock+0x50/0x70
[<ffffffff8111ac3c>] iput+0x2c/0x2a0
[<ffffffff8112636e>] writeback_sb_inodes+0xce/0x150
[<ffffffff81126d1c>] writeback_inodes_wb+0xcc/0x140
[<ffffffff811270bb>] wb_writeback+0x32b/0x370
[<ffffffff811271d4>] wb_do_writeback+0xd4/0x1e0
[<ffffffff811273bb>] bdi_writeback_thread+0xdb/0x240
[<ffffffff81071ae6>] kthread+0x96/0xb0
[<ffffffff8100bd24>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

   PerfTop:    3894 irqs/sec  kernel:99.5%  exact:  0.0% [1000Hz cycles],  (all, 4 CPUs)
----------------------------------------------------------------------------------------

     samples  pcnt function                        DSO
     _______ _____ _______________________________ _________________

    25466.00 81.1% _raw_spin_lock                  [kernel.kallsyms]          
      968.00  3.1% nfs_writepages                  [kernel.kallsyms]          
      704.00  2.2% writeback_sb_inodes             [kernel.kallsyms]          
      671.00  2.1% writeback_single_inode          [kernel.kallsyms]          
      636.00  2.0% queue_io                        [kernel.kallsyms]          
      393.00  1.3% nfs_write_inode                 [kernel.kallsyms]          
      368.00  1.2% __iget                          [kernel.kallsyms]          
      360.00  1.1% iput                            [kernel.kallsyms]          
      334.00  1.1% bit_waitqueue                   [kernel.kallsyms]          
      293.00  0.9% do_writepages                   [kernel.kallsyms]          
      206.00  0.7% redirty_tail                    [kernel.kallsyms]          
      194.00  0.6% __mark_inode_dirty              [kernel.kallsyms]          
      135.00  0.4% _atomic_dec_and_lock            [kernel.kallsyms]          
      119.00  0.4% write_cache_pages               [kernel.kallsyms]          
       65.00  0.2% __wake_up_bit                   [kernel.kallsyms]          
       62.00  0.2% is_bad_inode                    [kernel.kallsyms]          
       41.00  0.1% find_get_pages_tag              [kernel.kallsyms]          
       37.00  0.1% radix_tree_gang_lookup_tag_slot [kernel.kallsyms]          
       29.00  0.1% wake_up_bit                     [kernel.kallsyms]          
       17.00  0.1% thread_group_cputime            [kernel.kallsyms]          
       16.00  0.1% pagevec_lookup_tag              [kernel.kallsyms]          
       16.00  0.1% radix_tree_tagged               [kernel.kallsyms]          
       16.00  0.1% _cond_resched                   [kernel.kallsyms]          
       14.00  0.0% ktime_get                       [kernel.kallsyms]          
       11.00  0.0% mapping_tagged                  [kernel.kallsyms]          
	9.00  0.0% nfs_pageio_init                 [kernel.kallsyms]          
	9.00  0.0% __phys_addr                     [kernel.kallsyms]          
	8.00  0.0% nfs_pageio_doio                 [kernel.kallsyms]          
	7.00  0.0% _raw_spin_lock_irqsave          [kernel.kallsyms]          
	7.00  0.0% dso__load_sym                   /usr/local/bin/perf        

# grep ^nr_ /proc/vmstat
nr_free_pages 123806
nr_inactive_anon 52656
nr_active_anon 192039
nr_inactive_file 351876
nr_active_file 92993
nr_unevictable 0
nr_mlock 0
nr_anon_pages 234118
nr_mapped 4652
nr_file_pages 457325
nr_dirty 211
nr_writeback 0
nr_slab_reclaimable 79296
nr_slab_unreclaimable 45221
nr_page_table_pages 57483
nr_kernel_stack 2537
nr_unstable 0
nr_bounce 0
nr_vmscan_write 3387227
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 144

Looking up flush-major:minor in /proc/self/mountinfo shows that these are
all NFS mounts from a few different servers.  It doesn't seem like there
are any large write sor anything going on at this moment -- no processes
are in D state.  I started a "sync", which ran for another 10 minutes or
so, and then finally exited, and everything returned to normal.

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
