Date: Thu, 04 Nov 2004 17:01:32 +0900 (JST)
Message-Id: <20041104.170132.108422322.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041103152129.GA4716@logos.cnet>
References: <41813FCD.3070503@us.ibm.com>
	<20041028162652.GC7562@logos.cnet>
	<20041103152129.GA4716@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: haveblue@us.ibm.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi,

> Can't boot 2.6.9-mm1-mhp on my dual P4 - reverting -mhp 
> makes it happy again (with same .config file). Freezes
> after "OK, now booting the kernel".
> 
> Will stick to -rc4-mm1 for now.


I guess the problem may be solved with the attached patch Kame-san made.
 


From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>,
	lhms-devel@lists.sourceforge.net
Date: Mon, 01 Nov 2004 19:23:15 +0900
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.3) Gecko/20040910

Dave Hansen wrote:

> Hirokazu Takahashi wrote:
> 
>> BTW, linux-2.6.9-mm1-mhp1 often causes startup freeze on my box.
>> I don't know why.
> 
> 
> It would be very helpful to diagnose it.  Where does the freeze occur? 
> Can you dump the console?  Did you boot with "debug" on the kernel 
> command line?  Have you tried sysrq?
> 
This is a patch for this i386 problem.
alloc_memmap() is called twice and this hits new BUG_ON() :)

Thanks.
Kame <kamezawa.hiroyu@jp.fujitsu.com>

---

  linux-2.6.9-mm1-mhp-kamezawa/arch/i386/kernel/setup.c |   13 -------------
  1 files changed, 13 deletions(-)

diff -puN arch/i386/kernel/setup.c~cleanup arch/i386/kernel/setup.c
--- linux-2.6.9-mm1-mhp/arch/i386/kernel/setup.c~cleanup	2004-11-01 18:33:45.179201168 +0900
+++ linux-2.6.9-mm1-mhp-kamezawa/arch/i386/kernel/setup.c	2004-11-01 18:34:01.648697424 +0900
@@ -1393,19 +1393,6 @@ void __init setup_arch(char **cmdline_p)
  #endif
  	paging_init();

-	/*
-	 * NOTE: at this point the bootmem allocator is fully available.
-	 */
-
-#ifdef CONFIG_NONLINEAR
-	{
-		/* use alloc_node_mem_map() instead - daveh */
-		struct page *lmem_map;
-		lmem_map = alloc_bootmem(max_pfn * sizeof(struct page));
-		alloc_memmap(lmem_map, 0, max_pfn);
-	}
-#endif
-
  	zone_sizes_init();

  #ifdef CONFIG_EARLY_PRINTK

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
