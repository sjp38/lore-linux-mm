Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8246B04F6
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 02:01:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w187so7871555pgb.10
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 23:01:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id g28si35627plj.626.2017.07.31.23.01.24
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 23:01:25 -0700 (PDT)
Date: Tue, 1 Aug 2017 15:01:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 1/3] mm: migrate: prevent racy access to
 tlb_flush_pending
Message-ID: <20170801060123.GA19932@bbox>
References: <20170731164325.235019-1-namit@vmware.com>
 <20170731164325.235019-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731164325.235019-2-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, stable@vger.kernel.org

On Mon, Jul 31, 2017 at 09:43:23AM -0700, Nadav Amit wrote:
> From: Nadav Amit <nadav.amit@gmail.com>
> 
> Setting and clearing mm->tlb_flush_pending can be performed by multiple
> threads, since mmap_sem may only be acquired for read in
> task_numa_work(). If this happens, tlb_flush_pending might be cleared
> while one of the threads still changes PTEs and batches TLB flushes.
> 
> This can lead to the same race between migration and
> change_protection_range() that led to the introduction of
> tlb_flush_pending. The result of this race was data corruption, which
> means that this patch also addresses a theoretically possible data
> corruption.
> 
> An actual data corruption was not observed, yet the race was
> was confirmed by adding assertion to check tlb_flush_pending is not set
> by two threads, adding artificial latency in change_protection_range()
> and using sysctl to reduce kernel.numa_balancing_scan_delay_ms.
> 
> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
> change_protection_range")
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: stable@vger.kernel.org
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
