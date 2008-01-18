Date: Fri, 18 Jan 2008 12:54:52 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080118195451.GE20490@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com> <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 02:01:08PM -0800, Christoph Lameter wrote:
> Dec 6th? I was on vacation then and it seems that I was unable to 
> reproduce the oopses. Can I get some backtraces or other information 
> that would allow me to diagnose the problem?

I've found one backtrace which seems to be relevant.  I believe this is
due to 8/10.

I don't think the kernel for this run was saved, so we'll have to do a
new run if you need more information than this.

general protection fault: 0000 [1] SMP
CPU 5
Modules linked in: qla2xxx scsi_transport_fc ipv6 dm_mirror dm_multipath dm_mod button ehci_hcd uhci_hcd i2c_i801 i2c_core r
ng_core e1000 floppy ext3 jbd raid1 aic79xx scsi_transport_spi ata_piix ahci libata sd_mod scsi_mod
Pid: 22541, comm: oracle Not tainted 2.6.24-rc1-slub2 #3
RIP: 0010:[<ffffffff80287d2f>]  [<ffffffff80287d2f>] kmem_cache_alloc+0x3f/0x69
RSP: 0018:ffff81006d551b38  EFLAGS: 00010046
RAX: 0000000000000000 RBX: ffff810001084d40 RCX: ffffffff80267faf
RDX: 00ffff8100745818 RSI: 0000000000011220 RDI: ffffffff805b2240
RBP: 0000000000011220 R08: 0000000000000000 R09: ffff8100745e8a80
R10: 0000000000000086 R11: ffffffff88008014 R12: 0000000000000000
R13: 0000000000011220 R14: 0000000000011220 R15: 0000000000000001
FS:  00002b0b43b53c60(0000) GS:ffff81010609d880(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000f56626ff0 CR3: 000000006d4e4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process oracle (pid: 22541, threadinfo ffff81006d550000, task ffff810069c3c790)
Stack:  0000000000000000 ffff8100745e8a80 ffff810109979300 ffffffff80267faf
 ffff810106198000 ffffffff8023df1d 0000000000000000 ffff81010bdeee88
 0000000000000086 0000000000000086 ffff8100745e8a80 0000000000000000
Call Trace:
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff8023df1d>] lock_timer_base+0x24/0x49
 [<ffffffff88007550>] :scsi_mod:scsi_alloc_sgtable+0xb6/0x19c
 [<ffffffff88007b35>] :scsi_mod:scsi_init_io+0x26/0xda
 [<ffffffff8802c2ab>] :sd_mod:sd_prep_fn+0x70/0x782
 [<ffffffff80304cee>] elv_next_request+0xed/0x13a
 [<ffffffff88008014>] :scsi_mod:scsi_request_fn+0x0/0x362
 [<ffffffff8800808b>] :scsi_mod:scsi_request_fn+0x77/0x362
 [<ffffffff8030678f>] generic_unplug_device+0x18/0x25
 [<ffffffff802b289d>] __blockdev_direct_IO+0x851/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83


Code: 48 8b 34 c2 48 89 d0 48 0f b1 33 48 39 d0 75 ce 81 e5 00 80
RIP  [<ffffffff80287d2f>] kmem_cache_alloc+0x3f/0x69
 RSP <ffff81006d551b38>
BUG: sleeping function called from invalid context at kernel/rwsem.c:20
in_atomic():0, irqs_disabled():1

Call Trace:
 [<ffffffff8022aedd>] __might_sleep+0xb5/0xb7
 [<ffffffff8024b41d>] down_read+0x15/0x1e
 [<ffffffff80257c59>] acct_collect+0x40/0x17d
 [<ffffffff80238712>] do_exit+0x209/0x77d
 [<ffffffff8020cdbf>] do_divide_error+0x0/0x89
 [<ffffffff804649b9>] error_exit+0x0/0x51
 [<ffffffff88008014>] :scsi_mod:scsi_request_fn+0x0/0x362
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff80287d2f>] kmem_cache_alloc+0x3f/0x69
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff8023df1d>] lock_timer_base+0x24/0x49
 [<ffffffff88007550>] :scsi_mod:scsi_alloc_sgtable+0xb6/0x19c
 [<ffffffff88007b35>] :scsi_mod:scsi_init_io+0x26/0xda
 [<ffffffff8802c2ab>] :sd_mod:sd_prep_fn+0x70/0x782
 [<ffffffff80304cee>] elv_next_request+0xed/0x13a
 [<ffffffff88008014>] :scsi_mod:scsi_request_fn+0x0/0x362
 [<ffffffff8800808b>] :scsi_mod:scsi_request_fn+0x77/0x362
 [<ffffffff8030678f>] generic_unplug_device+0x18/0x25
 [<ffffffff802b289d>] __blockdev_direct_IO+0x851/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83

