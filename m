Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 678A36B004D
	for <linux-mm@kvack.org>; Mon, 25 May 2009 17:10:11 -0400 (EDT)
Date: Mon, 25 May 2009 22:09:43 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
 and not VM_SHARED in hugetlbfs
In-Reply-To: <20090519083619.GD19146@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0905252122370.8557@sister.anvils>
References: <20090519083619.GD19146@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, ebmunson@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 May 2009, Mel Gorman wrote:

> hugetlbfs reserves huge pages and accounts for them differently depending
> on whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. However, the
> check made against VMA->vm_flags is sometimes VM_SHARED and not VM_MAYSHARE.
> For file-backed mappings, such as hugetlbfs, VM_SHARED is set only if the
> mapping is MAP_SHARED *and* it is read-write. For example, if a shared
> memory mapping was created read-write with shmget() for populating of data
> and mapped SHM_RDONLY by other processes, then hugetlbfs gets the accounting
> wrong and reservations leak.
> 
> This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE when
> the intent of the code was to check whether the VMA was mapped MAP_SHARED
> or MAP_PRIVATE.
> 
> The patch needs wider review as there are places where we really mean
> VM_SHARED and not VM_MAYSHARE. I believe I got all the right places, but a
> second opinion is needed. When/if this patch passes review, it'll be needed
> for 2.6.30 and -stable as it partially addresses the problem reported in
> http://bugzilla.kernel.org/show_bug.cgi?id=13302 and
> http://bugzilla.kernel.org/show_bug.cgi?id=12134.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

After another session looking at this one, Mel, I'm dubious about it.

Let's make clear that I never attempted to understand hugetlb reservations
and hugetlb private mappings at the time they went in; and after a little
while gazing at the code, I wouldn't pretend to understand them now.  It
would be much better to hear from Adam and Andy about this than me.

You're right to say that VM_MAYSHARE reflects MAP_SHARED, where VM_SHARED
does not.  But your description of VM_SHARED isn't quite clear: VM_SHARED
is used if the file was opened read-write and its mapping is MAP_SHARED,
even when the mapping is not PROT_WRITE (since the file was opened read-
write, the mapping is eligible for an mprotect to PROT_WRITE later on).

Yes, mm/hugetlb.c uses VM_SHARED throughout, rather than VM_MAYSHARE;
and that means that its reservations behaviour won't quite follow the
MAP_SHARED/MAP_PRIVATE split; but does that actually matter, so long
as it remains consistent with itself?  It would be nicer if it did
follow that split, but I wouldn't want us to change its established
behaviour around now without better reason.

You suggest that you're fixing an inconsistency in the reservations
behaviour, but you don't actually say what; and I don't see any
confirmation from Starlight that it fixes actual anomalies seen.
I'm all for fixing the bugs, but it's not self-evident that this
patch does fix any: please explain in more detail.

I've ended up worrying about the VM_SHAREDs you've left behind in
mm/hugetlb.c: unless you can pin down exactly what you're fixing
with this patch, my worry is that you're unbalancing the existing
reservation assumptions.  Certainly the patch shouldn't go in
without libhugetlbfs testing by libhugetlbfs experts.

Something I've noticed, to confirm that I can't really expect
to understand how hugetlb works these days.  I experimented by
creating a hugetlb file, opening read-write, mmap'ing one page
shared read-write (but not faulting it in); opening read-only,
mmap'ing the one page read-only (shared or private, doesn't matter),
faulting it in (contains zeroes of course); writing ffffffff to
the one page through the read-write mapping, then looking at the
read-only mapping - still contains zeroes, whereas with any
normal file and mapping it should contain ffffffff, whether
the read-only mapping was shared or private.

And to fix that would need more than just a VM_SHARED to VM_MAYSHARE
change, wouldn't it?  It may well not be something fixable: perhaps
there cannot be a reasonable private reservations strategy without
that non-standard behaviour.

