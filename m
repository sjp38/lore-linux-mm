Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8CA18E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 06:10:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u13-v6so5860733pfm.8
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 03:10:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k6-v6si8779595pgb.446.2018.09.15.03.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 15 Sep 2018 03:10:49 -0700 (PDT)
Date: Sat, 15 Sep 2018 03:10:42 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v10 PATCH 0/3] mm: zap pages with read mmap_sem in munmap
 for large mapping
Message-ID: <20180915101042.GD31572@bombadil.infradead.org>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 15, 2018 at 04:34:56AM +0800, Yang Shi wrote:
> Regression and performance data:
> Did the below regression test with setting thresh to 4K manually in the code:
>   * Full LTP
>   * Trinity (munmap/all vm syscalls)
>   * Stress-ng: mmap/mmapfork/mmapfixed/mmapaddr/mmapmany/vm
>   * mm-tests: kernbench, phpbench, sysbench-mariadb, will-it-scale
>   * vm-scalability
> 
> With the patches, exclusive mmap_sem hold time when munmap a 80GB address
> space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us level
> from second.
> 
> munmap_test-15002 [008]   594.380138: funcgraph_entry: |  __vm_munmap {
> munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
> munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }
> 
> Here the excution time of unmap_region() is used to evaluate the time of
> holding read mmap_sem, then the remaining time is used with holding
> exclusive lock.

Something I've been wondering about for a while is whether we should "sort"
the readers together.  ie if the acquirers look like this:

A write
B read
C read
D write
E read
F read
G write

then we should grant the lock to A, BCEF, D, G rather than A, BC, D, EF, G.
A quick way to test this is in __rwsem_down_read_failed_common do
something like:

-	if (list_empty(&sem->wait_list))
+	if (list_empty(&sem->wait_list)) {
 		adjustment += RWSEM_WAITING_BIAS;
+		list_add(&waiter.list, &sem->wait_list);
+	} else {
+		struct rwsem_waiter *first = list_first_entry(&sem->wait_list,
+						struct rwsem_waiter, list);
+		if (first.type == RWSEM_WAITING_FOR_READ)
+			list_add(&waiter.list, &sem->wait_list);
+		else
+			list_add_tail(&waiter.list, &sem->wait_list);
+	}
-	list_add_tail(&waiter.list, &sem->wait_list);

It'd be interesting to know if this makes any difference with your tests.

(this isn't perfect, of course; it'll fail to sort readers together if there's
a writer at the head of the queue; eg:

A write
B write
C read
D write
E read
F write
G read

but it won't do any worse than we have at the moment).
