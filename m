Date: Thu, 10 Feb 2005 14:41:47 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache bug?
Message-ID: <20050210164147.GA19877@logos.cnet>
References: <420BB9E6.90303@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <420BB9E6.90303@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ray, 

On Thu, Feb 10, 2005 at 01:45:42PM -0600, Ray Bryant wrote:
> (Resending so this gets posted to linux-mm):
> 
> Hirokazu and Marcello,
> 
> Here's some more information on this problem I am having with the
> migration cache.
> 
> (The problem is that the test application is failing after it returns
> from the system call that migrated some of its address space from node
> 0 to node 3 on my test box.  When the program touches the first page
> in the range that was migrated, the process gets killed because
> do_swap_page() returns VM_FAULT_OOM.  The test works fine if I remove
> the migration cache patch.)

Thing is the PTE should have been remapped by touch_unmapped_address() at
the end of generic_migrate_page() during the migration syscall.

Hirokazu implemented the set of changes which saves mm_struct,address pairs of corresponding
page mappings on a list of "page_va_list" structures:

struct page_va_list {
        struct mm_struct *mm;
        unsigned long addr;
        struct list_head list;
};

To later on be able to redo the mapping (touch_unmapped_address).

generic_migrate_pages() {
	LIST_HEAD(vlist);
...
	if (page_mapped(page)) {
                while ((ret = try_to_unmap(page, &vlist)) == SWAP_AGAIN)
                        msleep(1);
                if (ret != SWAP_SUCCESS) {
                        ret = -EBUSY;
                        goto out_busy;
                }
        }
...
        /* map the newpage where the old page have been mapped. */
        touch_unmapped_address(&vlist);
	if (PageMigration(newpage))
		detach_from_migration_cache(newpage);       <---- comment it out to confirm
	else if (PageSwapCache(newpage)) {
		lock_page(newpage);
		__remove_exclusive_swap_page(newpage, 1);
		unlock_page(newpage);
        }
}

Can you find you why is touch_unmapped_address() failing to work? 

To confirm this hypothesis, please comment the call to "detach_from_migration_cache(newpage)"
at the end of generic_migrate_pages().

This should cause lookup_migration_cache() to succeed and remap the pte.

Hope that helps.

> It looks like the page is flagged as being a migration pte, the page
> is found in the migration cache, but then the test
> 
>            "likely(pte_same(*page_table, orig_pte))"
> 
> succeeds.  It's not obvious to me, at the moment, what this is supposed
> to be doing.
> 
> Here is the code segment from do_swap_page(), with the debug printout
> that was triggered:
> 
> again:
>         if (pte_is_migration(orig_pte)) {
>                 page = lookup_migration_cache(entry.val);
>                 if (!page) {
>                         spin_lock(&mm->page_table_lock);
>                         page_table = pte_offset_map(pmd, address);
>                         if (likely(pte_same(*page_table, orig_pte))) {
> ==========================>     DEBUG_VM_KILL(address);
>                                 ret = VM_FAULT_OOM;
>                         }
>                         else
>                                 ret = VM_FAULT_MINOR;
>                         pte_unmap(page_table);
>                         spin_unlock(&mm->page_table_lock);
>                         goto out;
>                 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
