Message-ID: <476A73F0.4070704@de.ibm.com>
Date: Thu, 20 Dec 2007 14:53:52 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de>
In-Reply-To: <20071214134106.GC28555@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> This is just a prototype for one possible way of supporting this. I may
> be missing some important detail or eg. have missed some requirement of the
> s390 XIP block device that makes the idea infeasible... comments?
I've tested things now without initialization of our struct page 
entries for s390. This does'nt work out, as you can see below. 
free_hot_cold_page apparently still uses the struct page behind our 
shared memory segment.
Please don't get confused by the process name "mount": this is _not_ 
the mount that has mounted the xip file system but rather an elf 
binary of /bin/mount [on ext3] which is linked against a library in 
/usr/lib64 [on ext2 -o xip].
I'll drill down deeper here to see why it does'nt work as expected...
     <6>extmem info:segment_load: loaded segment COTTE range 
0000000020000000 .. 000000007fe00fff type SW in shared mode
     <6>dcssblk info: Loaded segment COTTE, size = 1608519680 Byte, 
capacity = 3141640 (512 Byte) sectors
     <4>EXT2-fs warning: checktime reached, running e2fsck is recommended
     <0>Bad page state in process 'mount'
     <0>page:000003fffedd7a50 flags:0x0000000000000000 
mapping:0000000000000000 mapcount:1 count:0
     <0>Trying to fix it up, but a reboot is needed
     <0>Backtrace:
     <4>0000000000000000 000000000fbd5b58 0000000000000002 
0000000000000000
     <4>       000000000fbd5bf8 000000000fbd5b70 000000000fbd5b70 
000000000012b882
     <4>       0000000000000000 0000000000000000 000003fffe6f76f8 
0000000000000000
     <4>       0000000000000000 000000000fbd5b58 000000000000000d 
000000000fbd5bc8
     <4>       0000000000415f30 00000000001037b8 000000000fbd5b58 
000000000fbd5ba0
     <4>Call Trace:
     <4>([<0000000000103736>] show_trace+0x12e/0x148)
     <4> [<0000000000171e10>] bad_page+0x94/0xd0
     <4> [<0000000000172c80>] free_hot_cold_page+0x218/0x230
     <4> [<0000000000180082>] unmap_vmas+0x4e6/0xc50
     <4> [<0000000000185fa0>] exit_mmap+0x128/0x408
     <4> [<0000000000127e90>] mmput+0x70/0xe4
     <4> [<000000000012f606>] do_exit+0x1b6/0x8ac
     <4> [<000000000012fd48>] do_group_exit+0x4c/0xa4
     <4> [<00000000001102b8>] sysc_noemu+0x10/0x16
     <4> [<0000020000108272>] 0x20000108272



...and here the patch I use to get rid of the struct page entries in 
our vmmem_map array:

---
Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -310,8 +310,6 @@ out:
  int add_shared_memory(unsigned long start, unsigned long size)
  {
         struct memory_segment *seg;
-       struct page *page;
-       unsigned long pfn, num_pfn, end_pfn;
         int ret;

         mutex_lock(&vmem_mutex);
@@ -330,20 +328,6 @@ int add_shared_memory(unsigned long star
         if (ret)
                 goto out_remove;

-       pfn = PFN_DOWN(start);
-       num_pfn = PFN_DOWN(size);
-       end_pfn = pfn + num_pfn;
-
-       page = pfn_to_page(pfn);
-       memset(page, 0, num_pfn * sizeof(struct page));
-
-       for (; pfn < end_pfn; pfn++) {
-               page = pfn_to_page(pfn);
-               init_page_count(page);
-               reset_page_mapcount(page);
-               SetPageReserved(page);
-               INIT_LIST_HEAD(&page->lru);
-       }
         goto out;

  out_remove:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
