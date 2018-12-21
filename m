Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 750C68E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:23:46 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b185so6566836qkc.3
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:23:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor10918044qve.43.2018.12.21.10.23.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:23:45 -0800 (PST)
Date: Fri, 21 Dec 2018 10:23:43 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [mmotm:master 310/355] mm/memory.c:3007:23: error: too many
 arguments to function 'pte_alloc_one'
Message-ID: <20181221182343.GA249971@google.com>
References: <201812211234.xyGyhxhw%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201812211234.xyGyhxhw%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Dec 21, 2018 at 12:03:00PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   98c1d1d6a1d1553512e5db8c07a149c41e7c2f84
> commit: 47931f365e6eaac24d1653e3ce00f69e76187c08 [310/355] mm: treewide: remove unused address argument from pte_alloc functions
> config: x86_64-rhel-7.2-clear (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 47931f365e6eaac24d1653e3ce00f69e76187c08
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the mmotm/master HEAD 98c1d1d6a1d1553512e5db8c07a149c41e7c2f84 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    mm/memory.c: In function '__do_fault':
> >> mm/memory.c:3007:23: error: too many arguments to function 'pte_alloc_one'
>       vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm, vmf->address);
>                           ^~~~~~~~~~~~~
>    In file included from arch/x86/include/asm/mmu_context.h:12:0,
>                     from mm/memory.c:74:
>    arch/x86/include/asm/pgalloc.h:51:18: note: declared here
>     extern pgtable_t pte_alloc_one(struct mm_struct *);
>                      ^~~~~~~~~~~~~
> 
> vim +/pte_alloc_one +3007 mm/memory.c
> 
> ^1da177e4 Linus Torvalds     2005-04-16  2991  
> 9a95f3cf7 Paul Cassella      2014-08-06  2992  /*
> 9a95f3cf7 Paul Cassella      2014-08-06  2993   * The mmap_sem must have been held on entry, and may have been
> 9a95f3cf7 Paul Cassella      2014-08-06  2994   * released depending on flags and vma->vm_ops->fault() return value.
> 9a95f3cf7 Paul Cassella      2014-08-06  2995   * See filemap_fault() and __lock_page_retry().
> 9a95f3cf7 Paul Cassella      2014-08-06  2996   */
> 2b7403035 Souptick Joarder   2018-08-23  2997  static vm_fault_t __do_fault(struct vm_fault *vmf)
> 7eae74af3 Kirill A. Shutemov 2014-04-03  2998  {
> 82b0f8c39 Jan Kara           2016-12-14  2999  	struct vm_area_struct *vma = vmf->vma;
> 2b7403035 Souptick Joarder   2018-08-23  3000  	vm_fault_t ret;
> 7eae74af3 Kirill A. Shutemov 2014-04-03  3001  
> d85ec7561 Michal Hocko       2018-12-19  3002  	/*
> d85ec7561 Michal Hocko       2018-12-19  3003  	 * Preallocate pte before we take page_lock because this might lead to
> d85ec7561 Michal Hocko       2018-12-19  3004  	 * deadlocks for memcg reclaim which waits for pages under writeback.
> d85ec7561 Michal Hocko       2018-12-19  3005  	 */
> d85ec7561 Michal Hocko       2018-12-19  3006  	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
> d85ec7561 Michal Hocko       2018-12-19 @3007  		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm, vmf->address);

Taking a look at linux-next, this has already been fixed so I believe the
report is based on an older kernel.

thanks,

 - Joel
