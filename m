Date: Fri, 26 Sep 2008 11:58:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 11:32:28 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I got general protection fault.
> 
> (log from dump)
> general protection fault: 0000 [1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu15/cache/index1/shared_cpu_map

> Pid: 8001, comm: shmem_test_02 Tainted: G        W 2.6.27-rc7-mm1-7eacf5c9 #1
> RIP: 0010:[<ffffffff802a0ebb>]  [<ffffffff802a0ebb>] __mem_cgroup_move_lists+0x8b/0xa2
> RSP: 0018:ffff8800bb4ad888  EFLAGS: 00010046
> RAX: ffff88010b253080 RBX: ffff88010c67d618 RCX: dead000000100100
> RDX: dead000000200200 RSI: ffff88010b253088 RDI: ffff88010c67d630
> RBP: 0000000000000000 R08: ffff88010fc020a3 R09: 000000000000000f
> R10: ffffffff802a204a R11: 00000000fffffffa R12: ffff88010b253080
> R13: 0000000000000000 R14: ffff8800bb4ad9c8 R15: 0000000000000000
> FS:  00007f4600faa6f0(0000) GS:ffffffff80638900(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00000033af86c027 CR3: 00000000c1549000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process shmem_test_02 (pid: 8001, threadinfo ffff8800bb4ac000, task ffff880107d21470)
> Stack:  ffffe200028ef8b0 0000000000000082 ffff88010c67d618 ffffffff802a1cb9
>  ffff880000016f80 0000000000000000 ffff880000016f80 ffffe200028ef888
>  ffff8800bb4adb38 ffffffff8027dd09 ffffc20001859000 0000000000000000
> Call Trace:
>  [<ffffffff802a1cb9>] mem_cgroup_move_lists+0x50/0x74
>  [<ffffffff8027dd09>] shrink_list+0x443/0x4ff
>  [<ffffffff8027e04e>] shrink_zone+0x289/0x315
>  [<ffffffff802805d2>] congestion_wait+0x74/0x80
>  [<ffffffff8024c006>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff8027e52a>] do_try_to_free_pages+0x259/0x3e3
>  [<ffffffff8027e734>] try_to_free_mem_cgroup_pages+0x80/0x85
>  [<ffffffff802a204a>] mem_cgroup_isolate_pages+0x0/0x1d2

> Code: 0b 10 eb 04 f0 80 23 ef f0 80 23 bf 89 e8 48 8d 7b 18 48 ff 44 c6 58 48 c1 e0 04 48
> 8b 4b 18 48 8b 57 08 48 8d 04 06 48 8d 70 08 <48> 89 51 08 48 89 0a 48 8b 50 08 59 5b 5d e
> 9 75 f4 09 00 58 5b
> RIP  [<ffffffff802a0ebb>] __mem_cgroup_move_lists+0x8b/0xa2
>  RSP <ffff8800bb4ad888>
> ---[ end trace 4eaa2a86a8e2da22 ]---
> 
> I've not investigated deeply yet, but it seems that it is trying to
> handle an entry which has been already removed from list.
> (I can see some "dead" pointer in registers.)
> 
> I was running some ltp tests (4 "page01" tests(8MB for each)
> and 1 "shmem_test02" test(16MB)) in a group with limit=32M.
> 
> 
> Anyway, I'll dig it more later.
> 
Thank you.

How about following ?
-Kame
==
Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -597,8 +597,8 @@ __set_page_cgroup_lru(struct memcg_percp
 			spin_lock(&mz->lru_lock);
 		}
 		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
-			SetPageCgroupLRU(pc);
 			__mem_cgroup_add_list(mz, pc);
+			SetPageCgroupLRU(pc);
 		}
 	}
 






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
