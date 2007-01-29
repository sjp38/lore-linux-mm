Date: Mon, 29 Jan 2007 20:41:43 +0000 (GMT)
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: page_mkwrite caller is racy?
In-Reply-To: <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0701292037040.32539@hermes-1.csi.cam.ac.uk>
References: <45BDCA8A.4050809@yahoo.com.au> <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Hugh Dickins wrote:
> On Mon, 29 Jan 2007, Nick Piggin wrote:
> > After do_wp_page calls page_mkwrite on its target (old_page), it then drops
> > the reference to the page before locking the ptl and verifying that the pte
> > points to old_page.
> > 
> > Unfortunately, old_page may have been truncated and freed, or reclaimed, then
> > re-allocated and used again for the same pagecache position and faulted in
> > read-only into the same pte by another thread. Then you will have a situation
> > where page_mkwrite succeeds but the page we use is actually a readonly one.
> 
> You're right.  Well observed.  It was I who originally added that
> page_cache_release/page_cache_get, and the page_cache_get certainly
> followed getting the page_table_lock when I first added them.
> 
> Looks like amidst all the intervening versions, with the patch going
> into and getting dropped from -mm from time to time, those positions
> became reversed without us noticing (almost certainly when the lock
> and the pte_offset_map got merged into the pte_offset_map_lock).
> 
> > 
> > Moving page_cache_release(old_page) to below the next statement
> > will fix that problem.
> 
> Yes.  I'm reluctant to steal your credit, but also reluctant to go
> back and forth too much over this: please insert your Signed-off-by
> _before_ mine in the patch below (substituting your own comment if
> you prefer) and send it Andrew.
> 
> Not a priority for 2.6.20 or -stable: aside from the unlikelihood,
> we don't seem to have any page_mkwrite users yet, as you point out.
> 
> > But it is sad that this thing got merged without any callers to even
> > know how it is intended to work.
> 
> I'm rather to blame for that: I pushed Peter to rearranging his work
> on top of what David had, since they were dabbling in related issues,
> and we'd already solved a number of them in relation to page_mkwrite;
> so then when dirty tracking was wanted in, page_mkwrite came with it.
> 
> At the time I believed that AntonA was on the point of using it in
> NTFS, but apparently not yet.

Other things got more important...  I still am on the virge of using it 
but I have to finish off other work first so the "virge" may be a little 
wihle off still.

> > Must it be able to sleep?
> 
> Not as David was using it: that was something I felt strongly it
> should be allowd to do.  For example, in order to allocate backing
> store for the mmap'ed page to be written (that need has been talked
> about off and on for years).

Yes this is exactly what I need it in NTFS for.  And also I need to be 
able to perform a mmap'ed write into a non-initialized region, i.e. a 
region which has disk allocation but has not been zeroed yet so in a total 
worst case scenario I could have a huge file that is all allocated on disk 
but completely not initialized yet and a single byte write towards the end 
of the file would require me to zero the entirety of that file up to the 
written byte at least so the one byte write may trigger a multi gigabyte 
(or terrabyte!) write operation which from ->writepage would be bad news 
but from page_mkwrite is much better.

Best regards,

	Anton

> 
> Hugh
> 
> 
> After do_wp_page has tested page_mkwrite, it must release old_page after
> acquiring page table lock, not before: at some stage that ordering got
> reversed, leaving a (very unlikely) window in which old_page might be
> truncated, freed, and reused in the same position.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  mm/memory.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> --- 2.6.20-rc6/mm/memory.c	2007-01-25 08:25:27.000000000 +0000
> +++ linux/mm/memory.c	2007-01-29 15:35:56.000000000 +0000
> @@ -1531,8 +1531,6 @@ static int do_wp_page(struct mm_struct *
>  			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
>  				goto unwritable_page;
>  
> -			page_cache_release(old_page);
> -
>  			/*
>  			 * Since we dropped the lock we need to revalidate
>  			 * the PTE as someone else may have changed it.  If
> @@ -1541,6 +1539,7 @@ static int do_wp_page(struct mm_struct *
>  			 */
>  			page_table = pte_offset_map_lock(mm, pmd, address,
>  							 &ptl);
> +			page_cache_release(old_page);
>  			if (!pte_same(*page_table, orig_pte))
>  				goto unlock;
>  		}
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
