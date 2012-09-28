Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id ACB786B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:14:33 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so3821844obc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 08:14:33 -0700 (PDT)
Date: Fri, 28 Sep 2012 10:14:30 -0500
From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: mlx4_en_alloc_frag allocation failures
Message-ID: <20120928151429.GB2731@BohrerMBP.rgmadvisors.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

We've got a new application that is receiving UDP multicast data using
AF_PACKET and writing out the packets in a custom format to disk.  The
packet rates are bursty, but it seems to be roughly 100 Mbps on
average for 1 minute periods.  With this application running all day
we get a lot of these messages:

[1298269.103034] kswapd1: page allocation failure: order:2, mode:0x4020
[1298269.103038] Pid: 80, comm: kswapd1 Not tainted 3.4.9-2.rgm.fc16.x86_64 #1
[1298269.103040] Call Trace:
[1298269.103041]  <IRQ>  [<ffffffff810db746>] warn_alloc_failed+0xf6/0x160
[1298269.103053]  [<ffffffff813c767d>] ? skb_copy_bits+0x16d/0x2c0
[1298269.103058]  [<ffffffff810e83a9>] ? wakeup_kswapd+0x69/0x160
[1298269.103060]  [<ffffffff810df188>] __alloc_pages_nodemask+0x6e8/0x930
[1298269.103064]  [<ffffffff81114316>] alloc_pages_current+0xb6/0x120
[1298269.103070]  [<ffffffffa00c142b>] mlx4_en_alloc_frag+0x16b/0x1e0 [mlx4_en]
[1298269.103073]  [<ffffffffa00c18a0>] mlx4_en_complete_rx_desc+0x120/0x1d0 [mlx4_en]
[1298269.103076]  [<ffffffffa00c27d4>] mlx4_en_process_rx_cq+0x584/0x700 [mlx4_en]
[1298269.103079]  [<ffffffffa00c29ef>] mlx4_en_poll_rx_cq+0x3f/0x80 [mlx4_en]
[1298269.103083]  [<ffffffff813d6569>] net_rx_action+0x119/0x210
[1298269.103086]  [<ffffffff8103c690>] __do_softirq+0xb0/0x220
[1298269.103090]  [<ffffffff8109911d>] ? handle_irq_event+0x4d/0x70
[1298269.103095]  [<ffffffff8148e30c>] call_softirq+0x1c/0x30
[1298269.103100]  [<ffffffff81003ef5>] do_softirq+0x55/0x90
[1298269.103101]  [<ffffffff8103ca65>] irq_exit+0x75/0x80
[1298269.103103]  [<ffffffff8148e853>] do_IRQ+0x63/0xe0
[1298269.103107]  [<ffffffff81485667>] common_interrupt+0x67/0x67
[1298269.103108]  <EOI>  [<ffffffff8148523f>] ? _raw_spin_unlock_irqrestore+0xf/0x20
[1298269.103113]  [<ffffffff811184b1>] compaction_alloc+0x361/0x3f0
[1298269.103115]  [<ffffffff810e29b7>] ? pagevec_lru_move_fn+0xd7/0xf0
[1298269.103118]  [<ffffffff81123d19>] migrate_pages+0xa9/0x470
[1298269.103120]  [<ffffffff81118150>] ? perf_trace_mm_compaction_migratepages+0xd0/0xd0
[1298269.103122]  [<ffffffff81118abb>] compact_zone+0x4cb/0x910
[1298269.103124]  [<ffffffff8111904b>] __compact_pgdat+0x14b/0x190
[1298269.103125]  [<ffffffff8111931d>] compact_pgdat+0x2d/0x30
[1298269.103129]  [<ffffffff810f32b9>] ? fragmentation_index+0x19/0x70
[1298269.103131]  [<ffffffff810eb15f>] balance_pgdat+0x6ef/0x710
[1298269.103133]  [<ffffffff810eb2ca>] kswapd+0x14a/0x390
[1298269.103136]  [<ffffffff810567c0>] ? add_wait_queue+0x60/0x60
[1298269.103138]  [<ffffffff810eb180>] ? balance_pgdat+0x710/0x710
[1298269.103140]  [<ffffffff81055e93>] kthread+0x93/0xa0
[1298269.103142]  [<ffffffff8148e214>] kernel_thread_helper+0x4/0x10
[1298269.103144]  [<ffffffff81055e00>] ? kthread_worker_fn+0x140/0x140
[1298269.103146]  [<ffffffff8148e210>] ? gs_change+0xb/0xb

The kernel is based on a Fedora 16 kernel and actually has the 3.4.10
patches applied.  I can easily test patches or different kernels.

I'm mostly wondering if there is anything that can be done about these
failures?  It appears that these failures have to do with handling
fragmented IP frames, but the majority of the packets this machines
should not be fragmented (there are probably some that are).

>From a memory management point of view the system has 48GB of RAM, and
typically 44GB of that is page cache.  The dirty pages seem to hover
around 5-6MB and the filesystem/disks don't seem to have any problems
keeping up with writing out the data.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
