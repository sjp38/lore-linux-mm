Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id C6D486B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 02:58:29 -0500 (EST)
Received: by eekc41 with SMTP id c41so15496344eek.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 23:58:28 -0800 (PST)
Message-ID: <4EFD6F22.5010501@monstr.eu>
Date: Fri, 30 Dec 2011 08:58:26 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
MIME-Version: 1.0
Subject: Re: memblock and bootmem problems if start + size = 4GB
References: <4EEF42F5.7040002@monstr.eu> <20111219162835.GA24519@google.com> <4EF05316.5050803@monstr.eu> <20111229155836.GB3516@google.com> <4EFC995A.5090904@monstr.eu> <20111229170745.GE3516@google.com>
In-Reply-To: <20111229170745.GE3516@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Tejun Heo wrote:
> Hello,
> 
> On Thu, Dec 29, 2011 at 05:46:18PM +0100, Michal Simek wrote:
>> First of all I don't like to use your term "extend range coverages".
>> We don't want to extend any ranges - we just wanted to place memory to the end
>> of address space and be able to work with.
> 
> It is, as long as we use address ranges.  Either we can express length
> of zero or include the last address.
> 
>> It is limitation which should be fixed somehow.
>> And I would expect that PFN_XX(base + size) will be in u32 range.
>>
>> Probably the best solution will be to use PFN macro in one place and
>> do not covert addresses in common code.
>>
>> + change parameters in bootmem code because some arch do
>> free_bootmem_node(..., PFN_PHYS(), ...)
>> and
>> reserve_bootmem_node(..., PFN_PHYS(), ...)
> 
> So now we're talking about a lot of code just for ONE page and
> regardless of the representation in the memblock or other memory
> management code, I think trying to use that page is fundamentally a
> bad idea.  There are a lot of places in the kernel where phys_addr_t
> is used. 

I haven't said to replace phys_addr_t!
My point was something like this (just as example on parisc and free_bootmem_node).
The problematic part is kmemleak code which could be good reason not to change it.

Thanks,
Michal


diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 82f364e..b83ee32 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -291,8 +291,8 @@ static void __init setup_bootmem(void)
                                                 start_pfn,
                                                 (start_pfn + npages) );
                 free_bootmem_node(NODE_DATA(i),
-                                 (start_pfn << PAGE_SHIFT),
-                                 (npages << PAGE_SHIFT) );
+                                 start_pfn,
+                                 npages);
                 bootmap_pfn += (bootmap_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
                 if ((start_pfn + npages) > max_pfn)
                         max_pfn = start_pfn + npages;



diff --git a/mm/bootmem.c b/mm/bootmem.c
index 45a691a..dfbfc47 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -363,17 +363,12 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
   *
   * The range must reside completely on the specified node.
   */
-void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
-                             unsigned long size)
+void __init free_bootmem_node(pg_data_t *pgdat, unsigned long startpfn,
+                             unsigned long endpfn)
  {
-       unsigned long start, end;
-
-       kmemleak_free_part(__va(physaddr), size);
+       kmemleak_free_part(__va(startpfn << PAGE_SHIFT), (endpfn - startpfn) << PAGE_SHIFT);

-       start = PFN_UP(physaddr);
-       end = PFN_DOWN((u64)physaddr + (u64)size);
-
-       mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
+       mark_bootmem_node(pgdat->bdata, startpfn, endpfn, 0, 0);
  }




-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
