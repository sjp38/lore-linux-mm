Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 050652802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 22:28:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d136so55709258qkg.11
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 19:28:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si16260790qtu.224.2017.07.27.19.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 19:28:42 -0700 (PDT)
Message-ID: <1501208919.4073.58.camel@redhat.com>
Subject: Re: [PATCH v3 1/2] mm: migrate: prevent racy access to
 tlb_flush_pending
From: Rik van Riel <riel@redhat.com>
Date: Thu, 27 Jul 2017 22:28:39 -0400
In-Reply-To: <20170727114015.3452-2-namit@vmware.com>
References: <20170727114015.3452-1-namit@vmware.com>
	 <20170727114015.3452-2-namit@vmware.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, linux-mm@kvack.org
Cc: sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, mgorman@suse.de, luto@kernel.org, stable@vger.kernel.org

On Thu, 2017-07-27 at 04:40 -0700, Nadav Amit wrote:
> From: Nadav Amit <nadav.amit@gmail.com>
> 
> Setting and clearing mm->tlb_flush_pending can be performed by
> multiple
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
> was confirmed by adding assertion to check tlb_flush_pending is not
> set
> by two threads, adding artificial latency in
> change_protection_range()
> and using sysctl to reduce kernel.numa_balancing_scan_delay_ms.
> 
> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
> change_protection_range")
> 
> Cc: stable@vger.kernel.org
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> 
Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
