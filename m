Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A68666B0078
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:19 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so2444646pad.40
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:18 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/9] mm: use mm_populate() when adjusting brk with MCL_FUTURE in effect.
Date: Thu, 20 Dec 2012 16:49:53 -0800
Message-Id: <1356050997-2688-6-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a16fc499dbd1..4c8d39e64e80 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -240,6 +240,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	unsigned long newbrk, oldbrk;
 	struct mm_struct *mm = current->mm;
 	unsigned long min_brk;
+	bool populate;
 
 	down_write(&mm->mmap_sem);
 
@@ -289,8 +290,15 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	/* Ok, looks good - let it rip. */
 	if (do_brk(oldbrk, newbrk-oldbrk) != oldbrk)
 		goto out;
+
 set_brk:
 	mm->brk = brk;
+	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
+	up_write(&mm->mmap_sem);
+	if (populate)
+		mm_populate(oldbrk, newbrk - oldbrk);
+	return brk;
+
 out:
 	retval = mm->brk;
 	up_write(&mm->mmap_sem);
@@ -2274,10 +2282,8 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
-	if (flags & VM_LOCKED) {
-		if (!mlock_vma_pages_range(vma, addr, addr + len))
-			mm->locked_vm += (len >> PAGE_SHIFT);
-	}
+	if (flags & VM_LOCKED)
+		mm->locked_vm += (len >> PAGE_SHIFT);
 	return addr;
 }
 
@@ -2285,10 +2291,14 @@ unsigned long vm_brk(unsigned long addr, unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long ret;
+	bool populate;
 
 	down_write(&mm->mmap_sem);
 	ret = do_brk(addr, len);
+	populate = ((mm->def_flags & VM_LOCKED) != 0);
 	up_write(&mm->mmap_sem);
+	if (populate)
+		mm_populate(addr, len);
 	return ret;
 }
 EXPORT_SYMBOL(vm_brk);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
