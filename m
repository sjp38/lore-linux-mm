Date: Fri, 26 Sep 2008 11:32:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, 25 Sep 2008 15:11:24 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hi, I updated the stack and reflected comments.
> Against the latest mmotm. (rc7-mm1)
> 
> Major changes from previous one is 
>   - page_cgroup allocation/lookup manner is changed.
>     all FLATMEM/DISCONTIGMEM/SPARSEMEM and MEMORY_HOTPLUG is supported.
>   - force_empty is totally rewritten. and a problem that "force_empty takes long time"
>     in previous version is fixed (I think...)
>   - reordered patches.
>      - first half are easy ones.
>      - second half are big ones.
> 
> I'm still testing with full debug option. No problem found yet.
> (I'm afraid of race condition which have not been caught yet.)
> 
> [1/12]  avoid accounting special mappings not on LRU. (fix)
> [2/12]  move charege() call to swapped-in page under lock_page() (clean up)
> [3/12]  make root cgroup to be unlimited. (change semantics.)
> [4/12]  make page->mapping NULL before calling uncharge (clean up)
> [5/12]  make page->flags to use atomic ops. (changes in infrastructure)
> [6/12]  optimize stat. (clean up)
> [7/12]  add support function for moving account. (new function)
> [8/12]  rewrite force_empty to use move_account. (change semantics.)
> [9/12]  allocate all page_cgroup at boot. (changes in infrastructure)
> [10/12] free page_cgroup from LRU in lazy way (optimize)
> [11/12] add page_cgroup to LRU in lazy way (optimize)
> [12/12] fix race at charging swap  (fix by new logic.)
> 
> *Any* comment is welcome.
> 
> Thanks,
> -Kame
> 

I got general protection fault.

(log from dump)
general protection fault: 0000 [1] SMP
last sysfs file: /sys/devices/system/cpu/cpu15/cache/index1/shared_cpu_map
CPU 0
Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
autofs4 hidp rfcomm l2cap bluetooth sunrpc microcode dm_mirror dm_log dm_multipath dm_mod
rfkill input_polldev sbs sbshc battery ac lp sg e1000 ide_cd_mod cdrom button acpi_memhotp
lug serio_raw rtc_cmos parport_pc rtc_core parport rtc_lib i2c_i801 i2c_core pcspkr shpchp
 ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci
_hcd
Pid: 8001, comm: shmem_test_02 Tainted: G        W 2.6.27-rc7-mm1-7eacf5c9 #1
RIP: 0010:[<ffffffff802a0ebb>]  [<ffffffff802a0ebb>] __mem_cgroup_move_lists+0x8b/0xa2
RSP: 0018:ffff8800bb4ad888  EFLAGS: 00010046
RAX: ffff88010b253080 RBX: ffff88010c67d618 RCX: dead000000100100
RDX: dead000000200200 RSI: ffff88010b253088 RDI: ffff88010c67d630
RBP: 0000000000000000 R08: ffff88010fc020a3 R09: 000000000000000f
R10: ffffffff802a204a R11: 00000000fffffffa R12: ffff88010b253080
R13: 0000000000000000 R14: ffff8800bb4ad9c8 R15: 0000000000000000
FS:  00007f4600faa6f0(0000) GS:ffffffff80638900(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000033af86c027 CR3: 00000000c1549000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process shmem_test_02 (pid: 8001, threadinfo ffff8800bb4ac000, task ffff880107d21470)
Stack:  ffffe200028ef8b0 0000000000000082 ffff88010c67d618 ffffffff802a1cb9
 ffff880000016f80 0000000000000000 ffff880000016f80 ffffe200028ef888
 ffff8800bb4adb38 ffffffff8027dd09 ffffc20001859000 0000000000000000
Call Trace:
 [<ffffffff802a1cb9>] mem_cgroup_move_lists+0x50/0x74
 [<ffffffff8027dd09>] shrink_list+0x443/0x4ff
 [<ffffffff8027e04e>] shrink_zone+0x289/0x315
 [<ffffffff802805d2>] congestion_wait+0x74/0x80
 [<ffffffff8024c006>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8027e52a>] do_try_to_free_pages+0x259/0x3e3
 [<ffffffff8027e734>] try_to_free_mem_cgroup_pages+0x80/0x85
 [<ffffffff802a204a>] mem_cgroup_isolate_pages+0x0/0x1d2
 [<ffffffff802a13a3>] mem_cgroup_shrink_usage+0x60/0xba
 [<ffffffff802978a2>] shmem_getpage+0x455/0x7a0
 [<ffffffff8022c4f9>] target_load+0x2a/0x58
 [<ffffffff8022cf59>] place_entity+0x85/0xb3
 [<ffffffff8022f6db>] enqueue_entity+0x16e/0x18f
 [<ffffffff8022f781>] enqueue_task_fair+0x24/0x3a
 [<ffffffff8022cc33>] enqueue_task+0x50/0x5b
 [<ffffffff8023278e>] try_to_wake_up+0x241/0x253
 [<ffffffff8024c00f>] autoremove_wake_function+0x9/0x2e
 [<ffffffff8022c743>] __wake_up_common+0x41/0x74
 [<ffffffff8022dae7>] __wake_up+0x38/0x4f
 [<ffffffff80297c89>] shmem_fault+0x3b/0x68
 [<ffffffff802819f9>] __do_fault+0x51/0x3fb
 [<ffffffff80283592>] handle_mm_fault+0x1d6/0x791
 [<ffffffff804a2115>] do_page_fault+0x39c/0x773
 [<ffffffff804a2154>] do_page_fault+0x3db/0x773
 [<ffffffff804a0039>] error_exit+0x0/0x51
Code: 0b 10 eb 04 f0 80 23 ef f0 80 23 bf 89 e8 48 8d 7b 18 48 ff 44 c6 58 48 c1 e0 04 48
8b 4b 18 48 8b 57 08 48 8d 04 06 48 8d 70 08 <48> 89 51 08 48 89 0a 48 8b 50 08 59 5b 5d e
9 75 f4 09 00 58 5b
RIP  [<ffffffff802a0ebb>] __mem_cgroup_move_lists+0x8b/0xa2
 RSP <ffff8800bb4ad888>
---[ end trace 4eaa2a86a8e2da22 ]---

I've not investigated deeply yet, but it seems that it is trying to
handle an entry which has been already removed from list.
(I can see some "dead" pointer in registers.)

I was running some ltp tests (4 "page01" tests(8MB for each)
and 1 "shmem_test02" test(16MB)) in a group with limit=32M.


Anyway, I'll dig it more later.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
