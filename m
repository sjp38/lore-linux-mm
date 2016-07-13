Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 452826B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:17:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so28877944lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 02:17:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si5149603ljj.6.2016.07.13.02.17.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 02:17:15 -0700 (PDT)
Date: Wed, 13 Jul 2016 10:17:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fix calculation accounting dirtyable highmem
Message-ID: <20160713091711.GI11400@suse.de>
References: <1468376593-26444-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1468376593-26444-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 13, 2016 at 11:23:13AM +0900, Minchan Kim wrote:
> When I tested vmscale in mmtest in 32bit, I found the benchmark
> was slow down 0.5 times.
> 
>                 base        node
>                    1    global-1
> User           12.98       16.04
> System        147.61      166.42
> Elapsed        26.48       38.08
> 
> With vmstat, I found IO wait avg is much increased compared to
> base.
> 
> The reason was highmem_dirtyable_memory accumulates free pages
> and highmem_file_pages from HIGHMEM to MOVABLE zones which was
> wrong. With that, dirth_thresh in throtlle_vm_write is always
> 0 so that it calls congestion_wait frequently if writeback
> starts.
> 
> With this patch, it is much recovered.
> 
>                 base        node          fi
>                    1    global-1         fix
> User           12.98       16.04       13.78
> System        147.61      166.42      143.92
> Elapsed        26.48       38.08       29.64
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Thanks. I'll pick this up and send a follow-on series to Andrew with
this included.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
