Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 683DD6B0078
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 16:53:57 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so7211470pab.39
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 13:53:57 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sw2si25357669pab.185.2014.09.15.13.53.55
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 13:53:56 -0700 (PDT)
Message-ID: <541751DF.8090706@intel.com>
Date: Mon, 15 Sep 2014 13:53:51 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
> +static int get_bt_addr(long __user *bd_entry, unsigned long *bt_addr)
> +{
> +	int valid;
> +
> +	if (!access_ok(VERIFY_READ, (bd_entry), sizeof(*(bd_entry))))
> +		return -EFAULT;

Nit: get rid of unnecessary parenthesis.

> +	pagefault_disable();
> +	if (get_user(*bt_addr, bd_entry))
> +		goto out;
> +	pagefault_enable();

Nit #2: Rewrite this.  Do this:

	int ret;
	...
	pagefault_disable();
	ret = get_user(*bt_addr, bd_entry))
	pagefault_enable();
	if (ret)
		return ret;

Then you don't need the out block below.

> +	valid = *bt_addr & MPX_BD_ENTRY_VALID_FLAG;
> +	*bt_addr &= MPX_BT_ADDR_MASK;
> +
> +	/*
> +	 * If this bounds directory entry is nonzero, and meanwhile
> +	 * the valid bit is zero, one SIGSEGV will be produced due to
> +	 * this unexpected situation.
> +	 */
> +	if (!valid && *bt_addr)
> +		return -EINVAL;

/*
 * Not present is OK.  It just means there was no bounds table
 * for this memory, which is completely OK.  Make sure to distinguish
 * this from -EINVAL, which will cause a SEGV.
 */

> +	if (!valid)
> +		return -ENOENT;
> +
> +	return 0;
> +
> +out:
> +	pagefault_enable();
> +	return -EFAULT;
> +}
> +
> +/*
> + * Free the backing physical pages of bounds table 'bt_addr'.
> + * Assume start...end is within that bounds table.
> + */
> +static int __must_check zap_bt_entries(struct mm_struct *mm,
> +		unsigned long bt_addr,
> +		unsigned long start, unsigned long end)
> +{
> +	struct vm_area_struct *vma;
> +
> +	/* Find the vma which overlaps this bounds table */
> +	vma = find_vma(mm, bt_addr);
> +	/*
> +	 * The table entry comes from userspace and could be
> +	 * pointing anywhere, so make sure it is at least
> +	 * pointing to valid memory.
> +	 */
> +	if (!vma || !(vma->vm_flags & VM_MPX) ||
> +			vma->vm_start > bt_addr ||
> +			vma->vm_end < bt_addr+MPX_BT_SIZE_BYTES)
> +		return -EINVAL;

If someone did *ANYTHING* to split the VMA, this check would fail.  I
think that's a little draconian, considering that somebody could do a
NUMA policy on part of a VM_MPX VMA and cause it to be split.

This check should look across the entire 'bt_addr ->
bt_addr+MPX_BT_SIZE_BYTES' range, find all of the VM_MPX VMAs, and zap
only those.

If we encounter a non-VM_MPX vma, it should be ignored.

> +	zap_page_range(vma, start, end - start, NULL);
> +	return 0;
> +}
> +
> +static int __must_check unmap_single_bt(struct mm_struct *mm,
> +		long __user *bd_entry, unsigned long bt_addr)
> +{
> +	int ret;
> +
> +	pagefault_disable();
> +	ret = user_atomic_cmpxchg_inatomic(&bt_addr, bd_entry,
> +			bt_addr | MPX_BD_ENTRY_VALID_FLAG, 0);
> +	pagefault_enable();
> +	if (ret)
> +		return -EFAULT;
> +
> +	/*
> +	 * to avoid recursion, do_munmap() will check whether it comes
> +	 * from one bounds table through VM_MPX flag.
> +	 */

Add this to the comment: "Note, we are likely being called under
do_munmap() already."

> +	return do_munmap(mm, bt_addr & MPX_BT_ADDR_MASK, MPX_BT_SIZE_BYTES);
> +}

Add a comment about where we checked for VM_MPX already.

