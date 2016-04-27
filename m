Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19C5F6B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:06:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so40673844wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:06:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v68si9327723wmd.42.2016.04.27.07.06.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 07:06:12 -0700 (PDT)
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5720C753.2000804@suse.cz>
Date: Wed, 27 Apr 2016 16:06:11 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> Every page allocated checks a number of page fields for validity. This
> catches corruption bugs of pages that are already freed but it is expensive.
> This patch weakens the debugging check by checking PCP pages only when
> the PCP lists are being refilled. All compound pages are checked. This
> potentially avoids debugging checks entirely if the PCP lists are never
> emptied and refilled so some corruption issues may be missed. Full checking
> requires DEBUG_VM.
> 
> With the two deferred debugging patches applied, the impact to a page
> allocator microbenchmark is
> 
>                                             4.6.0-rc3                  4.6.0-rc3
>                                           inline-v3r6            deferalloc-v3r7
> Min      alloc-odr0-1               344.00 (  0.00%)           317.00 (  7.85%)
> Min      alloc-odr0-2               248.00 (  0.00%)           231.00 (  6.85%)
> Min      alloc-odr0-4               209.00 (  0.00%)           192.00 (  8.13%)
> Min      alloc-odr0-8               181.00 (  0.00%)           166.00 (  8.29%)
> Min      alloc-odr0-16              168.00 (  0.00%)           154.00 (  8.33%)
> Min      alloc-odr0-32              161.00 (  0.00%)           148.00 (  8.07%)
> Min      alloc-odr0-64              158.00 (  0.00%)           145.00 (  8.23%)
> Min      alloc-odr0-128             156.00 (  0.00%)           143.00 (  8.33%)
> Min      alloc-odr0-256             168.00 (  0.00%)           154.00 (  8.33%)
> Min      alloc-odr0-512             178.00 (  0.00%)           167.00 (  6.18%)
> Min      alloc-odr0-1024            186.00 (  0.00%)           174.00 (  6.45%)
> Min      alloc-odr0-2048            192.00 (  0.00%)           180.00 (  6.25%)
> Min      alloc-odr0-4096            198.00 (  0.00%)           184.00 (  7.07%)
> Min      alloc-odr0-8192            200.00 (  0.00%)           188.00 (  6.00%)
> Min      alloc-odr0-16384           201.00 (  0.00%)           188.00 (  6.47%)
> Min      free-odr0-1                189.00 (  0.00%)           180.00 (  4.76%)
> Min      free-odr0-2                132.00 (  0.00%)           126.00 (  4.55%)
> Min      free-odr0-4                104.00 (  0.00%)            99.00 (  4.81%)
> Min      free-odr0-8                 90.00 (  0.00%)            85.00 (  5.56%)
> Min      free-odr0-16                84.00 (  0.00%)            80.00 (  4.76%)
> Min      free-odr0-32                80.00 (  0.00%)            76.00 (  5.00%)
> Min      free-odr0-64                78.00 (  0.00%)            74.00 (  5.13%)
> Min      free-odr0-128               77.00 (  0.00%)            73.00 (  5.19%)
> Min      free-odr0-256               94.00 (  0.00%)            91.00 (  3.19%)
> Min      free-odr0-512              108.00 (  0.00%)           112.00 ( -3.70%)
> Min      free-odr0-1024             115.00 (  0.00%)           118.00 ( -2.61%)
> Min      free-odr0-2048             120.00 (  0.00%)           125.00 ( -4.17%)
> Min      free-odr0-4096             123.00 (  0.00%)           129.00 ( -4.88%)
> Min      free-odr0-8192             126.00 (  0.00%)           130.00 ( -3.17%)
> Min      free-odr0-16384            126.00 (  0.00%)           131.00 ( -3.97%)
> 
> Note that the free paths for large numbers of pages is impacted as the
> debugging cost gets shifted into that path when the page data is no longer
> necessarily cache-hot.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Unlike the free path, there are no duplications here, which is nice.
Some un-inlining of bad page check should still work here though imho:
