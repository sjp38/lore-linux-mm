Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4076B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 01:23:17 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id o8G5NClS013567
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:53:12 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8G5NBLv3678286
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:53:11 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8G5NBPQ015700
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:23:11 +1000
Date: Thu, 16 Sep 2010 10:53:11 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Reserved pages in PowerPC
Message-ID: <20100916052311.GC2332@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am trying to hotplug/offline sections of memory on a Power machine.
I boot the kernel with kernelcore=1G commandline parameter. I see that except
for 512MB, the rest of the memory is movable. When trying to do hot-remove, I
notice that I am unable to remove the very last section of memory, one with
the highest physical address. It is always marked as non-movable.

With some debugging I found that that section has reserved pages. On
instrumenting the memblock_reserve() and reserve_bootmem() routines, I can see
that many of the memory areas are reserved for kernel and initrd by the
memblock reserve() itself. reserve_bootmem then looks at the pages already
reserved and marks them reserved. However, for the very last section, I see
that bootmem reserves it but I am unable to find a corresponding reservation
by the memblock code.


memblock_reserve: start 0 size 3519 
reserve_bootmem 0 dbf000 nid=0
memblock_reserve: start 12096 size 15372
reserve_bootmem 2f40000 ccc000 nid=0
memblock_reserve: start 15628 size 15650
reserve_bootmem 3d0c000 16000 nid=0
...
...
memblock_reserve: start 1982455 size 1982464
reserve_bootmem 1e3ff7c00 8400 nid=0
reserve_bootmem 3d7f64000 3f000 nid=1
reserve_bootmem 3d7fa3c00 48400 nid=1
reserve_bootmem 3d7feeda8 11258 nid=1
..
 
Is it a known behavior on Power ? If yes, for what purpose is the memory
in the higher address reserved for ? I have seen that even if the system
has multiple nodes, only the very last section of the last node is not
removable.

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
