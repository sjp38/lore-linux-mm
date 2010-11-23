Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DBAD6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 08:48:55 -0500 (EST)
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
Subject: [PATCH] [BUG] memcg: fix false positive VM_BUG on non-SMP
Date: Tue, 23 Nov 2010 15:48:50 +0200
Message-Id: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

From: Kirill A. Shutemov <kirill@shutemov.name>

------------[ cut here ]------------
kernel BUG at mm/memcontrol.c:2155!
invalid opcode: 0000 [#1]
last sysfs file:

Pid: 18, comm: sh Not tainted 2.6.37-rc3 #3 /Bochs
EIP: 0060:[<c10731b2>] EFLAGS: 00000246 CPU: 0
EIP is at mem_cgroup_move_account+0xe2/0xf0
EAX: 00000004 EBX: c6f931d4 ECX: c681c300 EDX: c681c000
ESI: c681c300 EDI: ffffffea EBP: c681c000 ESP: c46f3e30
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process sh (pid: 18, ti=c46f2000 task=c6826e60 task.ti=c46f2000)
Stack:
 00000155 c681c000 0805f000 c46ee180 c46f3e5c c7058820 c1074d37 00000000
 08060000 c46db9a0 c46ec080 c7058820 0805f000 08060000 c46f3e98 c1074c50
 c106c75e c46f3e98 c46ec080 08060000 0805ffff c46db9a0 c46f3e98 c46e0340
Call Trace:
 [<c1074d37>] ? mem_cgroup_move_charge_pte_range+0xe7/0x130
 [<c1074c50>] ? mem_cgroup_move_charge_pte_range+0x0/0x130
 [<c106c75e>] ? walk_page_range+0xee/0x1d0
 [<c10725d6>] ? mem_cgroup_move_task+0x66/0x90
 [<c1074c50>] ? mem_cgroup_move_charge_pte_range+0x0/0x130
 [<c1072570>] ? mem_cgroup_move_task+0x0/0x90
 [<c1042616>] ? cgroup_attach_task+0x136/0x200
 [<c1042878>] ? cgroup_tasks_write+0x48/0xc0
 [<c1041e9e>] ? cgroup_file_write+0xde/0x220
 [<c101398d>] ? do_page_fault+0x17d/0x3f0
 [<c108a79d>] ? alloc_fd+0x2d/0xd0
 [<c1041dc0>] ? cgroup_file_write+0x0/0x220
 [<c1077ba2>] ? vfs_write+0x92/0xc0
 [<c1077c81>] ? sys_write+0x41/0x70
 [<c1140e3d>] ? syscall_call+0x7/0xb
Code: 03 00 74 09 8b 44 24 04 e8 1c f1 ff ff 89 73 04 8d 86 b0 00 00 00 b9 01 00 00 00 89 da 31 ff e8 65 f5 ff ff e9 4d ff ff ff 0f 0b <0f> 0b 0f 0b 0f 0b 90 8d b4 26 00 00 00 00 83 ec 10 8b 0d f4 e3
EIP: [<c10731b2>] mem_cgroup_move_account+0xe2/0xf0 SS:ESP 0068:c46f3e30
---[ end trace 7daa1582159b6532 ]---

lock_page_cgroup and unlock_page_cgroup are implemented using
bit_spinlock. bit_spinlock doesn't touch the bit if we are on non-SMP
machine, so we can't use the bit to check whether the lock was taken.

Let's introduce is_page_cgroup_locked based on bit_spin_is_locked
instead of PageCgroupLocked to fix it.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/page_cgroup.h |    7 +++++--
 mm/memcontrol.c             |    2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 5bb13b3..c42b523 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -59,8 +59,6 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
-TESTPCGFLAG(Locked, LOCK)
-
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 CLEARPCGFLAG(Cache, CACHE)
@@ -104,6 +102,11 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline int is_page_cgroup_locked(struct page_cgroup *pc)
+{
+	return bit_spin_is_locked(PCG_LOCK, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2efa8ea..d6c4bb9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2152,7 +2152,7 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 {
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-	VM_BUG_ON(!PageCgroupLocked(pc));
+	VM_BUG_ON(!is_page_cgroup_locked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
-- 
1.7.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
