Message-ID: <20001013123430.A8823@saw.sw.com.sg>
Date: Fri, 13 Oct 2000 12:34:30 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local>; from "davej@suse.de" on Fri, Oct 13, 2000 at 01:20:23AM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davej@suse.de, "David S. Miller" <davem@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, tytso@mit.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, Oct 13, 2000 at 01:20:23AM +0100, davej@suse.de wrote:
> > 9. To Do
> >     * mm->rss is modified in some places without holding the
> >       page_table_lock (sct)
> 
> Any of the mm gurus give the patch below a quick once over ?
> Is this adequate, or is there more to this than the description implies?

The patch is basically ok, except one point.

[snip]
> diff -urN --exclude-from=/home/davej/.exclude linux/mm/vmscan.c linux.dj/mm/vmscan.c
> --- linux/mm/vmscan.c	Mon Oct  2 20:02:20 2000
> +++ linux.dj/mm/vmscan.c	Wed Oct 11 23:46:01 2000
> @@ -102,7 +102,9 @@
>  		set_pte(page_table, swp_entry_to_pte(entry));
>  drop_pte:
>  		UnlockPage(page);
> +		spin_lock (&mm->page_table_lock);
>  		mm->rss--;
> +		spin_unlock (&mm->page_table_lock);
>  		flush_tlb_page(vma, address);
>  		deactivate_page(page);
>  		page_cache_release(page);
> @@ -170,7 +172,9 @@
>  		struct file *file = vma->vm_file;
>  		if (file) get_file(file);
>  		pte_clear(page_table);
> +		spin_lock (&mm->page_table_lock);
>  		mm->rss--;
> +		spin_unlock (&mm->page_table_lock);
>  		flush_tlb_page(vma, address);
>  		vmlist_access_unlock(mm);
>  		error = swapout(page, file);
> @@ -202,7 +206,9 @@
>  	add_to_swap_cache(page, entry);
>  
>  	/* Put the swap entry into the pte after the page is in swapcache */
> +	spin_lock (&mm->page_table_lock);
>  	mm->rss--;
> +	spin_unlock (&mm->page_table_lock);
>  	set_pte(page_table, swp_entry_to_pte(entry));
>  	flush_tlb_page(vma, address);
>  	vmlist_access_unlock(mm);

page_table_lock is supposed to protect normal page table activity (like
what's done in page fault handler) from swapping out.
However, grabbing this lock in swap-out code is completely missing!
In vmscan.c the question is not only about rss protection, but about real
protection for page table entries.
It may be something like

--- mm/vmscan.c.ptl	Fri Oct 13 12:09:51 2000
+++ mm/vmscan.c	Fri Oct 13 12:19:10 2000
@@ -150,6 +150,7 @@
 		if (file) get_file(file);
 		pte_clear(page_table);
 		vma->vm_mm->rss--;
+		spin_unlock(&mm->page_table_lock);
 		flush_tlb_page(vma, address);
 		vmlist_access_unlock(vma->vm_mm);
 		error = swapout(page, file);
@@ -182,6 +183,7 @@
 	/* Put the swap entry into the pte after the page is in swapcache */
 	vma->vm_mm->rss--;
 	set_pte(page_table, swp_entry_to_pte(entry));
+	spin_unlock(&mm->page_table_lock);
 	flush_tlb_page(vma, address);
 	vmlist_access_unlock(vma->vm_mm);
 
@@ -324,6 +326,7 @@
 		if (address < vma->vm_start)
 			address = vma->vm_start;
 
+		spin_lock(&mm->page_table_lock);
 		for (;;) {
 			int result = swap_out_vma(mm, vma, address, gfp_mask);
 			if (result)
@@ -333,6 +336,7 @@
 				break;
 			address = vma->vm_start;
 		}
+		spin_unlock(&mm->page_table_lock);
 	}
 	vmlist_access_unlock(mm);
 

On Thu, Oct 12, 2000 at 05:29:39PM -0700, David S. Miller wrote:
>    From: davej@suse.de
>    Date: 	Fri, 13 Oct 2000 01:20:23 +0100 (BST)
> 
>    Any of the mm gurus give the patch below a quick once over ?  Is
>    this adequate, or is there more to this than the description
>    implies?
> 
> It might make more sense to just make rss an atomic_t.

In most cases where rss is updated page_table_lock is already held.

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
