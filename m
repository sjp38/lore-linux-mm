Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m8OCWTH6031138
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Sep 2008 21:32:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A517240047
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 21:32:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 119582DC12F
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 21:32:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DD181DB803F
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 21:32:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB2AA1DB803B
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 21:32:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
In-Reply-To: <20080923194655.GA25542@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080923194655.GA25542@csn.ul.ie>
Message-Id: <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Sep 2008 21:32:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Dave, please let me know getpagesize() function return to 4k or 64k on ppc64.
> > I think the PageSize line of the /proc/pid/smap and getpagesize() result should be matched.
> > 
> > otherwise, enduser may be confused.
> > 
> 
> To distinguish between the two, I now report the kernel pagesize and the
> mmu pagesize like so
> 
> KernelPageSize:       64 kB
> MMUPageSize:           4 kB
> 
> This is running a kernel with a 64K base pagesize on a PPC970MP which
> does not support 64K hardware pagesizes.
> 
> Does this make sense?

Hmmm, Who want to this infomation?

I agreed with
  - An administrator want to know these page are normal or huge.
  - An administrator want to know hugepage size.
    (e.g. x86_64 has two hugepage size (2M and 1G))

but above ppc64 case seems deeply implementation depended infomation and
nobody want to know it.

it seems a bottleneck of future enhancement.

then I disagreed with
  - show both KernelPageSize and MMUPageSize in normal page.


I like following two choice


1) in normal page, show PAZE_SIZE

because, any userland application woks as pagesize==PAZE_SIZE 
on current powerpc architecture.

because

fs/binfmt_elf.c
------------------------------
static int
create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
                unsigned long load_addr, unsigned long interp_load_addr)
{
(snip)
        NEW_AUX_ENT(AT_HWCAP, ELF_HWCAP);
        NEW_AUX_ENT(AT_PAGESZ, ELF_EXEC_PAGESIZE); /* pass ELF_EXEC_PAGESIZE to libc */

include/asm-powerpc/elf.h
-----------------------------
#define ELF_EXEC_PAGESIZE       PAGE_SIZE 


2) in normal page, no display any page size.
   only hugepage case, display page size.

because, An administrator want to hugepage size only. (AFAICS)



Thought?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