general protection fault: 0000 [2] SMP
CPU 5
Modules linked in: qla2xxx scsi_transport_fc ipv6 dm_mirror dm_multipath dm_mod button ehci_hcd uhci_hcd i2c_i801 i2c_core r
ng_core e1000 floppy ext3 jbd raid1 aic79xx scsi_transport_spi ata_piix ahci libata sd_mod scsi_mod
Pid: 22541, comm: oracle Tainted: G      D 2.6.24-rc1-slub2 #3
RIP: 0010:[<ffffffff80287cc6>]  [<ffffffff80287cc6>] kmem_cache_alloc_node+0x46/0x70
RSP: 0018:ffff8101061a7e50  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff810001084d40 RCX: ffffffff803f3f43
RDX: 00000000ffffffff RSI: 00ffff8100745818 RDI: ffffffff805b2240
RBP: 0000000000000020 R08: 0000000000000005 R09: 000000000000b031
R10: ffff81006d5518f8 R11: ffff81006c14caa0 R12: 00000000000000e0
R13: ffffffff805b2240 R14: 0000000000000020 R15: 0000000000000001
FS:  00002b0b43b53c60(0000) GS:ffff81010609d880(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000f56626ff0 CR3: 000000006d4e4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process oracle (pid: 22541, threadinfo ffff81006d550000, task ffff810069c3c790)
Stack:  00000000ffffffff ffff81006c17e000 00000000ffffffff ffffffff803f3f43
 0000000000000005 ffff81006c17e000 ffff810106198000 0000000000000100
 ffffffff80431824 ffff8101061a7ee0 0000000000000001 ffffffff8043125a
Call Trace:
 <IRQ>  [<ffffffff803f3f43>] __alloc_skb+0x36/0x12a
 [<ffffffff80431824>] tcp_delack_timer+0x0/0x1e2
 [<ffffffff8043125a>] tcp_send_ack+0x24/0xfe
 [<ffffffff804319a9>] tcp_delack_timer+0x185/0x1e2
 [<ffffffff8023e307>] run_timer_softirq+0x156/0x1ac
 [<ffffffff8023aa61>] __do_softirq+0x50/0xbb
 [<ffffffff8020c7ac>] call_softirq+0x1c/0x28
 [<ffffffff8020ddb8>] do_softirq+0x2e/0x96
 [<ffffffff8021f28c>] smp_apic_timer_interrupt+0x3e/0x51
 [<ffffffff8020c256>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff8032dcb2>] vgacon_cursor+0x0/0x1b1
 [<ffffffff804647c1>] _spin_unlock_irq+0x9/0xa
 [<ffffffff804641fc>] __down_read+0x34/0x9e
 [<ffffffff8022aedd>] __might_sleep+0xb5/0xb7
 [<ffffffff80257c59>] acct_collect+0x40/0x17d
 [<ffffffff80238712>] do_exit+0x209/0x77d
 [<ffffffff8020cdbf>] do_divide_error+0x0/0x89
 [<ffffffff804649b9>] error_exit+0x0/0x51
 [<ffffffff88008014>] :scsi_mod:scsi_request_fn+0x0/0x362
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff80287d2f>] kmem_cache_alloc+0x3f/0x69
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff8023df1d>] lock_timer_base+0x24/0x49
 [<ffffffff88007550>] :scsi_mod:scsi_alloc_sgtable+0xb6/0x19c
 [<ffffffff88007b35>] :scsi_mod:scsi_init_io+0x26/0xda
 [<ffffffff8802c2ab>] :sd_mod:sd_prep_fn+0x70/0x782
 [<ffffffff80304cee>] elv_next_request+0xed/0x13a
 [<ffffffff88008014>] :scsi_mod:scsi_request_fn+0x0/0x362
 [<ffffffff8800808b>] :scsi_mod:scsi_request_fn+0x77/0x362
 [<ffffffff8030678f>] generic_unplug_device+0x18/0x25
 [<ffffffff802b289d>] __blockdev_direct_IO+0x851/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83


Code: 4c 8b 04 c6 48 89 f0 4c 0f b1 03 48 39 f0 75 c6 81 e5 00 80
RIP  [<ffffffff80287cc6>] kmem_cache_alloc_node+0x46/0x70
 RSP <ffff8101061a7e50>
Kernel panic - not syncing: Aiee, killing interrupt handler!
BUG: spinlock lockup on CPU#2, oracle/22999, ffff81010bdef018

Call Trace:
 [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff80307d64>] __make_request+0x65/0x574
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff803084a6>] generic_make_request+0x1d1/0x206
 [<ffffffff802af538>] bio_alloc_bioset+0xcd/0x136
 [<ffffffff803085af>] submit_bio+0xd4/0xdf
 [<ffffffff802b1b4f>] dio_bio_submit+0x52/0x66
 [<ffffffff802b2873>] __blockdev_direct_IO+0x827/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83

BUG: spinlock lockup on CPU#7, ksoftirqd/7/25, ffff81010bdef018

