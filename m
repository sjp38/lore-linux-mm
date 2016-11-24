Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03C4C6B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 18:59:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so136171486pgc.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 15:59:26 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id a3si12878495plc.322.2016.11.24.15.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 15:59:26 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 3so4291645pgd.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 15:59:26 -0800 (PST)
Subject: Re: [PATCH 0/5] Parallel hugepage migration optimization
References: <20161122162530.2370-1-zi.yan@sent.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <9cf7f4c6-6dde-9dbb-cf93-7874437a442d@gmail.com>
Date: Fri, 25 Nov 2016 10:59:20 +1100
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-1-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>



On 23/11/16 03:25, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> Hi all,
> 
> This patchset boosts the hugepage migration throughput and helps THP migration
> which is added by Naoya's patches: https://lwn.net/Articles/705879/.
> 
> Motivation
> ===============================
> 
> In x86, 4KB page migrations are underutilizing the memory bandwidth compared
> to 2MB THP migrations. I did some page migration benchmarking on a two-socket
> Intel Xeon E5-2640v3 box, which has 23.4GB/s bandwidth, and discover
> there are big throughput gap, ~3x, between 4KB and 2MB page migrations.
> 
> Here are the throughput numbers for different page sizes and page numbers:
>         | 512 4KB pages | 1 2MB THP  |  1 4KB page
> x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s
> 
> As Linux currently use single-threaded page migration, the throughput is still
> much lower than the hardware bandwidth, 2.97GB/s vs 23.4GB/s. So I parallelize
> the copy_page() part of THP migration with workqueue and achieve 2.8x throughput.
> 
> Here are the throughput numbers of 2MB page migration:
>            |  single-threaded   | 8-thread
> x86_64 2MB |    2.97GB/s        | 8.58GB/s
> 

Whats the impact on CPU utilization? Is there a huge impact?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
