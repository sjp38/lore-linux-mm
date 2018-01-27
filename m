Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7A86B0033
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 22:25:30 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id a81so1701299ywe.3
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 19:25:30 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b10si2028622ybe.74.2018.01.26.19.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 19:25:29 -0800 (PST)
From: William Kucharski <william.kucharski@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.9\))
Subject: [PATCH v2] mm: Correct comments regarding do_fault_around() 
Message-Id: <302D0B14-C7E9-44C6-8BED-033F9ACBD030@oracle.com>
Date: Fri, 26 Jan 2018 20:25:25 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

mm: Correct comments regarding do_fault_around()

There are multiple comments surrounding do_fault_around that memtion
fault_around_pages() and fault_around_mask(), two routines that do not
exist.  These comments should be reworded to reference =
fault_around_bytes,
the value which is used to determine how much do_fault_around() will
attempt to read when processing a fault.

These comments should have been updated when fault_around_pages() and
fault_around_mask() were removed in commit
aecd6f44266c13b8709245b21ded2d19291ab070.

Signed-off-by: William Kucharski <william.kucharski@oracle.com>
Reviewed-by: Larry Bassel <larry.bassel@oracle.com>
---
 memory.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 793004608332..885dffe194f8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3485,9 +3485,8 @@ static int fault_around_bytes_get(void *data, u64 =
*val)
 }
=20
 /*
- * fault_around_pages() and fault_around_mask() expects =
fault_around_bytes
- * rounded down to nearest page order. It's what do_fault_around() =
expects to
- * see.
+ * fault_around_bytes must be rounded down to the nearest page order as =
it's
+ * what do_fault_around() expects to see.
  */
 static int fault_around_bytes_set(void *data, u64 val)
 {
@@ -3530,13 +3529,14 @@ late_initcall(fault_around_debugfs);
  * This function doesn't cross the VMA boundaries, in order to call =
map_pages()
  * only once.
  *
- * fault_around_pages() defines how many pages we'll try to map.
- * do_fault_around() expects it to return a power of two less than or =
equal to
- * PTRS_PER_PTE.
+ * fault_around_bytes defines how many bytes we'll try to map.
+ * do_fault_around() expects it to be set to a power of two less than =
or equal
+ * to PTRS_PER_PTE.
  *
- * The virtual address of the area that we map is naturally aligned to =
the
- * fault_around_pages() value (and therefore to page order).  This way =
it's
- * easier to guarantee that we don't cross page table boundaries.
+ * The virtual address of the area that we map is naturally aligned to
+ * fault_around_bytes rounded down to the machine page size
+ * (and therefore to page order).  This way it's easier to guarantee
+ * that we don't cross page table boundaries.
  */
 static int do_fault_around(struct vm_fault *vmf)
 {
@@ -3553,8 +3553,8 @@ static int do_fault_around(struct vm_fault *vmf)
 	start_pgoff -=3D off;
=20
 	/*
-	 *  end_pgoff is either end of page table or end of vma
-	 *  or fault_around_pages() from start_pgoff, depending what is =
nearest.
+	 *  end_pgoff is either the end of the page table, the end of
+	 *  the vma or nr_pages from start_pgoff, depending what is =
nearest.
 	 */
 	end_pgoff =3D start_pgoff -
 		((vmf->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
