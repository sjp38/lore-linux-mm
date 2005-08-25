Date: Thu, 25 Aug 2005 18:15:21 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
In-Reply-To: <20050818125236.4ffe1053.akpm@osdl.org>
References: <20050810145550.740D.Y-GOTO@jp.fujitsu.com> <20050818125236.4ffe1053.akpm@osdl.org>
Message-Id: <20050825162423.2A0D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, kravetz@us.ibm.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Hello. Andrew-san.

I could rent a x86_64 box, and tried this panic.
But, it hasn't occurred in my box.
Could you add following patch and retry with my previous one
to get more information?

Your .config didn't set CONFIG_NUMA, so kernel tried allocation
just one node which had all of memory.
And your console message displayed that required size was 67Mbytes.
Now, I guess that one function called alloc_bootmem_low() 
by size = 67Mbytes. But, it is impossible because x86_64's DMA area
size is just 16Mbytes. So, caller got "non DMA" area in spite of
its requirement in current code, but my patch refused it and panic was
occured.

I would like to make sure my assumption and would like to know
which function call it.

Thanks.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
---

 alloc_bootmem-goto/mm/bootmem.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN mm/bootmem.c~info mm/bootmem.c
--- alloc_bootmem/mm/bootmem.c~info	2005-08-24 20:30:57.000000000 +0900
+++ alloc_bootmem-goto/mm/bootmem.c	2005-08-24 20:38:12.000000000 +0900
@@ -410,7 +410,9 @@ void * __init __alloc_bootmem (unsigned 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	printk(KERN_ALERT "bootmem alloc of %lu bytes %s failed!\n",
+	       size, goal < max_dma_physaddr() ? "DMA" : "No DMA");
+	dump_stack();
 	panic("Out of memory");
 	return NULL;
 }
_

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
