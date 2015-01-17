Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F0EC56B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 20:22:04 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id z2so7101236wiv.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 17:22:04 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id t3si7196735wiv.74.2015.01.16.17.22.03
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 17:22:03 -0800 (PST)
Date: Sat, 17 Jan 2015 03:21:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mmotm:master 162/365] mm/mmap.c:2857:2: warning: right shift
 count >= width of type
Message-ID: <20150117012137.GA3614@node.dhcp.inet.fi>
References: <201501170849.XjPhPqfm%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201501170849.XjPhPqfm%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jan 17, 2015 at 08:30:50AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   59f7a5af1a6c9e19c6e5152f26548c494a2d7338
> commit: c824a9dc5e8821ce083652d4f728e804161d3dd0 [162/365] mm: account pmd page tables to the process
> config: tile-tilegx_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout c824a9dc5e8821ce083652d4f728e804161d3dd0
>   # save the attached .config to linux build tree
>   make.cross ARCH=tile 
> 
> All warnings:
> 
>    mm/mmap.c: In function 'exit_mmap':
> >> mm/mmap.c:2857:2: warning: right shift count >= width of type [enabled by default]
> 
> vim +2857 mm/mmap.c
> 
>   2841		free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>   2842		tlb_finish_mmu(&tlb, 0, -1);
>   2843	
>   2844		/*
>   2845		 * Walk the list again, actually closing and freeing it,
>   2846		 * with preemption enabled, without holding any MM locks.
>   2847		 */
>   2848		while (vma) {
>   2849			if (vma->vm_flags & VM_ACCOUNT)
>   2850				nr_accounted += vma_pages(vma);
>   2851			vma = remove_vma(vma);
>   2852		}
>   2853		vm_unacct_memory(nr_accounted);
>   2854	
>   2855		WARN_ON(atomic_long_read(&mm->nr_ptes) >
>   2856				round_up(FIRST_USER_ADDRESS, PMD_SIZE) >> PMD_SHIFT);
> > 2857		WARN_ON(mm_nr_pmds(mm) >
>   2858				round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);

Okay, FIRST_USER_ADDRESS is 0. roundup_up() is int too in this case.
PUD_SHIFT is 32.

I think the best way to fix this warning is to make FIRST_USER_ADDRESS
unsigned long. And better on all architectures.
