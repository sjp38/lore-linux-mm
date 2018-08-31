Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF5896B5920
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 17:49:33 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v52-v6so16213551qtc.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 14:49:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h14-v6si9910258qka.90.2018.08.31.14.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 14:49:32 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: allow get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
Date: Fri, 31 Aug 2018 17:48:48 -0400
Message-Id: <20180831214848.23676-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Maxime Coquelin <maxime.coquelin@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that
would not be waiting for userfaults before failing and it would hit on
a SIGBUS instead. Using get_user_pages_locked/unlocked instead will
allow get_mempolicy to allow userfaults to resolve the fault and fill
the hole, before grabbing the node id of the page.

Reported-by: Maxime Coquelin <maxime.coquelin@redhat.com>
Tested-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01f1a14facc4..a7f7f5415936 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -797,16 +797,19 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 	}
 }
 
-static int lookup_node(unsigned long addr)
+static int lookup_node(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
+	int locked = 1;
+	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
 	}
+	if (locked)
+		up_read(&mm->mmap_sem);
 	return err;
 }
 
@@ -817,7 +820,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	int err;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
-	struct mempolicy *pol = current->mempolicy;
+	struct mempolicy *pol = current->mempolicy, *pol_refcount = NULL;
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -857,7 +860,16 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(addr);
+			/*
+			 * Take a refcount on the mpol, lookup_node()
+			 * wil drop the mmap_sem, so after calling
+			 * lookup_node() only "pol" remains valid, "vma"
+			 * is stale.
+			 */
+			pol_refcount = pol;
+			vma = NULL;
+			mpol_get(pol);
+			err = lookup_node(mm, addr);
 			if (err < 0)
 				goto out;
 			*policy = err;
@@ -892,7 +904,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		up_read(&mm->mmap_sem);
+	if (pol_refcount)
+		mpol_put(pol_refcount);
 	return err;
 }
 
