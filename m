Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEAF6B0253
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:57:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id f133so340528itb.1
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:57:46 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l189si6803953ioa.68.2018.01.18.17.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 17:57:44 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w0J1ph33140488
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:44 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2fk4pg0eqm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:44 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w0J1vgCT011758
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:43 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w0J1vgpc004014
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:42 GMT
From: William Kucharski <william.kucharski@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: [PATCH] mm: Correct comments regarding do_fault_around()
Message-Id: <054BC126-FA7A-46AC-8BF0-7AC98B41FA0A@oracle.com>
Date: Thu, 18 Jan 2018 18:57:41 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


There are multiple comments surrounding do_fault_around() that mention
fault_around_pages() and fault_around_mask(), two routines that do not
exist.  These comments should be reworded to reference =
fault_around_bytes,
the value which is used to determine how much do_fault_around() will
attempt to read when processing a fault.

Signed-off-by: William Kucharski <william.kucharski@oracle.com>
Reviewed-by: Larry Bassel <larry.bassel@oracle.com>
---
 memory.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..3f2f158f1a43 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3479,9 +3479,8 @@ static int fault_around_bytes_get(void *data, u64 =
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
@@ -3524,13 +3523,14 @@ late_initcall(fault_around_debugfs);
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
@@ -3547,8 +3547,8 @@ static int do_fault_around(struct vm_fault *vmf)
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
