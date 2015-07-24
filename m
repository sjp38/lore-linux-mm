Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 665A19003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 06:09:46 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so20994077wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:09:45 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id q8si3435478wiz.6.2015.07.24.03.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 03:09:44 -0700 (PDT)
Received: by wicgb10 with SMTP id gb10so21717378wic.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:09:43 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:09:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: vm_flags, vm_flags_t and __nocast
Message-ID: <20150724100940.GB22732@node.dhcp.inet.fi>
References: <201507241628.EnDEXbaF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507241628.EnDEXbaF%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Oleg Nesterov <oleg@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 04:18:30PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
> commit: b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73 [371/385] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
> reproduce:
>   # apt-get install sparse
>   git checkout b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> arch/x86/mm/mpx.c:71:54: sparse: implicit cast to nocast type
>    arch/x86/mm/mpx.c:312:27: sparse: incompatible types in comparison expression (different address spaces)
> --
> >> include/linux/mm.h:1812:54: sparse: implicit cast to nocast type
> --
>    mm/mmap.c:1343:47: sparse: implicit cast to nocast type
>    mm/mmap.c:1345:45: sparse: implicit cast to nocast type
>    mm/mmap.c:1354:45: sparse: implicit cast to nocast type
>    mm/mmap.c:1375:47: sparse: implicit cast to nocast type
>    mm/mmap.c:1395:37: sparse: implicit cast to nocast type
>    mm/mmap.c:1399:37: sparse: implicit cast to nocast type
>    mm/mmap.c:1443:33: sparse: implicit cast to nocast type
>    mm/mmap.c:1578:29: sparse: implicit cast to nocast type
>    mm/internal.h:253:43: sparse: implicit cast to nocast type
>    mm/mmap.c:2650:37: sparse: implicit cast to nocast type
>    mm/mmap.c:2690:34: sparse: implicit cast to nocast type
>    mm/mmap.c:2693:34: sparse: implicit cast to nocast type
> >> include/linux/mm.h:1812:54: sparse: implicit cast to nocast type
>    mm/internal.h:253:43: sparse: implicit cast to nocast type

sparse complains on each and every vm_flags_t initialization, even with
proper VM_* constants.

Do we really want to fix that?

To me it's too much pain and no gain. __nocast is not beneficial here.

And I'm not sure that vm_flags_t typedef was a good idea after all.
Originally, it was intended to become 64-bit one day, but four years later
it's still unsigned long. Plain unsigned long works fine for other bit
field.

What is special about vm_flags?

> vim +71 arch/x86/mm/mpx.c
> 
>     55	 * bounds tables (the bounds directory is user-allocated).
>     56	 *
>     57	 * Later on, we use the vma->vm_ops to uniquely identify these
>     58	 * VMAs.
>     59	 */
>     60	static unsigned long mpx_mmap(unsigned long len)
>     61	{
>     62		struct mm_struct *mm = current->mm;
>     63		unsigned long addr, populate;
>     64	
>     65		/* Only bounds table can be allocated here */
>     66		if (len != mpx_bt_size_bytes(mm))
>     67			return -EINVAL;
>     68	
>     69		down_write(&mm->mmap_sem);
>     70		addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
>   > 71				MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
>     72		up_write(&mm->mmap_sem);
>     73		if (populate)
>     74			mm_populate(addr, populate);
>     75	
>     76		return addr;
>     77	}
>     78	
>     79	enum reg_type {
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
