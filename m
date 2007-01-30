Message-ID: <45BE9BF0.10202@yahoo.com.au>
Date: Tue, 30 Jan 2007 12:14:24 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page_mkwrite caller is racy?
References: <45BDCA8A.4050809@yahoo.com.au> <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0701291521540.24726@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Mark Fasheh <mark.fasheh@oracle.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 29 Jan 2007, Nick Piggin wrote:

>>Moving page_cache_release(old_page) to below the next statement
>>will fix that problem.
> 
> 
> Yes.  I'm reluctant to steal your credit, but also reluctant to go
> back and forth too much over this: please insert your Signed-off-by
> _before_ mine in the patch below (substituting your own comment if
> you prefer) and send it Andrew.
> 
> Not a priority for 2.6.20 or -stable: aside from the unlikelihood,
> we don't seem to have any page_mkwrite users yet, as you point out.

Agreed. Thanks for doing the patch.

>>But it is sad that this thing got merged without any callers to even
>>know how it is intended to work.
> 
> 
> I'm rather to blame for that: I pushed Peter to rearranging his work
> on top of what David had, since they were dabbling in related issues,
> and we'd already solved a number of them in relation to page_mkwrite;
> so then when dirty tracking was wanted in, page_mkwrite came with it.

Well its not a big problem -- I knew there were several people lined
up who wanted it. XFS is another one IIRC.

>>Must it be able to sleep?
> 
> 
> Not as David was using it: that was something I felt strongly it
> should be allowd to do.  For example, in order to allocate backing
> store for the mmap'ed page to be written (that need has been talked
> about off and on for years).

Fine, and Mark and Anton confirm it (cc'ed, thanks guys).

This is another discussion, but do we want the page locked here? Or
are the filesystems happy to exclude truncate themselves?


> After do_wp_page has tested page_mkwrite, it must release old_page after
> acquiring page table lock, not before: at some stage that ordering got
> reversed, leaving a (very unlikely) window in which old_page might be
> truncated, freed, and reused in the same position.

Andrew please apply.

Signed-off-by: Nick Piggin <npiggin@suse.de>

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
> 


-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
