Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF6B6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 23:51:37 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id x3so3010937obt.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 20:51:37 -0700 (PDT)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id et3si11363691obb.86.2016.03.28.20.51.35
        for <linux-mm@kvack.org>;
        Mon, 28 Mar 2016 20:51:36 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com> <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [RFC PATCH 1/2] mm/hugetlbfs: Attempt PUD_SIZE mapping alignment if PMD sharing enabled
Date: Tue, 29 Mar 2016 11:50:47 +0800
Message-ID: <024b01d1896e$2e600e70$8b202b50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: 'Hugh Dickins' <hughd@google.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Thomas Gleixner' <tglx@linutronix.de>, 'Ingo Molnar' <mingo@redhat.com>, "'H. Peter Anvin'" <hpa@zytor.com>, 'Catalin Marinas' <catalin.marinas@arm.com>, 'Will Deacon' <will.deacon@arm.com>, 'Steve Capper' <steve.capper@linaro.org>, 'Andrew Morton' <akpm@linux-foundation.org>

> 
> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
> following conditions are met:
> - Address passed to mmap or shmat is NULL
> - The mapping is flaged as shared
> - The mapping is at least PUD_SIZE in length
> If a PUD_SIZE aligned mapping can not be created, then fall back to a
> huge page size mapping.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 540ddc9..22b2e38 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -175,6 +175,17 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  	struct vm_area_struct *vma;
>  	struct hstate *h = hstate_file(file);
>  	struct vm_unmapped_area_info info;
> +	bool pud_size_align = false;
> +	unsigned long ret_addr;
> +
> +	/*
> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
> +	 * sharing.  Only attempt alignment if no address was passed in,
> +	 * flags indicate sharing and size is big enough.
> +	 */
> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
> +	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
> +		pud_size_align = true;
> 
>  	if (len & ~huge_page_mask(h))
>  		return -EINVAL;
> @@ -199,9 +210,23 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  	info.length = len;
>  	info.low_limit = TASK_UNMAPPED_BASE;
>  	info.high_limit = TASK_SIZE;
> -	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +	if (pud_size_align)
> +		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
> +	else
> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>  	info.align_offset = 0;
> -	return vm_unmapped_area(&info);
> +	ret_addr = vm_unmapped_area(&info);
> +
> +	/*
> +	 * If failed with PUD_SIZE alignment, try again with huge page
> +	 * size alignment.
> +	 */

Can we avoid going another round as long as it is a file with
the PUD page size?

Hillf
> +	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
> +		ret_addr = vm_unmapped_area(&info);
> +	}
> +
> +	return ret_addr;
>  }
>  #endif
> 
> --
> 2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
