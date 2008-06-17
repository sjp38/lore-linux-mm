Date: Tue, 17 Jun 2008 18:03:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bad page] trying to free locked page? (Re: [PATCH][RFC] fix
 kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)
Message-Id: <20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	<20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Jun 2008 16:47:09 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 17 Jun 2008 16:35:01 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > Hi.
> > 
> > I got this bug while migrating pages only a few times
> > via memory_migrate of cpuset.
> > 
> > Unfortunately, even if this patch is applied,
> > I got bad_page problem after hundreds times of page migration
> > (I'll report it in another mail).
> > But I believe something like this patch is needed anyway.
> > 
> 
> I got bad_page after hundreds times of page migration.
> It seems that a locked page is being freed.
> 
Good catch, and I think your investigation in the last e-mail was correct.
I'd like to dig this...but it seems some kind of big fix is necessary.
Did this happen under page-migraion by cpuset-task-move test ?

Thanks,
-Kame



> 
> Bad page state in process 'switch.sh'
> page:ffffe20001ee8f40 flags:0x0500000000080019 mapping:0000000000000000 mapcount:0 count:0
> Trying to fix it up, but a reboot is needed
> Backtrace:
> Pid: 23283, comm: switch.sh Not tainted 2.6.26-rc5-mm3-test6-lee #1
> 
> Call Trace:
>  [<ffffffff802747b0>] bad_page+0x97/0x131
>  [<ffffffff80275ae6>] free_hot_cold_page+0xd4/0x19c
>  [<ffffffff8027a5c3>] putback_lru_page+0xf4/0xfb
>  [<ffffffff8029b210>] putback_lru_pages+0x46/0x74
>  [<ffffffff8029bc5b>] migrate_pages+0x3f4/0x468
>  [<ffffffff80290797>] new_node_page+0x0/0x2f
>  [<ffffffff80291631>] do_migrate_pages+0x19b/0x1e7
>  [<ffffffff8025c827>] cpuset_migrate_mm+0x58/0x8f
>  [<ffffffff8025d0fd>] cpuset_attach+0x8b/0x9e
>  [<ffffffff8032ffdc>] sscanf+0x49/0x51
>  [<ffffffff8025a3e1>] cgroup_attach_task+0x3a3/0x3f5
>  [<ffffffff80489a90>] __mutex_lock_slowpath+0x64/0x93
>  [<ffffffff8025af06>] cgroup_common_file_write+0x150/0x1dd
>  [<ffffffff8025aaf4>] cgroup_file_write+0x54/0x150
>  [<ffffffff8029f855>] vfs_write+0xad/0x136
>  [<ffffffff8029fd92>] sys_write+0x45/0x6e
>  [<ffffffff8020bef2>] tracesys+0xd5/0xda
> 
> Hexdump:
> 000: 28 00 08 00 00 00 00 05 02 00 00 00 01 00 00 00
> 010: 00 00 00 00 00 00 00 00 41 3b 41 2f 00 81 ff ff
> 020: 46 01 00 00 00 00 00 00 e8 17 e6 01 00 e2 ff ff
> 030: e8 4b e6 01 00 e2 ff ff 00 00 00 00 00 00 00 00
> 040: 19 00 08 00 00 00 00 05 00 00 00 00 ff ff ff ff
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 060: ba 06 00 00 00 00 00 00 00 01 10 00 00 c1 ff ff
> 070: 00 02 20 00 00 c1 ff ff 00 00 00 00 00 00 00 00
> 080: 28 00 08 00 00 00 00 05 01 00 00 00 00 00 00 00
> 090: 00 00 00 00 00 00 00 00 01 3d 41 2f 00 81 ff ff
> 0a0: bb c3 55 f7 07 00 00 00 68 c4 f0 01 00 e2 ff ff
> 0b0: e8 8f ee 01 00 e2 ff ff 00 00 00 00 00 00 00 00
> ------------[ cut here ]------------
> kernel BUG at mm/filemap.c:575!
> invalid opcode: 0000 [1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu3/cache/index1/shared_cpu_map
> CPU 1
> Modules linked in: nfs lockd nfs_acl ipv6 autofs4 hidp rfcomm l2cap bluetooth sunrpc dm_mirror dm_log dm_multipath dm_mod sbs sbshc button battery acpi_memhotplug ac parport_pc lp parport floppy serio_raw rtc_cmos 8139too rtc_core rtc_lib 8139cp mii pcspkr ata_piix libata sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: microcode]
> Pid: 23283, comm: switch.sh Tainted: G    B     2.6.26-rc5-mm3-test6-lee #1
> RIP: 0010:[<ffffffff80270bfe>]  [<ffffffff80270bfe>] unlock_page+0xf/0x26
> RSP: 0018:ffff8100396e7b78  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffe20001ee8f40 RCX: 000000000000005a
> RDX: 0000000000000006 RSI: 0000000000000003 RDI: ffffe20001ee8f40
> RBP: ffffe20001f3e9c0 R08: 0000000000000008 R09: ffff810001101780
> R10: 0000000000000002 R11: 0000000000000000 R12: 0000000000000004
> R13: ffff8100396e7c88 R14: ffffe20001e8d080 R15: ffff8100396e7c88
> FS:  00007fd4597fb6f0(0000) GS:ffff81007f98d280(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000418498 CR3: 000000003e9ac000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process switch.sh (pid: 23283, threadinfo ffff8100396e6000, task ffff8100318a64a0)
> Stack:  ffffe20001ee8f40 ffffffff8029b21c ffffe20001e98e40 ffff8100396e7c60
>  ffffe20000665140 ffff8100314fd581 0000000000000000 ffffffff8029bc5b
>  0000000000000000 ffffffff80290797 0000000000000000 0000000000000001
> Call Trace:
>  [<ffffffff8029b21c>] ? putback_lru_pages+0x52/0x74
>  [<ffffffff8029bc5b>] ? migrate_pages+0x3f4/0x468
>  [<ffffffff80290797>] ? new_node_page+0x0/0x2f
>  [<ffffffff80291631>] ? do_migrate_pages+0x19b/0x1e7
>  [<ffffffff8025c827>] ? cpuset_migrate_mm+0x58/0x8f
>  [<ffffffff8025d0fd>] ? cpuset_attach+0x8b/0x9e
>  [<ffffffff8032ffdc>] ? sscanf+0x49/0x51
>  [<ffffffff8025a3e1>] ? cgroup_attach_task+0x3a3/0x3f5
>  [<ffffffff80489a90>] ? __mutex_lock_slowpath+0x64/0x93
>  [<ffffffff8025af06>] ? cgroup_common_file_write+0x150/0x1dd
>  [<ffffffff8025aaf4>] ? cgroup_file_write+0x54/0x150
>  [<ffffffff8029f855>] ? vfs_write+0xad/0x136
>  [<ffffffff8029fd92>] ? sys_write+0x45/0x6e
>  [<ffffffff8020bef2>] ? tracesys+0xd5/0xda
> 
> 
> Code: 40 58 48 85 c0 74 0b 48 8b 40 10 48 85 c0 74 02 ff d0 e8 7b 89 21 00 41 5b 31 c0 c3 53 48 89 fb f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 01 f5 ff ff 48 89 de 48 89 c7 31 d2 5b e9 ea 5e
> RIP  [<ffffffff80270bfe>] unlock_page+0xf/0x26
>  RSP <ffff8100396e7b78>
> ---[ end trace 4ab171fcf075cf2e ]---
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
