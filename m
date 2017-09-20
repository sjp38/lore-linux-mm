Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C45F6B02B3
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:52:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so7449537pgh.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:52:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t5sor1219613plj.93.2017.09.20.13.52.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:52:57 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 24/31] fork: Define usercopy region in mm_struct slab caches
Date: Wed, 20 Sep 2017 13:45:30 -0700
Message-Id: <1505940337-79069-25-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
mm_struct slab caches in which userspace copy operations are allowed.
Only the auxv field is copied to userspace.

cache object allocation:
    kernel/fork.c:
        #define allocate_mm()     (kmem_cache_alloc(mm_cachep, GFP_KERNEL))

        dup_mm():
            ...
            mm = allocate_mm();

        copy_mm(...):
            ...
            dup_mm();

        copy_process(...):
            ...
            copy_mm(...)

        _do_fork(...):
            ...
            copy_process(...)

example usage trace:

    fs/binfmt_elf.c:
        create_elf_tables(...):
            ...
            elf_info = (elf_addr_t *)current->mm->saved_auxv;
            ...
            copy_to_user(..., elf_info, ei_index * sizeof(elf_addr_t))

        load_elf_binary(...):
            ...
            create_elf_tables(...);

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split patch, provide usage trace]
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Rik van Riel <riel@redhat.com>
---
 kernel/fork.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 10646182440f..dc1437f8b702 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2207,9 +2207,11 @@ void __init proc_caches_init(void)
 	 * maximum number of CPU's we can ever have.  The cpumask_allocation
 	 * is at the end of the structure, exactly for that reason.
 	 */
-	mm_cachep = kmem_cache_create("mm_struct",
+	mm_cachep = kmem_cache_create_usercopy("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			offsetof(struct mm_struct, saved_auxv),
+			sizeof_field(struct mm_struct, saved_auxv),
 			NULL);
 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
 	mmap_init();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