> +/*
> + * If the bounds table pointed by bounds directory 'bd_entry' is
> + * not shared, unmap this whole bounds table. Otherwise, only free
> + * those backing physical pages of bounds table entries covered
> + * in this virtual address region start...end.
> + */
> +static int __must_check unmap_shared_bt(struct mm_struct *mm,
> +		long __user *bd_entry, unsigned long start,
> +		unsigned long end, bool prev_shared, bool next_shared)
> +{
> +	unsigned long bt_addr;
> +	int ret;
> +
> +	ret = get_bt_addr(bd_entry, &bt_addr);
> +	if (ret)
> +		return ret;
> +
> +	if (prev_shared && next_shared)
> +		ret = zap_bt_entries(mm, bt_addr,
> +				bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
> +				bt_addr+MPX_GET_BT_ENTRY_OFFSET(end));
> +	else if (prev_shared)
> +		ret = zap_bt_entries(mm, bt_addr,
> +				bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
> +				bt_addr+MPX_BT_SIZE_BYTES);
> +	else if (next_shared)
> +		ret = zap_bt_entries(mm, bt_addr, bt_addr,
> +				bt_addr+MPX_GET_BT_ENTRY_OFFSET(end));
> +	else
> +		ret = unmap_single_bt(mm, bd_entry, bt_addr);
> +
> +	return ret;
> +}
> +
> +/*
> + * A virtual address region being munmap()ed might share bounds table
> + * with adjacent VMAs. We only need to free the backing physical
> + * memory of these shared bounds tables entries covered in this virtual
> + * address region.
> + *
> + * the VMAs covering the virtual address region start...end have already
> + * been split if necessary and removed from the VMA list.
> + */
> +static int __must_check unmap_side_bts(struct mm_struct *mm,
> +		unsigned long start, unsigned long end)
> +{

> +	long __user *bde_start, *bde_end;
> +	struct vm_area_struct *prev, *next;
> +	bool prev_shared = false, next_shared = false;
> +
> +	bde_start = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
> +	bde_end = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
> +
> +	next = find_vma_prev(mm, start, &prev);

Let's update the comment here to:

/* We already unliked the VMAs from the mm's rbtree so 'start' is
guaranteed to be in a hole.  This gets us the first VMA before the hole
in to 'prev' and the next VMA after the hole in to 'next'. */

> +	if (prev && (mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(prev->vm_end-1))
> +			== bde_start)
> +		prev_shared = true;
> +	if (next && (mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(next->vm_start))
> +			== bde_end)
> +		next_shared = true;
> +	/*
> +	 * This virtual address region being munmap()ed is only
> +	 * covered by one bounds table.
> +	 *
> +	 * In this case, if this table is also shared with adjacent
> +	 * VMAs, only part of the backing physical memory of the bounds
> +	 * table need be freeed. Otherwise the whole bounds table need
> +	 * be unmapped.
> +	 */
> +	if (bde_start == bde_end) {
> +		return unmap_shared_bt(mm, bde_start, start, end,
> +				prev_shared, next_shared);
> +	}
> +
> +	/*
> +	 * If more than one bounds tables are covered in this virtual
> +	 * address region being munmap()ed, we need to separately check
> +	 * whether bde_start and bde_end are shared with adjacent VMAs.
> +	 */
> +	ret = unmap_shared_bt(mm, bde_start, start, end, prev_shared, false);
> +	if (ret)
> +		return ret;
> +
> +	ret = unmap_shared_bt(mm, bde_end, start, end, false, next_shared);
> +	if (ret)
> +		return ret;
> +
> +	return 0;
> +}
> +
> +static int __must_check mpx_try_unmap(struct mm_struct *mm,
> +		unsigned long start, unsigned long end)
> +{
> +	int ret;
> +	long __user *bd_entry, *bde_start, *bde_end;
> +	unsigned long bt_addr;
> +
> +	/*
> +	 * unmap bounds tables pointed out by start/end bounds directory
> +	 * entries, or only free part of their backing physical memroy
> +	 * if they are shared with adjacent VMAs.
> +	 */

New comment suggestion:
/*
 * "Side" bounds tables are those which are being used by the region
 * (start -> end), but that may be shared with adjacent areas.  If they
 * turn out to be completely unshared, they will be freed.  If they are
 * shared, we will free the backing store (like an MADV_DONTNEED) for
 * areas used by this region.
 */

> +	ret = unmap_side_bts(mm, start, end);

I think I'd start calling these "edge" bounds tables.

> +	if (ret == -EFAULT)
> +		return ret;
> +
> +	/*
> +	 * unmap those bounds table which are entirely covered in this
> +	 * virtual address region.
> +	 */

Entirely covered *AND* not at the edges, right?

> +	bde_start = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
> +	bde_end = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
> +	for (bd_entry = bde_start + 1; bd_entry < bde_end; bd_entry++) {

This needs a big fat comment that it is only freeing the bounds tables
that are
1. fully covered
2. not at the edges of the mapping, even if full aligned

Does this get any nicer if we have unmap_side_bts() *ONLY* go after
bounds tables that are partially owned by the region being unmapped?

It seems like we really should do this:

	for (each bt fully owned)
		unmap_single_bt()
	if (start edge unaligned)
		free start edge
	if (end edge unaligned)
		free end edge

I bet the unmap_side_bts() code gets simpler if we do that, too.

> +		ret = get_bt_addr(bd_entry, &bt_addr);
> +		/*
> +		 * A fault means we have to drop mmap_sem,
> +		 * perform the fault, and retry this somehow.
> +		 */
> +		if (ret == -EFAULT)
> +			return ret;
> +		/*
> +		 * Any other issue (like a bad bounds-directory)
> +		 * we can try the next one.
> +		 */
> +		if (ret)
> +			continue;
> +
> +		ret = unmap_single_bt(mm, bd_entry, bt_addr);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * Free unused bounds tables covered in a virtual address region being
> + * munmap()ed. Assume end > start.
> + *
> + * This function will be called by do_munmap(), and the VMAs covering
> + * the virtual address region start...end have already been split if
> + * necessary and remvoed from the VMA list.
> + */
> +void mpx_unmap(struct mm_struct *mm,
> +		unsigned long start, unsigned long end)
> +{
> +	int ret;
> +
> +	ret = mpx_try_unmap(mm, start, end);

We should rename mpx_try_unmap().  Please rename to:

	mpx_unmap_tables_for(mm, start, end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
