Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6A6F6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:41:54 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so18837451lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 11:41:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c84si4700618wmf.65.2016.04.26.11.41.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 11:41:52 -0700 (PDT)
Subject: Re: [PATCH 23/28] mm, page_alloc: Check multiple page fields with a
 single branch
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-11-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FB66E.80306@suse.cz>
Date: Tue, 26 Apr 2016 20:41:50 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-11-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> Every page allocated or freed is checked for sanity to avoid corruptions
> that are difficult to detect later.  A bad page could be due to a number of
> fields. Instead of using multiple branches, this patch combines multiple
> fields into a single branch. A detailed check is only necessary if that
> check fails.
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                        initonce-v1r20            multcheck-v1r20
> Min      alloc-odr0-1               359.00 (  0.00%)           348.00 (  3.06%)
> Min      alloc-odr0-2               260.00 (  0.00%)           254.00 (  2.31%)
> Min      alloc-odr0-4               214.00 (  0.00%)           213.00 (  0.47%)
> Min      alloc-odr0-8               186.00 (  0.00%)           186.00 (  0.00%)
> Min      alloc-odr0-16              173.00 (  0.00%)           173.00 (  0.00%)
> Min      alloc-odr0-32              165.00 (  0.00%)           166.00 ( -0.61%)
> Min      alloc-odr0-64              162.00 (  0.00%)           162.00 (  0.00%)
> Min      alloc-odr0-128             161.00 (  0.00%)           160.00 (  0.62%)
> Min      alloc-odr0-256             170.00 (  0.00%)           169.00 (  0.59%)
> Min      alloc-odr0-512             181.00 (  0.00%)           180.00 (  0.55%)
> Min      alloc-odr0-1024            190.00 (  0.00%)           188.00 (  1.05%)
> Min      alloc-odr0-2048            196.00 (  0.00%)           194.00 (  1.02%)
> Min      alloc-odr0-4096            202.00 (  0.00%)           199.00 (  1.49%)
> Min      alloc-odr0-8192            205.00 (  0.00%)           202.00 (  1.46%)
> Min      alloc-odr0-16384           205.00 (  0.00%)           203.00 (  0.98%)
>
> Again, the benefit is marginal but avoiding excessive branches is
> important. Ideally the paths would not have to check these conditions at
> all but regrettably abandoning the tests would make use-after-free bugs
> much harder to detect.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

I wonder, would it be just too ugly to add +1 to atomic_read(&page->_mapcount) 
and OR it with the rest for a truly single branch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
