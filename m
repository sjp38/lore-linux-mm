Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 693416B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:06:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t8so125652479oif.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:06:49 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id h186si11759567ioa.178.2016.06.17.01.06.47
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 01:06:48 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <054e01d1c86d$c7261fd0$55725f70$@alibaba-inc.com>
In-Reply-To: <054e01d1c86d$c7261fd0$55725f70$@alibaba-inc.com>
Subject: Re: [PATCHv9-rebased2 28/37] shmem: get_unmapped_area align huge page
Date: Fri, 17 Jun 2016 16:06:33 +0800
Message-ID: <054f01d1c86f$2994d5c0$7cbe8140$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> +unsigned long shmem_get_unmapped_area(struct file *file,
> +				      unsigned long uaddr, unsigned long len,
> +				      unsigned long pgoff, unsigned long flags)
> +{
> +	unsigned long (*get_area)(struct file *,
> +		unsigned long, unsigned long, unsigned long, unsigned long);
> +	unsigned long addr;
> +	unsigned long offset;
> +	unsigned long inflated_len;
> +	unsigned long inflated_addr;
> +	unsigned long inflated_offset;
> +
> +	if (len > TASK_SIZE)
> +		return -ENOMEM;
> +
> +	get_area = current->mm->get_unmapped_area;
> +	addr = get_area(file, uaddr, len, pgoff, flags);
> +
> +	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> +		return addr;
> +	if (IS_ERR_VALUE(addr))
> +		return addr;
> +	if (addr & ~PAGE_MASK)
> +		return addr;
> +	if (addr > TASK_SIZE - len)
> +		return addr;
> +
> +	if (shmem_huge == SHMEM_HUGE_DENY)
> +		return addr;
> +	if (len < HPAGE_PMD_SIZE)
> +		return addr;
> +	if (flags & MAP_FIXED)
> +		return addr;
> +	/*
> +	 * Our priority is to support MAP_SHARED mapped hugely;
> +	 * and support MAP_PRIVATE mapped hugely too, until it is COWed.
> +	 * But if caller specified an address hint, respect that as before.
> +	 */
> +	if (uaddr)
> +		return addr;
> +
> +	if (shmem_huge != SHMEM_HUGE_FORCE) {
> +		struct super_block *sb;
> +
> +		if (file) {
> +			VM_BUG_ON(file->f_op != &shmem_file_operations);
> +			sb = file_inode(file)->i_sb;
> +		} else {
> +			/*
> +			 * Called directly from mm/mmap.c, or drivers/char/mem.c
> +			 * for "/dev/zero", to create a shared anonymous object.
> +			 */
> +			if (IS_ERR(shm_mnt))
> +				return addr;
> +			sb = shm_mnt->mnt_sb;
> +		}
> +		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
> +			return addr;

Try to ask for a larger arena if huge page is not disabled for 
the mount(s/!=/==/)?

> +	}
> +
> +	offset = (pgoff << PAGE_SHIFT) & (HPAGE_PMD_SIZE-1);
> +	if (offset && offset + len < 2 * HPAGE_PMD_SIZE)
> +		return addr;
> +	if ((addr & (HPAGE_PMD_SIZE-1)) == offset)
> +		return addr;
> +
> +	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
> +	if (inflated_len > TASK_SIZE)
> +		return addr;
> +	if (inflated_len < len)
> +		return addr;
> +
> +	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);
> +	if (IS_ERR_VALUE(inflated_addr))
> +		return addr;
> +	if (inflated_addr & ~PAGE_MASK)
> +		return addr;
> +
> +	inflated_offset = inflated_addr & (HPAGE_PMD_SIZE-1);
> +	inflated_addr += offset - inflated_offset;
> +	if (inflated_offset > offset)
> +		inflated_addr += HPAGE_PMD_SIZE;
> +
> +	if (inflated_addr > TASK_SIZE - len)
> +		return addr;
> +	return inflated_addr;
> +}
> +
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
