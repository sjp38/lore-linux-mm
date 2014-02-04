Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DA0366B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 06:44:52 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so12477864wgh.11
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 03:44:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lw9si11689868wjb.29.2014.02.04.03.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 03:44:51 -0800 (PST)
Date: Tue, 4 Feb 2014 11:44:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] Subject: [PATCH] xen: Properly account for _PAGE_NUMA during
 xen pte translations
Message-ID: <20140204114445.GM6732@suse.de>
References: <20140122032045.GA22182@falcon.amazon.com>
 <20140122050215.GC9931@konrad-lan.dumpdata.com>
 <20140122072914.GA9283@orcus.uplinklabs.net>
 <52DFD5DB.6060603@iogearbox.net>
 <CAEr7rXhJf1tf2KUErsGgUyYNUpVwLYD=fKUf8aPm0Dcg21MuNQ@mail.gmail.com>
 <20140122203337.GA31908@orcus.uplinklabs.net>
 <CAEr7rXjge6rKzxbwy+0A6-5YhVZL9WGmaLrDYbE8H5hrtwq_4A@mail.gmail.com>
 <20140124133830.GU4963@suse.de>
 <CAEr7rXjmVp-F88zQnc4a2tSzBAJFshzR0FPkOBdo1jbQLOv+2A@mail.gmail.com>
 <CAEr7rXgCoYW7O0E38YGCThUKgmxYFfLfYP-x_KSzVBLOCiHeDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEr7rXgCoYW7O0E38YGCThUKgmxYFfLfYP-x_KSzVBLOCiHeDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: Steven Noonan <steven@uplinklabs.net>, Andrew Morton <akpm@linux-foundation.org>, George Dunlap <george.dunlap@eu.citrix.com>, Dario Faggioli <dario.faggioli@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Elena Ufimtseva <ufimtseva@gmail.com>, Linux Kernel mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, xen-devel <xen-devel@lists.xenproject.org>

Steven Noonan forwarded a users report where they had a problem starting
vsftpd on a Xen paravirtualized guest, with this in dmesg:

[   60.654862] BUG: Bad page map in process vsftpd  pte:8000000493b88165 pmd:e9cc01067
[   60.654876] page:ffffea00124ee200 count:0 mapcount:-1 mapping:     (null) index:0x0
[   60.654879] page flags: 0x2ffc0000000014(referenced|dirty)
[   60.654885] addr:00007f97eea74000 vm_flags:00100071 anon_vma:ffff880e98f80380 mapping:          (null) index:7f97eea74
[   60.654890] CPU: 4 PID: 587 Comm: vsftpd Not tainted 3.12.7-1-ec2 #1
[   60.654893]  ffff880e9cc6ec38 ffff880e9cc61ca0 ffffffff814c763b 00007f97eea74000
[   60.654900]  ffff880e9cc61ce8 ffffffff8116784e 0000000000000000 0000000000000000
[   60.654906]  ffff880e9cc013a0 ffffea00124ee200 00007f97eea75000 ffff880e9cc61e10
[   60.654912] Call Trace:
[   60.654921]  [<ffffffff814c763b>] dump_stack+0x45/0x56
[   60.654928]  [<ffffffff8116784e>] print_bad_pte+0x22e/0x250
[   60.654933]  [<ffffffff81169073>] unmap_single_vma+0x583/0x890
[   60.654938]  [<ffffffff8116a405>] unmap_vmas+0x65/0x90
[   60.654942]  [<ffffffff81173795>] exit_mmap+0xc5/0x170
[   60.654948]  [<ffffffff8105d295>] mmput+0x65/0x100
[   60.654952]  [<ffffffff81062983>] do_exit+0x393/0x9e0
[   60.654955]  [<ffffffff810630dc>] do_group_exit+0xcc/0x140
[   60.654959]  [<ffffffff81063164>] SyS_exit_group+0x14/0x20
[   60.654965]  [<ffffffff814d602d>] system_call_fastpath+0x1a/0x1f
[   60.654968] Disabling lock debugging due to kernel taint
[   60.655191] BUG: Bad rss-counter state mm:ffff880e9ca60580 idx:0 val:-1
[   60.655196] BUG: Bad rss-counter state mm:ffff880e9ca60580 idx:1 val:1

The issue could not be reproduced under an HVM instance with the same kernel,
so it appears to be exclusive to paravirtual Xen guests. He bisected the
problem to commit 1667918b (mm: numa: clear numa hinting information on
mprotect) that was also included in 3.12-stable.

The problem was related to how xen translates ptes because it was not
accounting for the _PAGE_NUMA bit. This patch splits pte_present to add
a pteval_present helper for use by xen so both bare metal and xen use
the same code when checking if a PTE is present.

[mgorman@suse.de: Wrote changelog, proposed minor modifications]
Reported-and-tested-by: Steven Noonan <steven@uplinklabs.net>
Signed-off-by: Elena Ufimtseva <ufimtseva@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org # 3.12+
---
 arch/x86/include/asm/pgtable.h | 14 ++++++++++++--
 arch/x86/xen/mmu.c             |  4 ++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbc8b12..19e3706 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -445,10 +445,20 @@ static inline int pte_same(pte_t a, pte_t b)
 	return a.pte == b.pte;
 }
 
+static inline int pteval_present(pteval_t pteval)
+{
+	/*
+	 * Yes Linus, _PAGE_PROTNONE == _PAGE_NUMA. Expressing it this
+	 * way clearly states that the intent is that a protnone and numa
+	 * hinting ptes are considered present for the purposes of
+	 * pagetable operations like zapping, protection changes, gup etc.
+	 */
+	return pteval & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_NUMA);
+}
+
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
-			       _PAGE_NUMA);
+	return pteval_present(pte_flags(a));
 }
 
 #define pte_accessible pte_accessible
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 2423ef0..256282e 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -365,7 +365,7 @@ void xen_ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
 /* Assume pteval_t is equivalent to all the other *val_t types. */
 static pteval_t pte_mfn_to_pfn(pteval_t val)
 {
-	if (val & _PAGE_PRESENT) {
+	if (pteval_present(val)) {
 		unsigned long mfn = (val & PTE_PFN_MASK) >> PAGE_SHIFT;
 		unsigned long pfn = mfn_to_pfn(mfn);
 
@@ -381,7 +381,7 @@ static pteval_t pte_mfn_to_pfn(pteval_t val)
 
 static pteval_t pte_pfn_to_mfn(pteval_t val)
 {
-	if (val & _PAGE_PRESENT) {
+	if (pteval_present(val)) {
 		unsigned long pfn = (val & PTE_PFN_MASK) >> PAGE_SHIFT;
 		pteval_t flags = val & PTE_FLAGS_MASK;
 		unsigned long mfn;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
