Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9E46B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 04:20:12 -0500 (EST)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id n0S9K8Qk127064
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:20:08 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0S9K8Le2777284
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:20:08 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0S9K7s6012296
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:20:08 GMT
Date: Wed, 28 Jan 2009 10:20:04 +0100
From: Carsten Otte <cotte@de.ibm.com>
Subject: PATCH do_wp_page: fix regression with execute in place
Message-ID: <20090128102004.5cd8eb9a@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch fixes do_wp_page for VM_MIXEDMAP mappings. In case
pfn_valid returns 0 for a pfn at the beginning of do_wp_page,
and the mapping is not shared writable, the code branches to
label gotten with old_page == NULL. In case the vma is locked
(vma->vm_flags & VM_LOCKED), lock_page, clear_page_mlock, and
unlock_page try to access old_page.
This patch checks, whether old_page is valid before it is
dereferenced.
The regression was introduced with git commit b291f000

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
diff --git a/mm/memory.c b/mm/memory.c
index 22bfa7a..baa999e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1999,7 +1999,7 @@ gotten:
         * Don't let another task, with possibly unlocked vma,
         * keep the mlocked page.
         */
-       if (vma->vm_flags & VM_LOCKED) {
+       if ((vma->vm_flags & VM_LOCKED) && old_page) {
                lock_page(old_page);    /* for LRU manipulation */
                clear_page_mlock(old_page);
                unlock_page(old_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
