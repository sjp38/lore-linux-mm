Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6616B0272
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z24so9338507pgu.20
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc11sor5456475plb.44.2018.01.09.12.57.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:09 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 26/36] fork: Define usercopy region in mm_struct slab caches
Date: Tue,  9 Jan 2018 12:55:55 -0800
Message-Id: <1515531365-37423-27-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

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
index 432eadf6b58c..82f2a0441d3b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2225,9 +2225,11 @@ void __init proc_caches_init(void)
 	 * maximum number of CPU's we can ever have.  The cpumask_allocation
 	 * is at the end of the structure, exactly for that reason.
 	 */
-	mm_cachep = kmem_cache_create("mm_struct",
+	mm_cachep = kmem_cache_create_usercopy("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT,
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
