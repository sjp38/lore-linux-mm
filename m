Date: Fri, 26 Sep 2008 18:28:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926182833.95783a72.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926142455.5b0e239e.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
	<20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120408.39187294.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120019.33d58ca4.nishimura@mxp.nes.nec.co.jp>
	<20080926130534.e16c9317.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926142455.5b0e239e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 14:24:55 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 26 Sep 2008 13:05:34 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 26 Sep 2008 12:00:19 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > I'll test it with updated version of 9-11 and report you back.
> > > 
> > Thank you. below is the new one...(Sorry!)
> > 
> > -Kame
> > ==
> > Check LRU bit under lru_lock.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> >  mm/memcontrol.c |    9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> > 
> > Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
> > +++ mmotm-2.6.27-rc7+/mm/memcontrol.c
> > @@ -340,11 +340,12 @@ void mem_cgroup_move_lists(struct page *
> >  	if (!trylock_page_cgroup(pc))
> >  		return;
> >  
> > -	if (PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
> > +	if (PageCgroupUsed(pc)) {
> >  		mem = pc->mem_cgroup;
> >  		mz = page_cgroup_zoneinfo(pc);
> >  		spin_lock_irqsave(&mz->lru_lock, flags);
> > -		__mem_cgroup_move_lists(pc, lru);
> > +		if (PageCgroupLRU(pc))
> > +			__mem_cgroup_move_lists(pc, lru);
> >  		spin_unlock_irqrestore(&mz->lru_lock, flags);
> >  	}
> >  	unlock_page_cgroup(pc);
> > @@ -564,8 +565,8 @@ __release_page_cgroup(struct memcg_percp
> >  			spin_lock(&mz->lru_lock);
> >  		}
> >  		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
> > -			__mem_cgroup_remove_list(mz, pc);
> >  			ClearPageCgroupLRU(pc);
> > +			__mem_cgroup_remove_list(mz, pc);
> >  		}
> >  	}
> >  	if (prev_mz)
> > @@ -597,8 +598,8 @@ __set_page_cgroup_lru(struct memcg_percp
> >  			spin_lock(&mz->lru_lock);
> >  		}
> >  		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
> > -			SetPageCgroupLRU(pc);
> >  			__mem_cgroup_add_list(mz, pc);
> > +			SetPageCgroupLRU(pc);
> >  		}
> >  	}
> >  
> > 
> 
> Unfortunately, there remains some bugs yet...
> 
I confirmed I can reproduce this.

I found one chance to cause this. (and confirmed this happens by printk)
                                   set_lru()..
                                      
   TestSetPageCgroup(pc);
   ....                            if (PageCgroupUsed(pc) && !PageCgroupLRU(pc))
   pc->mem_cgroup = mem;
                                      SetPageCgroupLRU();
                                      __mem_cgroup_add_list();


Then, page_cgroup will be added to wrong LRU whic doesn't match pc->mem_cgroup.

But there is still more...still digging.

Thanks,
-kame



> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:51 list_del+0x5c/0x87()
> list_del corruption. next->prev should be ffff88010ca291e8, but was dead000000200200
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3940, comm: bash Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffff8024c0ec>] prepare_to_wait_exclusive+0x38/0x5a
>  [<ffffffff8024c089>] finish_wait+0x32/0x5d
>  [<ffffffff8049ec80>] __wait_on_bit_lock+0x5b/0x66
>  [<ffffffff80272ff4>] __lock_page+0x5e/0x64
>  [<ffffffff8022c4f9>] target_load+0x2a/0x58
>  [<ffffffff8022cf59>] place_entity+0x85/0xb3
>  [<ffffffff8022f6db>] enqueue_entity+0x16e/0x18f
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff802788d3>] get_page_from_freelist+0x455/0x5bf
>  [<ffffffff803402e8>] list_del+0x5c/0x87
>  [<ffffffff802a1530>] mem_cgroup_commit_charge+0x6f/0xdd
>  [<ffffffff802a16ed>] mem_cgroup_charge_common+0x4c/0x62
>  [<ffffffff802835de>] handle_mm_fault+0x222/0x791
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff8028235a>] follow_page+0x2d/0x2c2
>  [<ffffffff80283e42>] __get_user_pages+0x2f5/0x3f3
>  [<ffffffff802a74ed>] get_arg_page+0x46/0xa5
>  [<ffffffff802a7724>] copy_strings+0xfc/0x1de
>  [<ffffffff802a7827>] copy_strings_kernel+0x21/0x33
>  [<ffffffff802a8aff>] do_execve+0x140/0x256
>  [<ffffffff8020a495>] sys_execve+0x35/0x4c
>  [<ffffffff8020c1ea>] stub_execve+0x6a/0xc0
> ---[ end trace 4eaa2a86a8e2da22 ]---
> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:48 list_del+0x30/0x87()
> list_del corruption. prev->next should be ffff88010ca29210, but was dead000000100100
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3940, comm: bash Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffff802bf928>] __getblk+0x25/0x21f
>  [<ffffffffa0060f7e>] __ext3_journal_dirty_metadata+0x1e/0x46 [ext3]
>  [<ffffffff8022dae7>] __wake_up+0x38/0x4f
>  [<ffffffff802bc201>] __mark_inode_dirty+0x15c/0x16b
>  [<ffffffff802b4ec7>] touch_atime+0x109/0x112
>  [<ffffffff802b8284>] mnt_drop_write+0x25/0xdc
>  [<ffffffff80274cf9>] generic_file_aio_read+0x4b8/0x515
>  [<ffffffff803402bc>] list_del+0x30/0x87
>  [<ffffffff802a1106>] __release_page_cgroup+0x68/0x8a
>  [<ffffffff8028a67a>] page_remove_rmap+0x10e/0x12e
>  [<ffffffff80282a65>] unmap_vmas+0x476/0x7f2
>  [<ffffffff80286e5e>] exit_mmap+0xf0/0x176
>  [<ffffffff8038ec62>] secure_ip_id+0x45/0x4a
>  [<ffffffff802389e2>] mmput+0x30/0x88
>  [<ffffffff802a868b>] flush_old_exec+0x487/0x77c
>  [<ffffffff802a47b7>] vfs_read+0x11e/0x133
>  [<ffffffff802d54c9>] load_elf_binary+0x338/0x16b6
>  [<ffffffff802a74ed>] get_arg_page+0x46/0xa5
>  [<ffffffff802a77f5>] copy_strings+0x1cd/0x1de
>  [<ffffffff802a7907>] search_binary_handler+0xb0/0x22e
>  [<ffffffff802a8b67>] do_execve+0x1a8/0x256
>  [<ffffffff8020a495>] sys_execve+0x35/0x4c
>  [<ffffffff8020c1ea>] stub_execve+0x6a/0xc0
> ---[ end trace 4eaa2a86a8e2da22 ]---
> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:48 list_del+0x30/0x87()
> list_del corruption. prev->next should be ffff88010c937d50, but was ffff88010ca052e8
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3943, comm: shmem_test_02 Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffff802974c2>] shmem_getpage+0x75/0x7a0
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff802787d1>] get_page_from_freelist+0x353/0x5bf
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff802787d1>] get_page_from_freelist+0x353/0x5bf
>  [<ffffffff803402bc>] list_del+0x30/0x87
>  [<ffffffff802a1530>] mem_cgroup_commit_charge+0x6f/0xdd
>  [<ffffffff802a16ed>] mem_cgroup_charge_common+0x4c/0x62
>  [<ffffffff8028214e>] do_wp_page+0x3ab/0x58a
>  [<ffffffff80283af1>] handle_mm_fault+0x735/0x791
>  [<ffffffff802cdf1e>] fcntl_setlk+0x233/0x263
>  [<ffffffff804a20e5>] do_page_fault+0x39c/0x773
>  [<ffffffff804a0009>] error_exit+0x0/0x51
> ---[ end trace 4eaa2a86a8e2da22 ]---
> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:48 list_del+0x30/0x87()
> list_del corruption. prev->next should be ffff88010ca052e8, but was ffff88010c4068a0
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3942, comm: shmem_test_02 Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffff80277283>] rmqueue_bulk+0x61/0x8b
>  [<ffffffff8033b8a5>] number+0x106/0x1f9
>  [<ffffffff8027ff0a>] zone_statistics+0x3a/0x5d
>  [<ffffffff802787d1>] get_page_from_freelist+0x353/0x5bf
>  [<ffffffff802775e7>] free_pages_bulk+0x198/0x20b
>  [<ffffffff80277ffe>] __pagevec_free+0x21/0x2e
>  [<ffffffff8027b410>] release_pages+0x151/0x19f
>  [<ffffffff803402bc>] list_del+0x30/0x87
>  [<ffffffff802a1106>] __release_page_cgroup+0x68/0x8a
>  [<ffffffff802747c7>] __remove_from_page_cache+0x45/0x8f
>  [<ffffffff80274d7d>] remove_from_page_cache+0x27/0x2f
>  [<ffffffff8027c04b>] truncate_complete_page+0x49/0x59
>  [<ffffffff8027c118>] truncate_inode_pages_range+0xbd/0x2ff
>  [<ffffffff80298abb>] shmem_delete_inode+0x33/0xc4
>  [<ffffffff80298a88>] shmem_delete_inode+0x0/0xc4
>  [<ffffffff802b41af>] generic_delete_inode+0xb0/0x124
>  [<ffffffff802b1655>] d_kill+0x21/0x43
>  [<ffffffff802b28fe>] dput+0x111/0x11f
>  [<ffffffff802a4ed8>] __fput+0x14f/0x17e
>  [<ffffffff80286d39>] remove_vma+0x3d/0x72
>  [<ffffffff80286ec5>] exit_mmap+0x157/0x176
>  [<ffffffff802389e2>] mmput+0x30/0x88
>  [<ffffffff8023c66a>] exit_mm+0xff/0x10a
>  [<ffffffff8023dafc>] do_exit+0x210/0x7a5
>  [<ffffffff80269c22>] audit_syscall_entry+0x12d/0x160
>  [<ffffffff8023e0f7>] do_group_exit+0x66/0x96
>  [<ffffffff8020bdcb>] system_call_fastpath+0x16/0x1b
> ---[ end trace 4eaa2a86a8e2da22 ]---
> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:51 list_del+0x5c/0x87()
> list_del corruption. next->prev should be ffff88010caf6b20, but was dead000000200200
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3932, comm: page01 Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffff802775e7>] free_pages_bulk+0x198/0x20b
>  [<ffffffff8027b44c>] release_pages+0x18d/0x19f
>  [<ffffffff803402e8>] list_del+0x5c/0x87
>  [<ffffffff802a1106>] __release_page_cgroup+0x68/0x8a
>  [<ffffffff8028a67a>] page_remove_rmap+0x10e/0x12e
>  [<ffffffff80282a65>] unmap_vmas+0x476/0x7f2
>  [<ffffffff80286e5e>] exit_mmap+0xf0/0x176
>  [<ffffffff802389e2>] mmput+0x30/0x88
>  [<ffffffff8023c66a>] exit_mm+0xff/0x10a
>  [<ffffffff8023dafc>] do_exit+0x210/0x7a5
>  [<ffffffff80269c22>] audit_syscall_entry+0x12d/0x160
>  [<ffffffff8023e0f7>] do_group_exit+0x66/0x96
>  [<ffffffff8020bdcb>] system_call_fastpath+0x16/0x1b
> ---[ end trace 4eaa2a86a8e2da22 ]---
> ------------[ cut here ]------------
> WARNING: at lib/list_debug.c:48 list_del+0x30/0x87()
> list_del corruption. prev->next should be ffff88010c4068a0, but was dead000000100100
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
> rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
> lug parport_pc rtc_cmos rtc_core parport serio_raw rtc_lib i2c_i801 i2c_core shpchp pcspkr
>  ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
> _hcd
> Pid: 3934, comm: page01 Tainted: G        W 2.6.27-rc7-mm1-dd8bf0fe #1
> Call Trace:
>  [<ffffffff8023ac52>] warn_slowpath+0xb4/0xd2
>  [<ffffffffa003b89c>] do_get_write_access+0x37d/0x3c3 [jbd]
>  [<ffffffff802bf928>] __getblk+0x25/0x21f
>  [<ffffffff8024bf27>] bit_waitqueue+0x10/0xa0
>  [<ffffffffa003b89c>] do_get_write_access+0x37d/0x3c3 [jbd]
>  [<ffffffff8024bf27>] bit_waitqueue+0x10/0xa0
>  [<ffffffff80272e22>] find_get_page+0x18/0xc4
>  [<ffffffff8024bf27>] bit_waitqueue+0x10/0xa0
>  [<ffffffff803402bc>] list_del+0x30/0x87
>  [<ffffffff802a1106>] __release_page_cgroup+0x68/0x8a
>  [<ffffffff8028a67a>] page_remove_rmap+0x10e/0x12e
>  [<ffffffff80282a65>] unmap_vmas+0x476/0x7f2
>  [<ffffffff80286e5e>] exit_mmap+0xf0/0x176
>  [<ffffffff802389e2>] mmput+0x30/0x88
>  [<ffffffff8023c66a>] exit_mm+0xff/0x10a
>  [<ffffffff8023dafc>] do_exit+0x210/0x7a5
>  [<ffffffff80269c22>] audit_syscall_entry+0x12d/0x160
>  [<ffffffff8023e0f7>] do_group_exit+0x66/0x96
>  [<ffffffff8020bdcb>] system_call_fastpath+0x16/0x1b
> ---[ end trace 4eaa2a86a8e2da22 ]---
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
