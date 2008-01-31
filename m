Date: Thu, 31 Jan 2008 14:01:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: mmu_notifier: close hole in fork
In-Reply-To: <20080131123118.GK7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801311355260.27804@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com>
 <20080131123118.GK7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Talking to Robin and Jack we found taht we still have a hole during fork. 
Fork may set a pte writeprotect. At that point the remote pte are 
not marked readonly(!). Remote writes may occur to pages that are marked 
readonly locally without this patch.

mmu_notifier: Provide invalidate_range on fork

On fork we change ptes in cow mappings to readonly. This means we must
invalidate the ptes so that they are reestablished later with proper
permission.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/memory.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-01-31 13:42:35.000000000 -0800
+++ linux-2.6/mm/memory.c	2008-01-31 13:47:31.000000000 -0800
@@ -602,6 +602,9 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_begin, src_mm, addr, end, 0);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -612,6 +615,9 @@ int copy_page_range(struct mm_struct *ds
 						vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_end, src_mm, 0);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
