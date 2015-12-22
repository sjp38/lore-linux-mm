Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 84B8382F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:05:08 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id q3so102377161pav.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:05:08 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id qx6si6809406pab.241.2015.12.22.14.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:05:07 -0800 (PST)
Received: by mail-pa0-x22f.google.com with SMTP id jx14so95437334pad.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:05:07 -0800 (PST)
Date: Tue, 22 Dec 2015 14:05:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/compaction: fix invalid free_pfn and
 compact_cached_free_pfn
In-Reply-To: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1512221404560.5172@chino.kir.corp.google.com>
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 21 Dec 2015, Joonsoo Kim wrote:

> free_pfn and compact_cached_free_pfn are the pointer that remember
> restart position of freepage scanner. When they are reset or invalid,
> we set them to zone_end_pfn because freepage scanner works in reverse
> direction. But, because zone range is defined as [zone_start_pfn,
> zone_end_pfn), zone_end_pfn is invalid to access. Therefore, we should
> not store it to free_pfn and compact_cached_free_pfn. Instead, we need
> to store zone_end_pfn - 1 to them. There is one more thing we should
> consider. Freepage scanner scan reversely by pageblock unit. If free_pfn
> and compact_cached_free_pfn are set to middle of pageblock, it regards
> that sitiation as that it already scans front part of pageblock so we
> lose opportunity to scan there. To fix-up, this patch do round_down()
> to guarantee that reset position will be pageblock aligned.
> 
> Note that thanks to the current pageblock_pfn_to_page() implementation,
> actual access to zone_end_pfn doesn't happen until now. But, following
> patch will change pageblock_pfn_to_page() so this patch is needed
> from now on.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