But it does tell me not to trust my own preconceptions around here.

Hugh

> --- 
>  mm/hugetlb.c |   26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 28c655b..e83ad2c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -316,7 +316,7 @@ static void resv_map_release(struct kref *ref)
>  static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_SHARED))
> +	if (!(vma->vm_flags & VM_MAYSHARE))
>  		return (struct resv_map *)(get_vma_private_data(vma) &
>  							~HPAGE_RESV_MASK);
>  	return NULL;
> @@ -325,7 +325,7 @@ static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> +	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
>  
>  	set_vma_private_data(vma, (get_vma_private_data(vma) &
>  				HPAGE_RESV_MASK) | (unsigned long)map);
> @@ -334,7 +334,7 @@ static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
>  static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> +	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
>  
>  	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
>  }
> @@ -353,7 +353,7 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
>  	if (vma->vm_flags & VM_NORESERVE)
>  		return;
>  
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		/* Shared mappings always use reserves */
>  		h->resv_huge_pages--;
>  	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> @@ -369,14 +369,14 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_SHARED))
> +	if (!(vma->vm_flags & VM_MAYSHARE))
>  		vma->vm_private_data = (void *)0;
>  }
>  
>  /* Returns true if the VMA has associated reserve pages */
>  static int vma_has_reserves(struct vm_area_struct *vma)
>  {
> -	if (vma->vm_flags & VM_SHARED)
> +	if (vma->vm_flags & VM_MAYSHARE)
>  		return 1;
>  	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		return 1;
> @@ -924,7 +924,7 @@ static long vma_needs_reservation(struct hstate *h,
>  	struct address_space *mapping = vma->vm_file->f_mapping;
>  	struct inode *inode = mapping->host;
>  
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
>  		return region_chg(&inode->i_mapping->private_list,
>  							idx, idx + 1);
> @@ -949,7 +949,7 @@ static void vma_commit_reservation(struct hstate *h,
>  	struct address_space *mapping = vma->vm_file->f_mapping;
>  	struct inode *inode = mapping->host;
>  
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
>  		region_add(&inode->i_mapping->private_list, idx, idx + 1);
>  
> @@ -1893,7 +1893,7 @@ retry_avoidcopy:
>  	 * at the time of fork() could consume its reserves on COW instead
>  	 * of the full address range.
>  	 */
> -	if (!(vma->vm_flags & VM_SHARED) &&
> +	if (!(vma->vm_flags & VM_MAYSHARE) &&
>  			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
>  			old_page != pagecache_page)
>  		outside_reserve = 1;
> @@ -2000,7 +2000,7 @@ retry:
>  		clear_huge_page(page, address, huge_page_size(h));
>  		__SetPageUptodate(page);
>  
> -		if (vma->vm_flags & VM_SHARED) {
> +		if (vma->vm_flags & VM_MAYSHARE) {
>  			int err;
>  			struct inode *inode = mapping->host;
>  
> @@ -2104,7 +2104,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			goto out_mutex;
>  		}
>  
> -		if (!(vma->vm_flags & VM_SHARED))
> +		if (!(vma->vm_flags & VM_MAYSHARE))
>  			pagecache_page = hugetlbfs_pagecache_page(h,
>  								vma, address);
>  	}
> @@ -2289,7 +2289,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * to reserve the full area even if read-only as mprotect() may be
>  	 * called to make the mapping read-write. Assume !vma is a shm mapping
>  	 */
> -	if (!vma || vma->vm_flags & VM_SHARED)
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
>  		chg = region_chg(&inode->i_mapping->private_list, from, to);
>  	else {
>  		struct resv_map *resv_map = resv_map_alloc();
> @@ -2330,7 +2330,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * consumed reservations are stored in the map. Hence, nothing
>  	 * else has to be done for private mappings here
>  	 */
> -	if (!vma || vma->vm_flags & VM_SHARED)
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
>  		region_add(&inode->i_mapping->private_list, from, to);
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
