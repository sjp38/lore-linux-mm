Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 37D4A6B009C
	for <linux-mm@kvack.org>; Fri, 29 May 2015 16:32:54 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so68105379pab.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 13:32:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cq9si9993120pad.1.2015.05.29.13.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 13:32:53 -0700 (PDT)
Date: Fri, 29 May 2015 13:32:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 7235/7555] mm/page_alloc.c:654:121: warning:
 comparison of distinct pointer types lacks a cast
Message-Id: <20150529133252.b0fa852381a501ff9df2ffdc@linux-foundation.org>
In-Reply-To: <201505300112.mcr8MSyM%fengguang.wu@intel.com>
References: <201505300112.mcr8MSyM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 30 May 2015 01:48:20 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   7732a9817fb01002bde7615066e86c156fb5a31b
> commit: 0491d0d6aac97c5b8df17851db525f3758de26e6 [7235/7555] s390/mm: make hugepages_supported a boot time decision
> config: s390-defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 0491d0d6aac97c5b8df17851db525f3758de26e6
>   # save the attached .config to linux build tree
>   make.cross ARCH=s390 
> 
> All warnings:
> 
>    mm/page_alloc.c: In function '__free_one_page':
> >> mm/page_alloc.c:654:121: warning: comparison of distinct pointer types lacks a cast
>       max_order = min(MAX_ORDER, pageblock_order + 1);
>                                                                                                                             ^
> --
>    mm/cma.c: In function 'cma_init_reserved_mem':
> >> mm/cma.c:186:137: warning: comparison of distinct pointer types lacks a cast
>      alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);

Dominik's patch has somehow managed to change the type of
pageblock_order.  Before the patch, pageblock_order expands to "(20 -
12)".  After the patch, pageblock_order expands to "(HPAGE_SHIFT -
12)".

And on s390, HPAGE_SHIFT is unsigned int.  On x86 HPAGE_SHIFT has type
int.  I suggest the fix here is to make s390's HPAGE_SHIFT have type
int as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
