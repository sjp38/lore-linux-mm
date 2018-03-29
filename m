Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0BB06B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 16:42:22 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id u188so624552vke.13
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 13:42:22 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u16si2798747uae.257.2018.03.29.13.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 13:42:21 -0700 (PDT)
Subject: Re: [PATCH 0/1] fix regression in hugetlbfs overflow checking
References: <20180329041656.19691-1-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <91db8046-0504-4851-4bdb-28bfe7d4c24f@oracle.com>
Date: Thu, 29 Mar 2018 13:42:09 -0700
MIME-Version: 1.0
In-Reply-To: <20180329041656.19691-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Dan Rue <dan.rue@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On 03/28/2018 09:16 PM, Mike Kravetz wrote:
> Commit 63489f8e8211 ("hugetlbfs: check for pgoff value overflow")
> introduced a regression in 32 bit kernels.  When creating the mask
> to check vm_pgoff, it incorrectly specified that the size of a loff_t
> was the size of a long.  This prevents mapping hugetlbfs files at
> offsets greater than 4GB on 32 bit kernels.

Well, the kbuild test robot found issues with that as well. :(

I stepped back and did some analysis on what really needs to be
checked WRT arguments causing overflow in the hugetlbfs mmap routine.
For my reference more than anything, here are type sizes to be
concerned with on 32 and 64 bit systems:

Data or type		32 bit system	64 bit system
------------		-------------	-------------
vm_pgoff		32		64
size_t			32		64
loff_t			64		64
huge_page_index		32		64

There are three areas of concern:

1) Will the page offset value passed in vm_pgoff overflow a loff_t?

   On 64 bit systems, vm_off is 64 bits and loff_t is 64 bits.  When
   hugetlbfs mmap is entered via the normal mmap path, the file offset
   is PAGE_SHIFT'ed right and put into vm_pgoff.  However, the
   remap_file_pages system call allows a user to specify a page offset
   which is put directly into vm_pgoff.  Converting from a page offset
   to byte offset is required to get offsets within the underlying
   hugetlbfs file.  In both cases, the value in vm_pgoff when converted
   to a byte offset could overflow a loff_t.

   On 32 bit systems, vm_pgoff is 32 bits and loff_t is 64 bits.  Therefore,
   when converting to a byte address we will never overflow a loff_t.  In
   addition, on 32 bit systems it is perfectly valid for vm_pgoff to be
   as big as ULONG_MAX.  This allows for hugetlbfs files greater than 4GB
   in size.

2) Does vm_pgoff when converted to bytes plus the length of the mapping
   overflow a loff_t?

   On 64 bit systems, we have validated that vm_pgoff will not overflow a
   loff_t when converted to bytes.  But, it is still possible for this
   value plus length to overflow a loff_t.

   On 32 bit systems, vm_pgoff is a 32 bits and can be at most ULONG_MAX.
   Converting this value to bytes is a PAGE_SHIFT left into a 64 bit loff_t.
   length is a 32 bits and can be at most LONG_MAX.  Adding these two
   values can not overflow a 64 bit loff_t.

3) Can vm_pgoff and (vm_pgoff + length) be represented as huge page
   offsets with a signed long?  The hugetlbfs reservation management
   code uses longs for huge page offsets into the underlying file.

   On 64 bit systems, the checks in 1) and 2) have ensured that both values
   can be represented by a loff_t which is a signed 64 bit value.  These
   values will be shifted right by 'huge page shift'  Therefore, they can
   certainly be represented by a signed long.

  On 32 bit systems pg_off can be at most ULONG_MAX.  This value will be
  right shifted 'huge_page_shift - PAGE_SHIFT' bits.  So, as long as
  huge_page_shift is one or more greater than PAGE_SHIFT this value can
  be represented with a signed long.  Adding the maximum length value
  (LONG_MAX) the maximum pg_off byte converted value, would result in
  one more significant bit being set.  For example assuming
  PAGE_SHIFT = 12: 0x0ffffffff000 + 0x00ffffffff = 0x1000ffffefff.
  To represent this as a huge page index, we right shift 'huge_page_shift
  - PAGE_SHIFT' bits.  As long as huge_page_shift is 2 or more greater
  than PAGE_SHIFT, this value can be represented with a signed long.

If we make the following assumptions:
- PAGE_SHIFT will be 2 or more less than BITS_PER_LONG
- huge_page_shift will be 2 or more greater than PAGE_SHIFT
then we need to make to make following checks in the code.

1) Check the upper PAGE_SHIFT+1 bits of vm_pgoff on 64 bit systems.
   Explicitly disable on 32 bit systems.

/*
 * Mask used when checking the page offset value passed in via system
 * calls.  This value will be converted to a loff_t which is signed.
 * Therefore, we want to check the upper PAGE_SHIFT + 1 bits of the
 * value.  The extra bit (- 1 in the shift value) is to take the sign
 * bit into account.
 */
#define PGOFF_LOFFT_MAX \
	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))
...
	/*
	 * page based offset in vm_pgoff could be sufficiently large to
	 * overflow a loff_t when converted to byte offset.  This can
	 * only happen on architectures where sizeof(loff_t) ==
	 * sizeof(unsigned long).  So, only check in those instances.
	 */
	if (sizeof(unsigned long) == sizeof(loff_t)) {
		if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
			return -EINVAL;
	}

2) Convert vm_pgoff and length to loff_t byte offset.  Add together and
   check for overflow.  This is unnecessary on 32 bit systems as described
   above, but likely not worth the conditional code.

	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
	/* check for overflow */
	if (len < vma_len)
		return -EINVAL;

3) After making the above two checks, pg_off and (pg_off + length) can
   be represented as huge page offsets with a signed long.  So, no checks
   needed.

I know this is long and a bore to read.  However, I wanted to get some
feedback before sending another patch.  I have attempted to fix this several
times and seem to always over look some detail.  Hopefully, this will
help others to think of additional concerns.

-- 
Mike Kravetz
