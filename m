Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA6096B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:20:49 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id f62so769509vkc.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:20:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b67si32445616qke.206.2016.05.31.14.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 14:20:48 -0700 (PDT)
Date: Tue, 31 May 2016 17:20:45 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: The patch "mm, page_alloc: avoid looking up the first zone in a
 zonelist twice" breaks memory management
Message-ID: <alpine.LRH.2.02.1605311706040.16635@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Helge Deller <deller@gmx.de>

Hi

The patch c33d6c06f60f710f0305ae792773e1c2560e1e51 ("mm, page_alloc: avoid 
looking up the first zone in a zonelist twice") breaks memory management 
on PA-RISC.

The PA-RISC system is not NUMA, but the chipset maps physical memory to 
three distinct ranges, so the kernel sets up three nodes. My machine has 
7GiB RAM and the memory is mapped to these ranges:

 Memory Ranges:
  0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
  1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
  2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
 Total Memory: 7166 MB
 On node 0 totalpages: 262144
 free_area_init_node: node 0, pgdat 405e44d0, node_mem_map 415ed000
   Normal zone: 3584 pages used for memmap
   Normal zone: 0 pages reserved
   Normal zone: 262144 pages, LIFO batch:31
 On node 1 totalpages: 785920
 free_area_init_node: node 1, pgdat 405e5140, node_mem_map 140000000
   Normal zone: 10745 pages used for memmap
   Normal zone: 0 pages reserved
   Normal zone: 785920 pages, LIFO batch:31
 On node 2 totalpages: 786432
 free_area_init_node: node 2, pgdat 405e5db0, node_mem_map 4080000000
   Normal zone: 10752 pages used for memmap
   Normal zone: 0 pages reserved
   Normal zone: 786432 pages, LIFO batch:31

Prior to the patch c33d6c06f60f710f0305ae792773e1c2560e1e51, the kernel 
could use all 7GiB of RAM as file cache. After this patch, the kernel 
fills the first 1GiB zone with cache and then starts reclaiming the cache 
(or sometimes even swapping) instead of using the remaining two zones as a 
file cache.

The bug can be reproduced by reading 2GiB file and noticing that the 
amount of cached memory stays near 1GiB.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
