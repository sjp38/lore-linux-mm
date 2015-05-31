Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D43226B006E
	for <linux-mm@kvack.org>; Sun, 31 May 2015 06:18:22 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so5147507wib.1
        for <linux-mm@kvack.org>; Sun, 31 May 2015 03:18:22 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id o2si13055061wic.59.2015.05.31.03.18.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 31 May 2015 03:18:21 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Sun, 31 May 2015 11:18:20 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1BDBA17D8056
	for <linux-mm@kvack.org>; Sun, 31 May 2015 11:19:15 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4VAIINn17694906
	for <linux-mm@kvack.org>; Sun, 31 May 2015 10:18:18 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4VAIHcw013379
	for <linux-mm@kvack.org>; Sun, 31 May 2015 04:18:17 -0600
Date: Sun, 31 May 2015 12:18:15 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [next:master 7235/7555] mm/page_alloc.c:654:121: warning:
 comparison of distinct pointer types lacks a cast
Message-ID: <20150531121815.254f9bc2@BR9TG4T3.de.ibm.com>
In-Reply-To: <20150529133252.b0fa852381a501ff9df2ffdc@linux-foundation.org>
References: <201505300112.mcr8MSyM%fengguang.wu@intel.com>
	<20150529133252.b0fa852381a501ff9df2ffdc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Fri, 29 May 2015 13:32:52 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sat, 30 May 2015 01:48:20 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   7732a9817fb01002bde7615066e86c156fb5a31b
> > commit: 0491d0d6aac97c5b8df17851db525f3758de26e6 [7235/7555] s390/mm: make hugepages_supported a boot time decision
> > config: s390-defconfig (attached as .config)
> > reproduce:
> >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >   chmod +x ~/bin/make.cross
> >   git checkout 0491d0d6aac97c5b8df17851db525f3758de26e6
> >   # save the attached .config to linux build tree
> >   make.cross ARCH=s390 
> > 
> > All warnings:
> > 
> >    mm/page_alloc.c: In function '__free_one_page':
> > >> mm/page_alloc.c:654:121: warning: comparison of distinct pointer types lacks a cast
> >       max_order = min(MAX_ORDER, pageblock_order + 1);
> >                                                                                                                             ^
> > --
> >    mm/cma.c: In function 'cma_init_reserved_mem':
> > >> mm/cma.c:186:137: warning: comparison of distinct pointer types lacks a cast
> >      alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
> 
> Dominik's patch has somehow managed to change the type of
> pageblock_order.  Before the patch, pageblock_order expands to "(20 -
> 12)".  After the patch, pageblock_order expands to "(HPAGE_SHIFT -
> 12)".
> 
> And on s390, HPAGE_SHIFT is unsigned int.  On x86 HPAGE_SHIFT has type
> int.  I suggest the fix here is to make s390's HPAGE_SHIFT have type
> int as well.

Thanks for noticing. As my way to handle this was mostly inspired by the
way powerpc does it,  I'm kind of puzzled why they don't have the same problem?

So I checked and your fix seems to be the right thing to do. But then I would
assume the powerpc type for HPAGE should also be changed?

Thanks,
	Dominik

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
