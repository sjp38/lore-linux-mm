Date: Fri, 27 Jun 2003 11:13:19 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.73-mm1] Make sure truncate fix has no race
Message-ID: <69440000.1056730399@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1873729384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========1873729384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Paul McKenney pointed out that reading the truncate sequence number in
do_no_page might not be entirely safe if the ->nopage callout takes no
locks.  The simple solution is to move the read before the unlock of
page_table_lock.  Here's a patch that does it.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1873729384==========
Content-Type: text/plain; charset=us-ascii; name="trunc-2.5.73-mm1-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="trunc-2.5.73-mm1-1.diff"; size=897

--- 2.5.73-mm1/mm/memory.c	2003-06-27 10:40:48.000000000 -0500
+++ 2.5.73-mm1-trunc/mm/memory.c	2003-06-27 10:47:10.000000000 -0500
@@ -1402,11 +1402,11 @@ do_no_page(struct mm_struct *mm, struct 
 		return do_anonymous_page(mm, vma, page_table,
 					pmd, write_access, address);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
 
 	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
-retry:
 	sequence = atomic_read(&mapping->truncate_count);
+	spin_unlock(&mm->page_table_lock);
+retry:
 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, 0);
 
 	/* no page was available -- either SIGBUS or OOM */
@@ -1441,6 +1441,7 @@ retry:
 	 * retry getting the page.
 	 */
 	if (unlikely(sequence != atomic_read(&mapping->truncate_count))) {
+		sequence = atomic_read(&mapping->truncate_count);
 		spin_unlock(&mm->page_table_lock);
 		page_cache_release(new_page);
 		goto retry;

--==========1873729384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
