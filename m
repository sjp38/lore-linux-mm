Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A76D6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 06:09:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g141so55416176wmd.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 03:09:15 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id n96si3955419lfi.25.2016.09.12.03.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 03:09:13 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l131so5639196lfl.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 03:09:13 -0700 (PDT)
Date: Mon, 12 Sep 2016 13:09:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Message-ID: <20160912100910.GC23346@node.shutemov.name>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Sep 11, 2016 at 10:31:35AM -0700, Dan Williams wrote:
> As evidenced by this bug report [1], userspace libraries are interested
> in whether a mapping is DAX mapped, i.e. no intervening page cache.
> Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
> explicit "is dax" indication as a new flag in the page vector populated
> by mincore.
> 
> There are also cases, particularly for testing and validating a
> configuration to know the hardware mapping geometry of the pages in a
> given process address range.  Consider filesystem-dax where a
> configuration needs to take care to align partitions and block
> allocations before huge page mappings might be used, or
> anonymous-transparent-huge-pages where a process is opportunistically
> assigned large pages.  mincore2() allows these configurations to be
> surveyed and validated.
> 
> The implementation takes advantage of the unused bits in the per-page
> byte returned for each PAGE_SIZE extent of a given address range.  The
> new format of each vector byte is:
> 
> (TLB_SHIFT - PAGE_SHIFT) << 2 | vma_is_dax() << 1 | page_present
> 
> [1]: https://lkml.org/lkml/2016/9/7/61
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/syscalls.h               |    2 +
>  include/uapi/asm-generic/mman-common.h |    3 +
>  kernel/sys_ni.c                        |    1 
>  mm/mincore.c                           |  126 +++++++++++++++++++++++++-------
>  4 files changed, 104 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index d02239022bd0..4aa2ee7e359a 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -467,6 +467,8 @@ asmlinkage long sys_munlockall(void);
>  asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
>  asmlinkage long sys_mincore(unsigned long start, size_t len,
>  				unsigned char __user * vec);
> +asmlinkage long sys_mincore2(unsigned long start, size_t len,
> +				unsigned char __user * vec, int flags);

We had few attempts to extand mincore(2) interface/functionality before.
None of them ended up in upsteam.

How this attempt compares to previous?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
