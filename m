Date: Fri, 1 Feb 2008 11:13:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080201103221.GH26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0802011105030.18163@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com>
 <20080201042408.GG26420@sgi.com> <Pine.LNX.4.64.0801312042500.20675@schroedinger.engr.sgi.com>
 <20080201103221.GH26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Robin Holt wrote:

> Maybe I haven't looked closely enough, but let's start with some common
> assumptions.  Looking at do_wp_page from 2.6.24 (I believe that is what
> my work area is based upon).  On line 1559, the function begins being
> declared.

Aah I looked at the wrong file.

> On lines 1614 and 1630, we do "goto unlock" where the _end callout is
> soon made.  The _begin callout does not come until after those branches
> have been taken (occurs on line 1648).

There are actually two cases...

---
 mm/memory.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-02-01 11:04:21.000000000 -0800
+++ linux-2.6/mm/memory.c	2008-02-01 11:12:12.000000000 -0800
@@ -1611,8 +1611,10 @@ static int do_wp_page(struct mm_struct *
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
 			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
-				goto unlock;
+			if (!pte_same(*page_table, orig_pte)) {
+				pte_unmap_unlock(page_table, ptl);
+				goto check_dirty;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -1628,7 +1630,8 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
-		goto unlock;
+		pte_unmap_unlock(page_table, ptl);
+		goto check_dirty;
 	}
 
 	/*
@@ -1684,10 +1687,10 @@ gotten:
 		page_cache_release(new_page);
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
 	pte_unmap_unlock(page_table, ptl);
 	mmu_notifier(invalidate_range_end, mm,
 				address, address + PAGE_SIZE, 0);
+check_dirty:
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
