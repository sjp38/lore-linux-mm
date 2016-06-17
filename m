Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5956B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:29:54 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so38006504lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:29:54 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id r14si17928902lfr.187.2016.06.17.04.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 04:29:52 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l184so8076685lfl.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:29:52 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:29:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9-rebased2 28/37] shmem: get_unmapped_area align huge page
Message-ID: <20160617112949.GB6534@node.shutemov.name>
References: <054e01d1c86d$c7261fd0$55725f70$@alibaba-inc.com>
 <054f01d1c86f$2994d5c0$7cbe8140$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <054f01d1c86f$2994d5c0$7cbe8140$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jun 17, 2016 at 04:06:33PM +0800, Hillf Danton wrote:
> > 
> > +unsigned long shmem_get_unmapped_area(struct file *file,
> > +				      unsigned long uaddr, unsigned long len,
> > +				      unsigned long pgoff, unsigned long flags)
> > +{
> > +	unsigned long (*get_area)(struct file *,
> > +		unsigned long, unsigned long, unsigned long, unsigned long);
> > +	unsigned long addr;
> > +	unsigned long offset;
> > +	unsigned long inflated_len;
> > +	unsigned long inflated_addr;
> > +	unsigned long inflated_offset;
> > +
> > +	if (len > TASK_SIZE)
> > +		return -ENOMEM;
> > +
> > +	get_area = current->mm->get_unmapped_area;
> > +	addr = get_area(file, uaddr, len, pgoff, flags);
> > +
> > +	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> > +		return addr;
> > +	if (IS_ERR_VALUE(addr))
> > +		return addr;
> > +	if (addr & ~PAGE_MASK)
> > +		return addr;
> > +	if (addr > TASK_SIZE - len)
> > +		return addr;
> > +
> > +	if (shmem_huge == SHMEM_HUGE_DENY)
> > +		return addr;
> > +	if (len < HPAGE_PMD_SIZE)
> > +		return addr;
> > +	if (flags & MAP_FIXED)
> > +		return addr;
> > +	/*
> > +	 * Our priority is to support MAP_SHARED mapped hugely;
> > +	 * and support MAP_PRIVATE mapped hugely too, until it is COWed.
> > +	 * But if caller specified an address hint, respect that as before.
> > +	 */
> > +	if (uaddr)
> > +		return addr;
> > +
> > +	if (shmem_huge != SHMEM_HUGE_FORCE) {
> > +		struct super_block *sb;
> > +
> > +		if (file) {
> > +			VM_BUG_ON(file->f_op != &shmem_file_operations);
> > +			sb = file_inode(file)->i_sb;
> > +		} else {
> > +			/*
> > +			 * Called directly from mm/mmap.c, or drivers/char/mem.c
> > +			 * for "/dev/zero", to create a shared anonymous object.
> > +			 */
> > +			if (IS_ERR(shm_mnt))
> > +				return addr;
> > +			sb = shm_mnt->mnt_sb;
> > +		}
> > +		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
> > +			return addr;
> 
> Try to ask for a larger arena if huge page is not disabled for 
> the mount(s/!=/==/)?

<facepalm>

I mostly test with SHMEM_HUGE_FORCE as it puts more stress on the system.

Fixup:

diff --git a/mm/shmem.c b/mm/shmem.c
index e2c6b6e8387a..3f4ebe84ef61 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1979,7 +1979,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 				return addr;
 			sb = shm_mnt->mnt_sb;
 		}
-		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
+		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
 			return addr;
 	}
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
