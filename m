Message-ID: <420BB9E6.90303@sgi.com>
Date: Thu, 10 Feb 2005 13:45:42 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: migration cache bug?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(Resending so this gets posted to linux-mm):

Hirokazu and Marcello,

Here's some more information on this problem I am having with the
migration cache.

(The problem is that the test application is failing after it returns
from the system call that migrated some of its address space from node
0 to node 3 on my test box.  When the program touches the first page
in the range that was migrated, the process gets killed because
do_swap_page() returns VM_FAULT_OOM.  The test works fine if I remove
the migration cache patch.)

It looks like the page is flagged as being a migration pte, the page
is found in the migration cache, but then the test

            "likely(pte_same(*page_table, orig_pte))"

succeeds.  It's not obvious to me, at the moment, what this is supposed
to be doing.

Here is the code segment from do_swap_page(), with the debug printout
that was triggered:

again:
         if (pte_is_migration(orig_pte)) {
                 page = lookup_migration_cache(entry.val);
                 if (!page) {
                         spin_lock(&mm->page_table_lock);
                         page_table = pte_offset_map(pmd, address);
                         if (likely(pte_same(*page_table, orig_pte))) {
==========================>     DEBUG_VM_KILL(address);
                                 ret = VM_FAULT_OOM;
                         }
                         else
                                 ret = VM_FAULT_MINOR;
                         pte_unmap(page_table);
                         spin_unlock(&mm->page_table_lock);
                         goto out;
                 }




-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
