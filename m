Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06CB76B025F
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 17:48:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so119784735pfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:23 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id h80si120754pfj.46.2016.07.08.14.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id fi15so2629764pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 1/2] binfmt_elf: fix calculations for bss padding
Date: Fri,  8 Jul 2016 14:48:13 -0700
Message-Id: <1468014494-25291-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1468014494-25291-1-git-send-email-keescook@chromium.org>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A double-bug exists in the bss calculation code, where an overflow can
happen in the "last_bss - elf_bss" calculation, but vm_brk internally
aligns the argument, underflowing it, wrapping back around safe. We
shouldn't depend on these bugs staying in sync, so this cleans up the bss
padding handling to avoid the overflow.

This moves the bss padzero() before the last_bss > elf_bss case, since
the zero-filling of the ELF_PAGE should have nothing to do with the
relationship of last_bss and elf_bss: any trailing portion should be
zeroed, and a zero size is already handled by padzero().

Then it handles the math on elf_bss vs last_bss correctly. These need
to both be ELF_PAGE aligned to get the comparison correct, since that's
the expected granularity of the mappings. Since elf_bss already had
alignment-based padding happen in padzero(), the "start" of the new
vm_brk() should be moved forward as done in the original code. However,
since the "end" of the vm_brk() area will already become PAGE_ALIGNed in
vm_brk() then last_bss should get aligned here to avoid hiding it as a
side-effect.

Additionally makes a cosmetic change to the initial last_bss calculation
so it's easier to read in comparison to the load_addr calculation above it
(i.e. the only difference is p_filesz vs p_memsz).

Reported-by: Hector Marco-Gisbert <hecmargi@upv.es>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/binfmt_elf.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index e158b22ef32f..fe948933bcc5 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -605,28 +605,30 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
 			 * Do the same thing for the memory mapping - between
 			 * elf_bss and last_bss is the bss section.
 			 */
-			k = load_addr + eppnt->p_memsz + eppnt->p_vaddr;
+			k = load_addr + eppnt->p_vaddr + eppnt->p_memsz;
 			if (k > last_bss)
 				last_bss = k;
 		}
 	}
 
+	/*
+	 * Now fill out the bss section: first pad the last page from
+	 * the file up to the page boundary, and zero it from elf_bss
+	 * up to the end of the page.
+	 */
+	if (padzero(elf_bss)) {
+		error = -EFAULT;
+		goto out;
+	}
+	/*
+	 * Next, align both the file and mem bss up to the page size,
+	 * since this is where elf_bss was just zeroed up to, and where
+	 * last_bss will end after the vm_brk() below.
+	 */
+	elf_bss = ELF_PAGEALIGN(elf_bss);
+	last_bss = ELF_PAGEALIGN(last_bss);
+	/* Finally, if there is still more bss to allocate, do it. */
 	if (last_bss > elf_bss) {
-		/*
-		 * Now fill out the bss section.  First pad the last page up
-		 * to the page boundary, and then perform a mmap to make sure
-		 * that there are zero-mapped pages up to and including the
-		 * last bss page.
-		 */
-		if (padzero(elf_bss)) {
-			error = -EFAULT;
-			goto out;
-		}
-
-		/* What we have mapped so far */
-		elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
-
-		/* Map the last of the bss segment */
 		error = vm_brk(elf_bss, last_bss - elf_bss);
 		if (error)
 			goto out;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
