Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1376B0008
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:25:23 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id z11so9552989plo.21
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:25:23 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i4si4033040pfa.152.2018.02.15.05.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:25:21 -0800 (PST)
Subject: [PATCH 3/3] x86/pti: enable global pages for shared areas
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 15 Feb 2018 05:20:57 -0800
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
In-Reply-To: <20180215132053.6C9B48C8@viggo.jf.intel.com>
Message-Id: <20180215132057.054C1DC1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The entry/exit text and cpu_entry_area are mapped into userspace and
the kernel.  But, they are not _PAGE_GLOBAL.  This creates unnecessary
TLB misses.

Add the _PAGE_GLOBAL flag for these areas.

After this patch, we can see that "GLB" shows up in each copy of the
page tables, that we have the same number of global entries in each
and that they are the *same* entries.

# grep -c GLB /sys/kernel/debug/page_tables/*
/sys/kernel/debug/page_tables/current_kernel:11
/sys/kernel/debug/page_tables/current_user:11
/sys/kernel/debug/page_tables/kernel:11

# for f in `ls /sys/kernel/debug/page_tables/`; do grep GLB /sys/kernel/debug/page_tables/$f > $f.GLB; done
# md5sum *.GLB
9caae8ad6a1fb53aca2407ec037f612d  current_kernel.GLB
9caae8ad6a1fb53aca2407ec037f612d  current_user.GLB
9caae8ad6a1fb53aca2407ec037f612d  kernel.GLB

A quick visual audit also shows that all the entries make sense.
0xfffffe0000000000 is the cpu_entry_area and 0xffffffff81c00000
is the entry/exit text:

# grep -c GLB /sys/kernel/debug/page_tables/current_user
0xfffffe0000000000-0xfffffe0000002000           8K     ro                 GLB NX pte
0xfffffe0000002000-0xfffffe0000003000           4K     RW                 GLB NX pte
0xfffffe0000003000-0xfffffe0000006000          12K     ro                 GLB NX pte
0xfffffe0000006000-0xfffffe0000007000           4K     ro                 GLB x  pte
0xfffffe0000007000-0xfffffe000000d000          24K     RW                 GLB NX pte
0xfffffe000002d000-0xfffffe000002e000           4K     ro                 GLB NX pte
0xfffffe000002e000-0xfffffe000002f000           4K     RW                 GLB NX pte
0xfffffe000002f000-0xfffffe0000032000          12K     ro                 GLB NX pte
0xfffffe0000032000-0xfffffe0000033000           4K     ro                 GLB x  pte
0xfffffe0000033000-0xfffffe0000039000          24K     RW                 GLB NX pte
0xffffffff81c00000-0xffffffff81e00000           2M     ro         PSE     GLB x  pmd

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
---

 b/arch/x86/mm/cpu_entry_area.c |    7 +++++++
 b/arch/x86/mm/pti.c            |    9 ++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff -puN arch/x86/mm/cpu_entry_area.c~kpti-why-no-global arch/x86/mm/cpu_entry_area.c
--- a/arch/x86/mm/cpu_entry_area.c~kpti-why-no-global	2018-02-13 15:17:56.735210059 -0800
+++ b/arch/x86/mm/cpu_entry_area.c	2018-02-13 15:17:56.740210059 -0800
@@ -28,6 +28,13 @@ void cea_set_pte(void *cea_vaddr, phys_a
 {
 	unsigned long va = (unsigned long) cea_vaddr;
 
+	/*
+	 * The cpu_entry_area is shared between the user and kernel
+	 * page tables.  All of its ptes can safely be global.
+	 */
+	if (boot_cpu_has(X86_FEATURE_PGE))
+		pgprot_val(flags) |= _PAGE_GLOBAL;
+
 	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
 }
 
diff -puN arch/x86/mm/pti.c~kpti-why-no-global arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~kpti-why-no-global	2018-02-13 15:17:56.737210059 -0800
+++ b/arch/x86/mm/pti.c	2018-02-13 15:17:56.740210059 -0800
@@ -300,6 +300,13 @@ pti_clone_pmds(unsigned long start, unsi
 			return;
 
 		/*
+		 * Setting 'target_pmd' below creates a mapping in both
+		 * the user and kernel page tables.  It is effectively
+		 * global, so set it as global in both copies.
+		 */
+		*pmd = pmd_set_flags(*pmd, _PAGE_GLOBAL);
+
+		/*
 		 * Copy the PMD.  That is, the kernelmode and usermode
 		 * tables will share the last-level page tables of this
 		 * address range
@@ -348,7 +355,7 @@ static void __init pti_clone_entry_text(
 {
 	pti_clone_pmds((unsigned long) __entry_text_start,
 			(unsigned long) __irqentry_text_end,
-		       _PAGE_RW | _PAGE_GLOBAL);
+		       _PAGE_RW);
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