Call Trace:
 <IRQ>  [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff88007092>] :scsi_mod:scsi_device_unbusy+0x66/0x80
 [<ffffffff88002979>] :scsi_mod:scsi_finish_command+0x16/0xbf
 [<ffffffff8800800d>] :scsi_mod:scsi_softirq_done+0xdd/0xe4
 [<ffffffff8031306e>] kobject_release+0x0/0x9
 [<ffffffff8031306e>] kobject_release+0x0/0x9
 [<ffffffff80308a2b>] blk_done_softirq+0x63/0x71
 [<ffffffff8023aa61>] __do_softirq+0x50/0xbb
 [<ffffffff8020c7ac>] call_softirq+0x1c/0x28
 <EOI>  [<ffffffff8023ae66>] ksoftirqd+0x0/0x9b
 [<ffffffff8020ddb8>] do_softirq+0x2e/0x96
 [<ffffffff8023ae66>] ksoftirqd+0x0/0x9b
 [<ffffffff8023aeab>] ksoftirqd+0x45/0x9b
 [<ffffffff802486dc>] kthread+0x3d/0x63
 [<ffffffff8020c438>] child_rip+0xa/0x12
 [<ffffffff8024869f>] kthread+0x0/0x63
 [<ffffffff8020c42e>] child_rip+0x0/0x12

BUG: spinlock lockup on CPU#1, ksoftirqd/1/7, ffff81010bdef018

Call Trace:
BUG: spinlock lockup on CPU#3, oracle/22971, ffff81010bdef018

Call Trace:
 [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff80307d64>] __make_request+0x65/0x574
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff803084a6>] generic_make_request+0x1d1/0x206
 [<ffffffff802af538>] bio_alloc_bioset+0xcd/0x136
 [<ffffffff803085af>] submit_bio+0xd4/0xdf
 [<ffffffff802b1b4f>] dio_bio_submit+0x52/0x66
 [<ffffffff802b2873>] __blockdev_direct_IO+0x827/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83

 <IRQ>  [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff88007092>] :scsi_mod:scsi_device_unbusy+0x66/0x80
 [<ffffffff88002979>] :scsi_mod:scsi_finish_command+0x16/0xbf
 [<ffffffff8800800d>] :scsi_mod:scsi_softirq_done+0xdd/0xe4
 [<ffffffff8031306e>] kobject_release+0x0/0x9
 [<ffffffff8031306e>] kobject_release+0x0/0x9
 [<ffffffff80308a2b>] blk_done_softirq+0x63/0x71
 [<ffffffff8023aa61>] __do_softirq+0x50/0xbb
 [<ffffffff8020c7ac>] call_softirq+0x1c/0x28
 <EOI>  [<ffffffff8023ae66>] ksoftirqd+0x0/0x9b
 [<ffffffff8020ddb8>] do_softirq+0x2e/0x96
 [<ffffffff8023ae66>] ksoftirqd+0x0/0x9b
 [<ffffffff8023aeab>] ksoftirqd+0x45/0x9b
 [<ffffffff802486dc>] kthread+0x3d/0x63
 [<ffffffff8020c438>] child_rip+0xa/0x12
 [<ffffffff8024869f>] kthread+0x0/0x63
 [<ffffffff8020c42e>] child_rip+0x0/0x12

BUG: spinlock lockup on CPU#6, oracle/22645, ffff81010bdef018

Call Trace:
 [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff80307d64>] __make_request+0x65/0x574
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff803084a6>] generic_make_request+0x1d1/0x206
 [<ffffffff802af538>] bio_alloc_bioset+0xcd/0x136
 [<ffffffff803085af>] submit_bio+0xd4/0xdf
 [<ffffffff802b1b4f>] dio_bio_submit+0x52/0x66
 [<ffffffff802b2873>] __blockdev_direct_IO+0x827/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
BUG: spinlock lockup on CPU#4, oracle/22730, ffff81010bdef018

Call Trace:
 [<ffffffff80319aee>] _raw_spin_lock+0xcc/0xf3
 [<ffffffff80307d64>] __make_request+0x65/0x574
 [<ffffffff80267faf>] mempool_alloc+0x41/0xf9
 [<ffffffff803084a6>] generic_make_request+0x1d1/0x206
 [<ffffffff802af538>] bio_alloc_bioset+0xcd/0x136
 [<ffffffff803085af>] submit_bio+0xd4/0xdf
 [<ffffffff802b1b4f>] dio_bio_submit+0x52/0x66
 [<ffffffff802b2873>] __blockdev_direct_IO+0x827/0xa34
 [<ffffffff802b0746>] blkdev_direct_IO+0x45/0x4a
 [<ffffffff802b0681>] blkdev_get_blocks+0x0/0x80
 [<ffffffff802674c2>] generic_file_direct_IO+0xd0/0x103
 [<ffffffff80267bb6>] generic_file_aio_read+0x86/0x160
 [<ffffffff802a3fe9>] __aio_get_req+0x1f/0x141
 [<ffffffff80267b30>] generic_file_aio_read+0x0/0x160
 [<ffffffff802a51c7>] aio_rw_vect_retry+0x75/0x171
 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83

 [<ffffffff802a5152>] aio_rw_vect_retry+0x0/0x171
 [<ffffffff802a4727>] aio_run_iocb+0x5d/0xe3
 [<ffffffff802a571b>] io_submit_one+0x333/0x379
 [<ffffffff802a5812>] sys_io_submit+0xb1/0xfe
 [<ffffffff8020b61e>] system_call+0x7e/0x83

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
