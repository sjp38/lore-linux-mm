Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2108B6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:09:37 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so3884347ieb.32
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:09:36 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id bm3si16407121icb.49.2014.07.17.16.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 16:09:36 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 17 Jul 2014 17:09:35 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 36E8D19D8042
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 17:09:21 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6HL5oBC9240854
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:05:50 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6HN9UJe021511
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 17:09:30 -0600
Date: Thu, 17 Jul 2014 16:09:23 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC 0/2] Memoryless nodes and kworker
Message-ID: <20140717230923.GA32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

[Apologies for the large Cc list, but I believe we have the following
interested parties:

x86 (recently posted memoryless node support)
ia64 (existing memoryless node support)
ppc (existing memoryless node support)
previous discussion of how to solve Anton's issue with slab usage
workqueue contributors/maintainers]

There is an issue currently where NUMA information is used on powerpc
(and possibly ia64) before it has been read from the device-tree, which
leads to large slab consumption with CONFIG_SLUB and memoryless nodes.

While testing memoryless nodes on PowerKVM guests with the patches in
this series, with a guest topology of
    
    available: 2 nodes (0-1)
    node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
    node 0 size: 0 MB
    node 0 free: 0 MB
    node 1 cpus: 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
    node 1 size: 16336 MB
    node 1 free: 15329 MB
    node distances:
    node   0   1
      0:  10  40
      1:  40  10
    
the slab consumption decreases from
    
    Slab:             932416 kB
    SUnreclaim:       902336 kB
    
to
    
    Slab:             395264 kB
    SUnreclaim:       359424 kB
    
And we see a corresponding increase in the slab efficiency from
    
    slab                                   mem     objs    slabs
                                          used   active   active
    ------------------------------------------------------------
    kmalloc-16384                       337 MB   11.28%  100.00%
    task_struct                         288 MB    9.93%  100.00%
    
to
    
    slab                                   mem     objs    slabs
                                          used   active   active
    ------------------------------------------------------------
    kmalloc-16384                        37 MB  100.00%  100.00%
    task_struct                          31 MB  100.00%  100.00%

It turns out we see this large slab usage due to using the wrong NUMA
information when creating kthreads.
    
Two changes are required, one of which is in the workqueue code and one
of which is in the powerpc initialization. Note that ia64 may want to
consider something similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
