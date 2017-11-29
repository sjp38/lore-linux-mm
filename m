Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 229F46B0282
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:42:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so2584458pfd.6
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:42:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d21sor563392pgn.30.2017.11.29.06.42.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 06:42:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
Date: Wed, 29 Nov 2017 15:42:19 +0100
Message-Id: <20171129144219.22867-3-mhocko@kernel.org>
In-Reply-To: <20171129144219.22867-1-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

From: Michal Hocko <mhocko@suse.com>

Both load_elf_interp and load_elf_binary rely on elf_map to map segments
on a controlled address and they use MAP_FIXED to enforce that. This is
however dangerous thing prone to silent data corruption which can be
even exploitable. Let's take CVE-2017-1000253 as an example. At the time
(before eab09532d400 ("binfmt_elf: use ELF_ET_DYN_BASE only for PIE"))
ELF_ET_DYN_BASE was at TASK_SIZE / 3 * 2 which is not that far away from
the stack top on 32b (legacy) memory layout (only 1GB away). Therefore
we could end up mapping over the existing stack with some luck.

The issue has been fixed since then (a87938b2e246 ("fs/binfmt_elf.c:
fix bug in loading of PIE binaries")), ELF_ET_DYN_BASE moved moved much
further from the stack (eab09532d400 and later by c715b72c1ba4 ("mm:
revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")) and excessive
stack consumption early during execve fully stopped by da029c11e6b1
("exec: Limit arg stack to at most 75% of _STK_LIM"). So we should be
safe and any attack should be impractical. On the other hand this is
just too subtle assumption so it can break quite easily and hard to
spot.

I believe that the MAP_FIXED usage in load_elf_binary (et. al) is still
fundamentally dangerous. Moreover it shouldn't be even needed. We are
at the early process stage and so there shouldn't be unrelated mappings
(except for stack and loader) existing so mmap for a given address
should succeed even without MAP_FIXED. Something is terribly wrong if
this is not the case and we should rather fail than silently corrupt the
underlying mapping.

Address this issue by changing MAP_FIXED to the newly added
MAP_FIXED_SAFE. This will mean that mmap will fail if there is an
existing mapping clashing with the requested one without clobbering it.

Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Cc: Joel Stanley <joel@jms.id.au>
Acked-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/metag/kernel/process.c |  6 +++++-
 fs/binfmt_elf.c             | 12 ++++++++----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
index 0909834c83a7..867c8d0a5fb4 100644
--- a/arch/metag/kernel/process.c
+++ b/arch/metag/kernel/process.c
@@ -399,7 +399,7 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
 	tcm_tag = tcm_lookup_tag(addr);
 
 	if (tcm_tag != TCM_INVALID_TAG)
-		type &= ~MAP_FIXED;
+		type &= ~(MAP_FIXED | MAP_FIXED_SAFE);
 
 	/*
 	* total_size is the size of the ELF (interpreter) image.
@@ -417,6 +417,10 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
 	} else
 		map_addr = vm_mmap(filep, addr, size, prot, type, off);
 
+	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
+		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
+				task_pid_nr(current), tsk->comm, (void*)addr);
+
 	if (!BAD_ADDR(map_addr) && tcm_tag != TCM_INVALID_TAG) {
 		struct tcm_allocation *tcm;
 		unsigned long tcm_addr;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 73b01e474fdc..5916d45f64a7 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -372,6 +372,10 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
 	} else
 		map_addr = vm_mmap(filep, addr, size, prot, type, off);
 
+	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
+		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
+				task_pid_nr(current), current->comm, (void*)addr);
+
 	return(map_addr);
 }
 
@@ -569,7 +573,7 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
 				elf_prot |= PROT_EXEC;
 			vaddr = eppnt->p_vaddr;
 			if (interp_elf_ex->e_type == ET_EXEC || load_addr_set)
-				elf_type |= MAP_FIXED;
+				elf_type |= MAP_FIXED_SAFE;
 			else if (no_base && interp_elf_ex->e_type == ET_DYN)
 				load_addr = -vaddr;
 
@@ -930,7 +934,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		 * the ET_DYN load_addr calculations, proceed normally.
 		 */
 		if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
-			elf_flags |= MAP_FIXED;
+			elf_flags |= MAP_FIXED_SAFE;
 		} else if (loc->elf_ex.e_type == ET_DYN) {
 			/*
 			 * This logic is run once for the first LOAD Program
@@ -966,7 +970,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
 				load_bias = ELF_ET_DYN_BASE;
 				if (current->flags & PF_RANDOMIZE)
 					load_bias += arch_mmap_rnd();
-				elf_flags |= MAP_FIXED;
+				elf_flags |= MAP_FIXED_SAFE;
 			} else
 				load_bias = 0;
 
@@ -1223,7 +1227,7 @@ static int load_elf_library(struct file *file)
 			(eppnt->p_filesz +
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)),
 			PROT_READ | PROT_WRITE | PROT_EXEC,
-			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
+			MAP_FIXED_SAFE | MAP_PRIVATE | MAP_DENYWRITE,
 			(eppnt->p_offset -
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
 	if (error != ELF_PAGESTART(eppnt->p_vaddr))
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
