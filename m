Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LKgxww015031
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:42:59 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKgwsc210940
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:42:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKgw2K027036
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:42:58 -0600
Subject: [RFC][PATCH 7/9] pagewalk: add handler for empty ranges
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:56 -0700
References: <20070821204248.0F506A29@kernel>
In-Reply-To: <20070821204248.0F506A29@kernel>
Message-Id: <20070821204256.140D32D2@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There's a pretty good deal of complexity surrounding dealing
with a sparse address space in the /proc/<pid>/pagemap code.
We have the pm->next pointer to help indicate how far we've
walked in the pagetables.  We also attempt to fill empty
areas without vmas manually.

This code adds an extension to the mm_walk code: a new handler
for "empty" pte ranges.  Those are areas where there is no
pte page present.  This allows us to get rid of the code that
inspects VMAs or that trys to keep track of how much of the
pagemap we have filled.

Note that this truly does walk pte *holes*.  That isn't just
places where we have a pte_none().  It includes places where
there are any missing higher-level pagetable entries like
puds.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/include/linux/mm.h |    1 
 lxc-dave/lib/pagewalk.c     |   67 +++++++++++++++++++-------------------------
 2 files changed, 30 insertions(+), 38 deletions(-)

diff -puN include/linux/mm.h~pagewalk-empty-ranges include/linux/mm.h
--- lxc/include/linux/mm.h~pagewalk-empty-ranges	2007-08-21 13:30:53.000000000 -0700
+++ lxc-dave/include/linux/mm.h	2007-08-21 13:30:53.000000000 -0700
@@ -699,6 +699,7 @@ struct mm_walk {
 	int (*pud_entry)(pud_t *, unsigned long, unsigned long, void *);
 	int (*pmd_entry)(pmd_t *, unsigned long, unsigned long, void *);
 	int (*pte_entry)(pte_t *, unsigned long, unsigned long, void *);
+	int (*pte_hole) (unsigned long, unsigned long, void *);
 };
 
 int walk_page_range(struct mm_struct *, unsigned long addr, unsigned long end,
diff -puN lib/pagewalk.c~pagewalk-empty-ranges lib/pagewalk.c
--- lxc/lib/pagewalk.c~pagewalk-empty-ranges	2007-08-21 13:30:53.000000000 -0700
+++ lxc-dave/lib/pagewalk.c	2007-08-21 13:30:53.000000000 -0700
@@ -6,17 +6,13 @@ static int walk_pte_range(pmd_t *pmd, un
 			  struct mm_walk *walk, void *private)
 {
 	pte_t *pte;
-	int err;
+	int err = 0;
 
 	for (pte = pte_offset_map(pmd, addr); addr != end;
 	     addr += PAGE_SIZE, pte++) {
-		if (pte_none(*pte))
-			continue;
 		err = walk->pte_entry(pte, addr, addr, private);
-		if (err) {
-			pte_unmap(pte);
-			return err;
-		}
+		if (err)
+		       break;
 	}
 	pte_unmap(pte);
 	return 0;
@@ -27,25 +23,23 @@ static int walk_pmd_range(pud_t *pud, un
 {
 	pmd_t *pmd;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	for (pmd = pmd_offset(pud, addr); addr != end;
 	     pmd++, addr = next) {
 		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
+		if (pmd_none(*pmd)) {
+			err = walk->pte_hole(addr, next, private);
+		} else if (pmd_none_or_clear_bad(pmd))
 			continue;
-		if (walk->pmd_entry) {
+		if (!err && walk->pmd_entry)
 			err = walk->pmd_entry(pmd, addr, next, private);
-			if (err)
-				return err;
-		}
-		if (walk->pte_entry) {
+		if (!err && walk->pte_entry)
 			err = walk_pte_range(pmd, addr, next, walk, private);
-			if (err)
-				return err;
-		}
+		if (err)
+			break;
 	}
-	return 0;
+	return err;
 }
 
 static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
@@ -53,23 +47,21 @@ static int walk_pud_range(pgd_t *pgd, un
 {
 	pud_t *pud;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	for (pud = pud_offset(pgd, addr); addr != end;
 	     pud++, addr = next) {
 		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
+		if (pud_none(*pud)) {
+			err = walk->pte_hole(addr, next, private);
+		} else if (pud_none_or_clear_bad(pud))
 			continue;
-		if (walk->pud_entry) {
+		if (!err && walk->pud_entry)
 			err = walk->pud_entry(pud, addr, next, private);
-			if (err)
-				return err;
-		}
-		if (walk->pmd_entry || walk->pte_entry) {
+		if (!err && (walk->pmd_entry || walk->pte_entry))
 			err = walk_pmd_range(pud, addr, next, walk, private);
-			if (err)
-				return err;
-		}
+		if (err)
+			return err;
 	}
 	return 0;
 }
@@ -91,23 +83,22 @@ int walk_page_range(struct mm_struct *mm
 {
 	pgd_t *pgd;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	for (pgd = pgd_offset(mm, addr); addr != end;
 	     pgd++, addr = next) {
 		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
+		if (pgd_none(*pgd)) {
+			err = walk->pte_hole(addr, next, private);
+		} else if (pgd_none_or_clear_bad(pgd))
 			continue;
-		if (walk->pgd_entry) {
+		if (!err && walk->pgd_entry)
 			err = walk->pgd_entry(pgd, addr, next, private);
-			if (err)
-				return err;
-		}
-		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry) {
+		if (!err &&
+		    (walk->pud_entry || walk->pmd_entry || walk->pte_entry))
 			err = walk_pud_range(pgd, addr, next, walk, private);
-			if (err)
-				return err;
-		}
+		if (err)
+			return err;
 	}
 	return 0;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
