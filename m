Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j7HJWugB578034
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:32:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJWXKM527392
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 13:32:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJWqZU016087
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 13:32:55 -0600
Subject: Re: [PATCH 1/4] x86-pte_huge
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1124306286.5879.20.camel@localhost>
References: <1124304966.3139.37.camel@localhost.localdomain>
	 <1124305384.3139.39.camel@localhost.localdomain>
	 <1124306286.5879.20.camel@localhost>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 14:27:31 -0500
Message-Id: <1124306851.3139.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 12:18 -0700, Dave Hansen wrote:
> Looks like a little whitespace issue.  Probably just tabs vs. spaces.

Ughh, don't know how that slipped in.

Fixed whitespace issue in asm-x86_64/pgtable.h

Initial Post (Wed, 17 Aug 2005)

This patch adds a macro pte_huge(pte) for i386/x86_64  which is needed by a
patch later in the series.  Instead of repeating (_PAGE_PRESENT | _PAGE_PSE),
I've added __LARGE_PTE to i386 to match x86_64.

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 asm-i386/pgtable.h   |    4 +++-
 asm-x86_64/pgtable.h |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)
diff -upN reference/include/asm-i386/pgtable.h current/include/asm-i386/pgtable.h
--- reference/include/asm-i386/pgtable.h
+++ current/include/asm-i386/pgtable.h
@@ -215,11 +215,13 @@ extern unsigned long pg0[];
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
+#define __LARGE_PTE (_PAGE_PSE | _PAGE_PRESENT)
 static inline int pte_user(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_read(pte_t pte)		{ return (pte).pte_low & _PAGE_USER; }
 static inline int pte_dirty(pte_t pte)		{ return (pte).pte_low & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
+static inline int pte_huge(pte_t pte)		{ return ((pte).pte_low & __LARGE_PTE) == __LARGE_PTE; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -236,7 +238,7 @@ static inline pte_t pte_mkexec(pte_t pte
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte_low |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
-static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= _PAGE_PRESENT | _PAGE_PSE; return pte; }
+static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= __LARGE_PTE; return pte; }
 
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
diff -upN reference/include/asm-x86_64/pgtable.h current/include/asm-x86_64/pgtable.h
--- reference/include/asm-x86_64/pgtable.h
+++ current/include/asm-x86_64/pgtable.h
@@ -247,6 +247,7 @@ static inline pte_t pfn_pte(unsigned lon
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
+#define __LARGE_PTE (_PAGE_PSE|_PAGE_PRESENT)
 static inline int pte_user(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
 extern inline int pte_read(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
 extern inline int pte_exec(pte_t pte)		{ return pte_val(pte) & _PAGE_USER; }
@@ -254,8 +255,8 @@ extern inline int pte_dirty(pte_t pte)		
 extern inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 extern inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_huge(pte_t pte)		{ return (pte_val(pte) & __LARGE_PTE) == __LARGE_PTE; }
 
-#define __LARGE_PTE (_PAGE_PSE|_PAGE_PRESENT)
 extern inline pte_t pte_rdprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 extern inline pte_t pte_exprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 extern inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
