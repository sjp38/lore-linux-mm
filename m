Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54E016B025F
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:48:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so26816033pfx.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:48:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l3si13573976paz.169.2016.06.28.03.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jun 2016 03:48:06 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5SAiMpX127422
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:48:05 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23spf9jdcm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:48:04 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 28 Jun 2016 04:48:03 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [linux-next:master 6012/6704] include/asm-generic/tlb.h:133:3: error: implicit declaration of function '__tlb_adjust_range'
In-Reply-To: <201606272339.TRfrgkTK%fengguang.wu@intel.com>
References: <201606272339.TRfrgkTK%fengguang.wu@intel.com>
Date: Tue, 28 Jun 2016 16:17:55 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d1n16144.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, akpm@linux-foundation.org
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

kbuild test robot <fengguang.wu@intel.com> writes:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   aa20c9aa490a2b73f97bceae9828ccfaa9cb1b4f
> commit: dbea3efdd0c92695c1697b6a20e5b4cff09a3312 [6012/6704] mm: change the interface for __tlb_remove_page()
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout dbea3efdd0c92695c1697b6a20e5b4cff09a3312
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> Note: the linux-next/master HEAD aa20c9aa490a2b73f97bceae9828ccfaa9cb1b4f builds fine.
>       It may have been fixed somewhere.
>
> All errors (new ones prefixed by >>):
>
>    In file included from arch/x86/include/asm/tlb.h:16:0,
>                     from arch/x86/include/asm/efi.h:7,
>                     from arch/x86/kernel/setup.c:81:
>    include/asm-generic/tlb.h: In function 'tlb_remove_page':
>>> include/asm-generic/tlb.h:133:3: error: implicit declaration of function '__tlb_adjust_range' [-Werror=implicit-function-declaration]
>       __tlb_adjust_range(tlb, tlb->addr);
>       ^~~~~~~~~~~~~~~~~~
>    include/asm-generic/tlb.h: At top level:
>    include/asm-generic/tlb.h:138:20: warning: conflicting types for '__tlb_adjust_range'
>     static inline void __tlb_adjust_range(struct mmu_gather *tlb,
>                        ^~~~~~~~~~~~~~~~~~
>>> include/asm-generic/tlb.h:138:20: error: static declaration of '__tlb_adjust_range' follows non-static declaration
>    include/asm-generic/tlb.h:133:3: note: previous implicit declaration of '__tlb_adjust_range' was here
>       __tlb_adjust_range(tlb, tlb->addr);
>       ^~~~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors
>
> vim +/__tlb_adjust_range +133 include/asm-generic/tlb.h
>
>    127	 *	required.
>    128	 */
>    129	static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>    130	{
>    131		if (__tlb_remove_page(tlb, page)) {
>    132			tlb_flush_mmu(tlb);
>  > 133			__tlb_adjust_range(tlb, tlb->addr);
>    134			__tlb_remove_page(tlb, page);
>    135		}
>    136	}
>    137	
>  > 138	static inline void __tlb_adjust_range(struct mmu_gather *tlb,
>    139					      unsigned long address)
>    140	{
>    141		tlb->start = min(tlb->start, address);
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

IIUC this will get fixed, when we fold

http://ozlabs.org/~akpm/mmots/broken-out/mm-change-the-interface-for-__tlb_remove_page-v3.patch

to

http://ozlabs.org/~akpm/mmots/broken-out/mm-change-the-interface-for-__tlb_remove_page.patch


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
