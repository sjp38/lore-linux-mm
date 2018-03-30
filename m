Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Li RongQing <lirongqing@baidu.com>
Subject: [PATCH] mm: limit a process RSS
Date: Fri, 30 Mar 2018 13:11:14 +0800
Message-Id: <1522386674-12047-1-git-send-email-lirongqing@baidu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

we cannot limit a process RSS although there is ulimit -m,
not sure why and when ulimit -m is not working, make it work

similar requirement:
https://stackoverflow.com/questions/3360348/why-ulimit-cant-limit-resident-memory-successfully-and-how

Signed-off-by: Li RongQing <lirongqing@baidu.com>
---
 mm/memory.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 5fcfc24904d1..50cf9399477c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4140,6 +4140,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		ret = __handle_mm_fault(vma, address, flags);
 
 	if (flags & FAULT_FLAG_USER) {
+		unsigned long total_rss = get_mm_rss(current->mm);
+		u64 rlimit;
+
 		mem_cgroup_oom_disable();
 		/*
 		 * The task may have entered a memcg OOM situation but
@@ -4149,6 +4152,17 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		 */
 		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
 			mem_cgroup_oom_synchronize(false);
+
+		rlimit = current->signal->rlim[RLIMIT_RSS].rlim_cur;
+
+		if (unlikely(total_rss > (rlimit >> PAGE_SHIFT)) &&
+			(current->pid != 1)) {
+
+			pr_info("kill process %s rsslimit[%lluK] rss[%luK]\n",
+				current->comm, (rlimit >> 10),
+				total_rss << (PAGE_SHIFT - 10));
+			do_group_exit(SIGKILL);
+		}
 	}
 
 	return ret;
-- 
2.11.0
