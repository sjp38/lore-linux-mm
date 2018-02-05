Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFA4E6B02B4
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:34:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id h5so18609061pgv.21
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:34:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 68-v6si3704801ple.371.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 38/64] arch/blackfin: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:28 +0100
Message-Id: <20180205012754.23615-39-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/blackfin/kernel/ptrace.c | 5 +++--
 arch/blackfin/kernel/trace.c  | 7 ++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/blackfin/kernel/ptrace.c b/arch/blackfin/kernel/ptrace.c
index a6827095b99a..e6657ab61afc 100644
--- a/arch/blackfin/kernel/ptrace.c
+++ b/arch/blackfin/kernel/ptrace.c
@@ -121,15 +121,16 @@ is_user_addr_valid(struct task_struct *child, unsigned long start, unsigned long
 	bool valid;
 	struct vm_area_struct *vma;
 	struct sram_list_struct *sraml;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* overflow */
 	if (start + len < start)
 		return -EIO;
 
-	down_read(&child->mm->mmap_sem);
+	mm_read_lock(child->mm, &mmrange);
 	vma = find_vma(child->mm, start);
 	valid = vma && start >= vma->vm_start && start + len <= vma->vm_end;
-	up_read(&child->mm->mmap_sem);
+	mm_read_unlock(child->mm, &mmrange);
 	if (valid)
 		return 0;
 
diff --git a/arch/blackfin/kernel/trace.c b/arch/blackfin/kernel/trace.c
index 151f22196ab6..9bf938b14601 100644
--- a/arch/blackfin/kernel/trace.c
+++ b/arch/blackfin/kernel/trace.c
@@ -33,6 +33,7 @@ void decode_address(char *buf, unsigned long address)
 	struct mm_struct *mm;
 	unsigned long offset;
 	struct rb_node *n;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 #ifdef CONFIG_KALLSYMS
 	unsigned long symsize;
@@ -124,7 +125,7 @@ void decode_address(char *buf, unsigned long address)
 			continue;
 
 		mm = t->mm;
-		if (!down_read_trylock(&mm->mmap_sem))
+		if (!mm_read_trylock(mm, &mmrange))
 			goto __continue;
 
 		for (n = rb_first(&mm->mm_rb); n; n = rb_next(n)) {
@@ -166,7 +167,7 @@ void decode_address(char *buf, unsigned long address)
 					sprintf(buf, "[ %s vma:0x%lx-0x%lx]",
 						name, vma->vm_start, vma->vm_end);
 
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &mmrange);
 				task_unlock(t);
 
 				if (buf[0] == '\0')
@@ -176,7 +177,7 @@ void decode_address(char *buf, unsigned long address)
 			}
 		}
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 __continue:
 		task_unlock(t);
 	}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
