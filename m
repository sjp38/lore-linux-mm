Subject: [PATCH] a fix for procfs-task-exe-symlink.patch
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080317004330.6D4441E7958@siro.lan>
Date: Mon, 17 Mar 2008 09:43:30 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: matthltc@us.ibm.com, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, minoura@valinux.co.jp
List-ID: <linux-mm.kvack.org>

it seems that procfs-task-exe-symlink.patch broke the case of
dup_mmap failure.  ie. mm->exe_file is copied by memcpy from oldmm
and then be fput'ed by mmput/set_mm_exe_file.

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

--- linux-2.6.25-rc3-mm1/kernel/fork.c.BACKUP	2008-03-05 15:45:50.000000000 +0900
+++ linux-2.6.25-rc3-mm1/kernel/fork.c	2008-03-17 09:17:39.000000000 +0900
@@ -523,11 +526,12 @@ static struct mm_struct *dup_mm(struct t
 	if (init_new_context(tsk, mm))
 		goto fail_nocontext;
 
+	dup_mm_exe_file(oldmm, mm);
+
 	err = dup_mmap(mm, oldmm);
 	if (err)
 		goto free_pt;
 
-	dup_mm_exe_file(oldmm, mm);
 	mm->hiwater_rss = get_mm_rss(mm);
 	mm->hiwater_vm = mm->total_vm;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
