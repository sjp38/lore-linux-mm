Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E25336B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 08:38:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so853397wrb.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:38:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v21si2715499pgh.155.2017.03.24.05.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 05:37:00 -0700 (PDT)
Date: Fri, 24 Mar 2017 20:37:10 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
Message-ID: <20170324123710.GA10672@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
 <20170322063335.GF30149@bbox>
 <20170322084103.GC2360@aaronlu.sh.intel.com>
 <4549498a-befc-133d-b204-dd69b191e579@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4549498a-befc-133d-b204-dd69b191e579@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, Mar 23, 2017 at 08:38:43AM -0700, Dave Hansen wrote:
> On 03/22/2017 01:41 AM, Aaron Lu wrote:
> > On Wed, Mar 22, 2017 at 03:33:35PM +0900, Minchan Kim wrote:
> >> On Wed, Mar 15, 2017 at 05:00:02PM +0800, Aaron Lu wrote:
> >>> Introduce a workqueue for all the free workers so that user can fine
> >>> tune how many workers can be active through sysfs interface: max_active.
> >>> More workers will normally lead to better performance, but too many can
> >>> cause severe lock contention.
> >>
> >> Let me ask a question.
> >>
> >> How well can workqueue distribute the jobs in multiple CPU?
> > 
> > I would say it's good enough for my needs.
> > After all, it doesn't need many kworkers to achieve the 50% time
> > decrease: 2-4 kworkers for EP and 4-8 kworkers for EX are enough from
> > previous attched data.
> 
> It's also worth noting that we'd like to *also* like to look into
> increasing how scalable freeing pages to a given zone is.

Still on EX, I restricted the allocation to be only on node 1, with
120G memory allocated there:

max_active            time            compared to base  lock from perf
base(no parallel)     3.81s A+-3.3%     N/A               <1%
1                     3.10s A+-7.7%     a??18.6%            14.76%
2                     2.44s A+-13.6%    a??35.9%            36.95%
4                     2.07s A+-13.6%    a??45.6%            59.67%
8                     1.98s A+-0.4%     a??48.0%            62.59%
16                    2.01s A+-2.4%     a??47.2%            79.62%

If we can improve the scalibility of freeing a given zone, then parallel
free will be able to achieve more.

BTW, the lock is basically pgdat->lru_lock in release_pages and
zone->lock in free_pcppages_bulk:
    62.59%    62.59%  [kernel.kallsyms]  [k] native_queued_spin_lock_slowpath
37.17% native_queued_spin_lock_slowpath;_raw_spin_lock_irqsave;free_pcppages_bulk;free_hot_cold_page;free_hot_cold_page_list;release_pages;free_pages_and_swap_cache;tlb_flush_mmu_free_batches;batch_free_work;process_one_work;worker_thread;kthread;ret_from_fork
25.27% native_queued_spin_lock_slowpath;_raw_spin_lock_irqsave;release_pages;free_pages_and_swap_cache;tlb_flush_mmu_free_batches;batch_free_work;process_one_work;worker_thread;kthread;ret_from_fork

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
