Date: Tue, 14 Nov 2006 15:03:39 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: [hugepage] Check for brk() entering a hugepage region
Message-ID: <20061114040339.GK13060@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew, please apply.  I could have sworn I checked ages ago, and
thought that sys_brk() eventually called do_mmap_pgoff() which would
do the necessary checks.  Can't find any evidence of such a change
though, so either I was just blind at the time, or it happened before
the changeover to git.

Unlike mmap(), the codepath for brk() creates a vma without first
checking that it doesn't touch a region exclusively reserved for
hugepages.  On powerpc, this can allow it to create a normal page vma
in a hugepage region, causing oopses and other badness.

This patch adds a test to prevent this.  With this patch, brk() will
simply fail if it attempts to move the break into a hugepage reserved
region.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Index: working-2.6/mm/mmap.c
===================================================================
--- working-2.6.orig/mm/mmap.c	2006-11-14 14:03:53.000000000 +1100
+++ working-2.6/mm/mmap.c	2006-11-14 14:05:25.000000000 +1100
@@ -1880,6 +1880,10 @@ unsigned long do_brk(unsigned long addr,
 	if ((addr + len) > TASK_SIZE || (addr + len) < addr)
 		return -EINVAL;
 
+	error = is_hugepage_only_range(current->mm, addr, len);
+	if (error)
+		return error;
+
 	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
 	error = arch_mmap_check(addr, len, flags);

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
