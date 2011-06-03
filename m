Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 24AB86B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 02:40:38 -0400 (EDT)
Message-ID: <4DE88112.3090908@snapgear.com>
Date: Fri, 3 Jun 2011 16:37:06 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] nommu: add page_align to mmap
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

Hi Bob,

On 06/05/11 16:03, Bob Liu wrote:
> Currently on nommu arch mmap(),mremap() and munmap() doesn't do page_align()
> which isn't consist with mmu arch and cause some issues.
>
> First, some drivers' mmap() function depends on vma->vm_end - vma->start is
> page aligned which is true on mmu arch but not on nommu. eg: uvc camera driver.
>
> Second munmap() may return -EINVAL[split file] error in cases when end is not
> page aligned(passed into from userspace) but vma->vm_end is aligned dure to
> split or driver's mmap() ops.
>
> This patch add page align to fix those issues.

This is actually causing me problems on head at the moment.
git bisected to this patch as the cause.

When booting on a ColdFire (m68knommu) target the init process (or
there abouts at least) fails. Last console messages are:

   ...
   VFS: Mounted root (romfs filesystem) readonly on device 31:0.
   Freeing unused kernel memory: 52k freed (0x401aa000 - 0x401b6000)
   Unable to mmap process text, errno 22

I haven't really debugged it any further yet. But that error message
comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.

Reverting that this patch and no more problem.

Regards
Greg



> Changelog v1->v2:
> - added more commit message
>
> Signed-off-by: Bob Liu<lliubbo@gmail.com>
> ---
>   mm/nommu.c |   24 ++++++++++++++----------
>   1 files changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/mm/nommu.c b/mm/nommu.c
> index c4c542c..3febfd9 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1133,7 +1133,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
>   			   unsigned long capabilities)
>   {
>   	struct page *pages;
> -	unsigned long total, point, n, rlen;
> +	unsigned long total, point, n;
>   	void *base;
>   	int ret, order;
>
> @@ -1157,13 +1157,12 @@ static int do_mmap_private(struct vm_area_struct *vma,
>   		 * make a private copy of the data and map that instead */
>   	}
>
> -	rlen = PAGE_ALIGN(len);
>
>   	/* allocate some memory to hold the mapping
>   	 * - note that this may not return a page-aligned address if the object
>   	 *   we're allocating is smaller than a page
>   	 */
> -	order = get_order(rlen);
> +	order = get_order(len);
>   	kdebug("alloc order %d for %lx", order, len);
>
>   	pages = alloc_pages(GFP_KERNEL, order);
> @@ -1173,7 +1172,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
>   	total = 1<<  order;
>   	atomic_long_add(total,&mmap_pages_allocated);
>
> -	point = rlen>>  PAGE_SHIFT;
> +	point = len>>  PAGE_SHIFT;
>
>   	/* we allocated a power-of-2 sized page set, so we may want to trim off
>   	 * the excess */
> @@ -1195,7 +1194,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
>   	base = page_address(pages);
>   	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
>   	region->vm_start = (unsigned long) base;
> -	region->vm_end   = region->vm_start + rlen;
> +	region->vm_end   = region->vm_start + len;
>   	region->vm_top   = region->vm_start + (total<<  PAGE_SHIFT);
>
>   	vma->vm_start = region->vm_start;
> @@ -1211,15 +1210,15 @@ static int do_mmap_private(struct vm_area_struct *vma,
>
>   		old_fs = get_fs();
>   		set_fs(KERNEL_DS);
> -		ret = vma->vm_file->f_op->read(vma->vm_file, base, rlen,&fpos);
> +		ret = vma->vm_file->f_op->read(vma->vm_file, base, len,&fpos);
>   		set_fs(old_fs);
>
>   		if (ret<  0)
>   			goto error_free;
>
>   		/* clear the last little bit */
> -		if (ret<  rlen)
> -			memset(base + ret, 0, rlen - ret);
> +		if (ret<  len)
> +			memset(base + ret, 0, len - ret);
>
>   	}
>
> @@ -1268,6 +1267,7 @@ unsigned long do_mmap_pgoff(struct file *file,
>
>   	/* we ignore the address hint */
>   	addr = 0;
> +	len = PAGE_ALIGN(len);
>
>   	/* we've determined that we can make the mapping, now translate what we
>   	 * now know into VMA flags */
> @@ -1645,14 +1645,16 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
>   {
>   	struct vm_area_struct *vma;
>   	struct rb_node *rb;
> -	unsigned long end = start + len;
> +	unsigned long end;
>   	int ret;
>
>   	kenter(",%lx,%zx", start, len);
>
> -	if (len == 0)
> +	if ((len = PAGE_ALIGN(len)) == 0)
>   		return -EINVAL;
>
> +	end = start + len;
> +
>   	/* find the first potentially overlapping VMA */
>   	vma = find_vma(mm, start);
>   	if (!vma) {
> @@ -1773,6 +1775,8 @@ unsigned long do_mremap(unsigned long addr,
>   	struct vm_area_struct *vma;
>
>   	/* insanity checks first */
> +	old_len = PAGE_ALIGN(old_len);
> +	new_len = PAGE_ALIGN(new_len);
>   	if (old_len == 0 || new_len == 0)
>   		return (unsigned long) -EINVAL;
>


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
