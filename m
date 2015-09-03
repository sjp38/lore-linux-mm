From: gang.chen.5i5j@gmail.com
Subject: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer in get_unmapped_area()
Date: Thu,  3 Sep 2015 12:14:51 +0800
Message-ID: <1441253691-5798-1-git-send-email-gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, mhocko@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gchen_5i5j@21cn.com, Chen Gang <gang.chen.5i5j@gmail.com>
List-Id: linux-mm.kvack.org

From: Chen Gang <gang.chen.5i5j@gmail.com>

Call the function pointer directly, then let code a bit simpler.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/mmap.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 4db7cf0..39fd727 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2012,10 +2012,8 @@ unsigned long
 get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
-	unsigned long (*get_area)(struct file *, unsigned long,
-				  unsigned long, unsigned long, unsigned long);
-
 	unsigned long error = arch_mmap_check(addr, len, flags);
+
 	if (error)
 		return error;
 
@@ -2023,10 +2021,12 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	get_area = current->mm->get_unmapped_area;
 	if (file && file->f_op->get_unmapped_area)
-		get_area = file->f_op->get_unmapped_area;
-	addr = get_area(file, addr, len, pgoff, flags);
+		addr = file->f_op->get_unmapped_area(file, addr, len,
+							pgoff, flags);
+	else
+		addr = current->mm->get_unmapped_area(file, addr, len,
+							pgoff, flags);
 	if (IS_ERR_VALUE(addr))
 		return addr;
 
-- 
1.9.3
