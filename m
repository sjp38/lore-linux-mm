Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA18167
	for <linux-mm@kvack.org>; Fri, 27 Sep 2002 23:10:04 -0700 (PDT)
Message-ID: <3D9547BC.432C018@digeo.com>
Date: Fri, 27 Sep 2002 23:10:04 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: mremap() pte allocation atomicity error
References: <20020928052813.GY22942@holomorphy.com> <3D95442E.C0959F4A@digeo.com> <20020928060450.GW3530@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Fri, Sep 27, 2002 at 10:54:54PM -0700, Andrew Morton wrote:
> > A simple fix would be to drop the atomic kmap of the source pte
> > and take it again after the alloc_one_pte_map() call.
> > Can you think of a more efficient way?
> 
> Not one that isn't highly invasive, no. This is what I had in mind
> for the easy fix.
> 

OK.   kmap_atomics are pretty darn quick, but it might be better
to take a peek to see if the pgd and pmd are present, and only
drop the kmap if not.

Care to eyeball this?  I haven't tested it yet.

 mm/mremap.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+)

--- 2.5.39/mm/mremap.c~move_one_page_fix	Fri Sep 27 22:59:04 2002
+++ 2.5.39-akpm/mm/mremap.c	Fri Sep 27 23:05:16 2002
@@ -53,6 +53,20 @@ end:
 	return pte;
 }
 
+static inline int page_table_present(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_none(*pgd))
+		return 0;
+	pmd = pmd_offset(pgd, addr);
+	if (pmd == NULL)
+		return 0;
+	return 1;
+}
+
 static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned long addr)
 {
 	pmd_t * pmd;
@@ -98,7 +112,18 @@ static int move_one_page(struct vm_area_
 	spin_lock(&mm->page_table_lock);
 	src = get_one_pte_map_nested(mm, old_addr);
 	if (src) {
+		/*
+		 * Look to see whether alloc_one_pte_map needs to perform a
+		 * memory allocation.  If it does then we need to drop the
+		 * atomic kmap
+		 */
+		if (!page_table_present(mm, new_addr)) {
+			pte_unmap_nested(src);
+			src = NULL;
+		}
 		dst = alloc_one_pte_map(mm, new_addr);
+		if (src == NULL)
+			src = get_one_pte_map_nested(mm, old_addr);
 		error = copy_one_pte(mm, src, dst);
 		pte_unmap_nested(src);
 		pte_unmap(dst);

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
