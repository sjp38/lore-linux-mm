Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 000A36B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:49:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so19637387wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 12:49:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t203si5018817wmg.31.2016.04.26.12.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 12:49:45 -0700 (PDT)
Subject: Re: [PATCH 26/28] cpuset: use static key better and convert to new
 API
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-14-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FC658.3030206@suse.cz>
Date: Tue, 26 Apr 2016 21:49:44 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-14-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Zefan Li <lizefan@huawei.com>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
>
> An important function for cpusets is cpuset_node_allowed(), which optimizes on
> the fact if there's a single root CPU set, it must be trivially allowed. But
> the check "nr_cpusets() <= 1" doesn't use the cpusets_enabled_key static key
> the right way where static keys eliminate branching overhead with jump labels.
>
> This patch converts it so that static key is used properly. It's also switched
> to the new static key API and the checking functions are converted to return
> bool instead of int. We also provide a new variant __cpuset_zone_allowed()
> which expects that the static key check was already done and they key was
> enabled. This is needed for get_page_from_freelist() where we want to also
> avoid the relatively slower check when ALLOC_CPUSET is not set in alloc_flags.
>
> The impact on the page allocator microbenchmark is less than expected but the
> cleanup in itself is worthwhile.
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                       multcheck-v1r20               cpuset-v1r20
> Min      alloc-odr0-1               348.00 (  0.00%)           348.00 (  0.00%)
> Min      alloc-odr0-2               254.00 (  0.00%)           254.00 (  0.00%)
> Min      alloc-odr0-4               213.00 (  0.00%)           213.00 (  0.00%)
> Min      alloc-odr0-8               186.00 (  0.00%)           183.00 (  1.61%)
> Min      alloc-odr0-16              173.00 (  0.00%)           171.00 (  1.16%)
> Min      alloc-odr0-32              166.00 (  0.00%)           163.00 (  1.81%)
> Min      alloc-odr0-64              162.00 (  0.00%)           159.00 (  1.85%)
> Min      alloc-odr0-128             160.00 (  0.00%)           157.00 (  1.88%)
> Min      alloc-odr0-256             169.00 (  0.00%)           166.00 (  1.78%)
> Min      alloc-odr0-512             180.00 (  0.00%)           180.00 (  0.00%)
> Min      alloc-odr0-1024            188.00 (  0.00%)           187.00 (  0.53%)
> Min      alloc-odr0-2048            194.00 (  0.00%)           193.00 (  0.52%)
> Min      alloc-odr0-4096            199.00 (  0.00%)           198.00 (  0.50%)
> Min      alloc-odr0-8192            202.00 (  0.00%)           201.00 (  0.50%)
> Min      alloc-odr0-16384           203.00 (  0.00%)           202.00 (  0.49%)
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vl... ah, no, I actually wrote this one.

But since the cpuset maintainer acked [1] my earlier posting only after Mel 
included it in this series, I think it's worth transferring it here:

Acked-by: Zefan Li <lizefan@huawei.com>

[1] http://marc.info/?l=linux-mm&m=146062276216574&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
