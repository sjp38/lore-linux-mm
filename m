Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0CF96B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 12:15:06 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id n2so243586341obo.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:15:06 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id i65si24433984ioi.135.2016.04.25.09.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 09:15:05 -0700 (PDT)
Message-ID: <1461600377.8149.76.camel@hpe.com>
Subject: Re: [PATCH v4 1/2] thp, dax: add thp_get_unmapped_area for pmd
 mappings
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 25 Apr 2016 10:06:17 -0600
In-Reply-To: <20160424225057.GA6670@node.shutemov.name>
References: <1461370883-7664-1-git-send-email-toshi.kani@hpe.com>
	 <1461370883-7664-2-git-send-email-toshi.kani@hpe.com>
	 <20160424225057.GA6670@node.shutemov.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, mike.kravetz@oracle.com, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2016-04-25 at 01:50 +0300, Kirill A. Shutemov wrote:
> On Fri, Apr 22, 2016 at 06:21:22PM -0600, Toshi Kani wrote:
> > 
A :
> > +unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long
> > len,
> > +		loff_t off, unsigned long flags, unsigned long size)
> > +{
> > +	unsigned long addr;
> > +	loff_t off_end = off + len;
> > +	loff_t off_align = round_up(off, size);
> > +	unsigned long len_pad;
> > +
> > +	if (off_end <= off_align || (off_end - off_align) < size)
> > +		return 0;
> > +
> > +	len_pad = len + size;
> > +	if (len_pad < len || (off + len_pad) < off)
> > +		return 0;
> > +
> > +	addr = current->mm->get_unmapped_area(filp, 0, len_pad,
> > +					A A A A A A off >> PAGE_SHIFT,
> > flags);
> > +	if (IS_ERR_VALUE(addr))
> > +		return 0;
> > +
> > +	addr += (off - addr) & (size - 1);
> > +	return addr;
>
> Hugh has more sanity checks before and after call to get_unmapped_area().
> Please, consider borrowing them.

This function only checks if the request is qualified for THP mappings. It
tries not to step into the implementation of the allocation code current-
>mm->get_unmapped_area(), such asA arch_get_unmapped_area_topdown() on x86.

Let me walk thru Hugh's checks to make sure I am not missing something:

---(Hugh's checks)---
| +	if (len > TASK_SIZE)
| +		return -ENOMEM;

This check is made by arch_get_unmapped_area_topdown().

| +
| +	get_area = current->mm->get_unmapped_area;
| +	addr = get_area(file, uaddr, len, pgoff, flags);
| +
| +	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
| +		return addr;

thp_get_unmapped_area() is defined to NULL in this case.

| +	if (IS_ERR_VALUE(addr))
| +		return addr;

Checked in my patch.

| +	if (addr & ~PAGE_MASK)
| +		return addr;

arch_get_unmapped_area_topdown() aligns 'addr' unless MAP_FIXED is set. No
need to check in this func.

| +	if (addr > TASK_SIZE - len)
| +		return addr;

The allocation code needs to assure this case.

| +	if (shmem_huge == SHMEM_HUGE_DENY)
| +		return addr;

This check is specific to Hugh's patch.

| +	if (len < HPAGE_PMD_SIZE)
| +		return addr;

Checked in my patch.

| +	if (flags & MAP_FIXED)
| +		return addr;

Checked by arch_get_unmapped_area_topdown().

| +	/*
| +	A * Our priority is to support MAP_SHARED mapped hugely;
| +	A * and support MAP_PRIVATE mapped hugely too, until it is COWed.
| +	A * But if caller specified an address hint, respect that as
before.
| +	A */
| +	if (uaddr)
| +		return addr;

Checked in my patch.

(cut)

| +	offset = (pgoff << PAGE_SHIFT) & (HPAGE_PMD_SIZE-1);
| +	if (offset && offset + len < 2 * HPAGE_PMD_SIZE)
| +		return addr;

Checked in my patch.

| +	if ((addr & (HPAGE_PMD_SIZE-1)) == offset)
| +		return addr;

This is a lucky case, i.e. the 1st get_unmapped_area() call returned an
aligned addr. Not applicable to my patch.

| +
| +	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
| +	if (inflated_len > TASK_SIZE)
| +		return addr;

Checked by arch_get_unmapped_area_topdown().

| +	if (inflated_len < len)
| +		return addr;

Checked in my patch.

| +	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);

Not sure why passing 'filp' and 'off' as NULL here.

| +	if (IS_ERR_VALUE(inflated_addr))
| +		return addr;

Checked in my patch.

| +	if (inflated_addr & ~PAGE_MASK)
| +		return addr;

Hmm... if this happens, it is a bug in the allocation code. I do not think
this check is necessary.

| +	inflated_offset = inflated_addr & (HPAGE_PMD_SIZE-1);
| +	inflated_addr += offset - inflated_offset;
| +	if (inflated_offset > offset)
| +		inflated_addr += HPAGE_PMD_SIZE;
| +
| +	if (inflated_addr > TASK_SIZE - len)
| +		return addr;

The allocation code needs to assure this.

| +	return inflated_addr;

> > 
> > +}
> > +
> > +unsigned long thp_get_unmapped_area(struct file *filp, unsigned long
> > addr,
> > +		unsigned long len, unsigned long pgoff, unsigned long
> > flags)
> > +{
> > +	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
> > +
> > +	if (addr)
> > +		goto out;
>
> I think it's too strong reaction to hint, isn't it?
> We definately need this for MAP_FIXED. But in general? Maybe.

It calls arch's get_unmapped_area() to proceed with the original args when
'addr' is passed. The arch's get_unmapped_are() then handles 'addr' as a
hint when MAP_FIXED is not set. This can be used as a hint to avoid using
THP mappings if a non-aligned address is passed. Hugh's code handles it in
the same way as well.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
