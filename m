Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BAE826B0033
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 18:41:44 -0400 (EDT)
Message-Id: <20130604172132.425514485@1wt.eu>
Date: Tue, 04 Jun 2013 19:22:21 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: [ 051/184] x86/mm: Check if PUD is large when validating a
In-Reply-To: <58df134a4b98edf5b0073e2e1e988fe6@local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>

2.6.32-longterm review patch.  If anyone has any objections, please let me know.

------------------
 kernel address

From: Mel Gorman <mgorman@suse.de>

commit 0ee364eb316348ddf3e0dfcd986f5f13f528f821 upstream.

A user reported the following oops when a backup process reads
/proc/kcore:

 BUG: unable to handle kernel paging request at ffffbb00ff33b000
 IP: [<ffffffff8103157e>] kern_addr_valid+0xbe/0x110
 [...]

 Call Trace:
  [<ffffffff811b8aaa>] read_kcore+0x17a/0x370
  [<ffffffff811ad847>] proc_reg_read+0x77/0xc0
  [<ffffffff81151687>] vfs_read+0xc7/0x130
  [<ffffffff811517f3>] sys_read+0x53/0xa0
  [<ffffffff81449692>] system_call_fastpath+0x16/0x1b

Investigation determined that the bug triggered when reading
system RAM at the 4G mark. On this system, that was the first
address using 1G pages for the virt->phys direct mapping so the
PUD is pointing to a physical address, not a PMD page.

The problem is that the page table walker in kern_addr_valid() is
not checking pud_large() and treats the physical address as if
it was a PMD.  If it happens to look like pmd_none then it'll
silently fail, probably returning zeros instead of real data. If
the data happens to look like a present PMD though, it will be
walked resulting in the oops above.

This patch adds the necessary pud_large() check.

Unfortunately the problem was not readily reproducible and now
they are running the backup program without accessing
/proc/kcore so the patch has not been validated but I think it
makes sense.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.coM>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20130211145236.GX21389@suse.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 arch/x86/include/asm/pgtable.h | 5 +++++
 arch/x86/mm/init_64.c          | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index af6fd36..1cce9d2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -130,6 +130,11 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 	return (pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+static inline unsigned long pud_pfn(pud_t pud)
+{
+	return (pud_val(pud) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7d095ad..ccbc61b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -839,6 +839,9 @@ int kern_addr_valid(unsigned long addr)
 	if (pud_none(*pud))
 		return 0;
 
+	if (pud_large(*pud))
+		return pfn_valid(pud_pfn(*pud));
+
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return 0;
-- 
1.7.12.2.21.g234cd45.dirty



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
