Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806F56B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 17:43:28 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so120535912pac.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 14:43:28 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id t5si26348950pgo.286.2016.11.01.14.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 14:43:27 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id 189so48035939pfz.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 14:43:27 -0700 (PDT)
Date: Tue, 1 Nov 2016 14:43:25 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] lkdtm: Do not use flush_icache_range() on user addresses
Message-ID: <20161101214325.GA75616@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Jerome Marchand <jmarchan@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Catalin Marinas <catalin.marinas@arm.com>

The flush_icache_range() API is meant to be used on kernel addresses
only as it may not have the infrastructure (exception entries) to handle
user memory faults.

The lkdtm execute_user_location() function tests the kernel execution of
user space addresses by mmap'ing an anonymous page, copying some code
together with cache maintenance and attempting to run it. However, the
cache maintenance step may fail because of the incorrect API usage
described above. The patch changes lkdtm to use access_process_vm() for
copying the code into user space which would take care of the necessary
cache maintenance.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
[kees: export access_process_vm() for module use]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
Since this now adds an export, we should probably delay this to v4.10.
(And I've fixed my build tests to actually do CONFIG_LKDTM=m instead of
lying to me.)
---
 drivers/misc/lkdtm_perms.c | 7 +++++--
 mm/memory.c                | 1 +
 mm/nommu.c                 | 1 +
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/misc/lkdtm_perms.c b/drivers/misc/lkdtm_perms.c
index 45f1c0f96612..c7635a79341f 100644
--- a/drivers/misc/lkdtm_perms.c
+++ b/drivers/misc/lkdtm_perms.c
@@ -60,15 +60,18 @@ static noinline void execute_location(void *dst, bool write)
 
 static void execute_user_location(void *dst)
 {
+	int copied;
+
 	/* Intentionally crossing kernel/user memory boundary. */
 	void (*func)(void) = dst;
 
 	pr_info("attempting ok execution at %p\n", do_nothing);
 	do_nothing();
 
-	if (copy_to_user((void __user *)dst, do_nothing, EXEC_SIZE))
+	copied = access_process_vm(current, (unsigned long)dst, do_nothing,
+				   EXEC_SIZE, FOLL_WRITE);
+	if (copied < EXEC_SIZE)
 		return;
-	flush_icache_range((unsigned long)dst, (unsigned long)dst + EXEC_SIZE);
 	pr_info("attempting bad execution at %p\n", func);
 	func();
 }
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..485f12d8ad5c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3966,6 +3966,7 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(access_process_vm);
 
 /*
  * Print the name of a VMA.
diff --git a/mm/nommu.c b/mm/nommu.c
index db5fd1795298..0990145054b5 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1878,6 +1878,7 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
 	mmput(mm);
 	return len;
 }
+EXPORT_SYMBOL_GPL(access_process_vm);
 
 /**
  * nommu_shrink_inode_mappings - Shrink the shared mappings on an inode
-- 
2.7.4


-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
