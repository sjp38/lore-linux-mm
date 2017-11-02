Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF936B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:04:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 11so2982171wrb.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:04:36 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id n11si2650144edi.458.2017.11.02.06.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 06:04:34 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 3C8B81C1C2D
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:04:34 +0000 (GMT)
Date: Thu, 2 Nov 2017 13:04:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] mm, compaction: extend pageblock_skip_persistent()
 to all compound pages
Message-ID: <20171102130433.5n3n45gwttgcj3nj@techsingularity.net>
References: <20171102121706.21504-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171102121706.21504-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Nov 02, 2017 at 01:17:04PM +0100, Vlastimil Babka wrote:
> The pageblock_skip_persistent() function checks for HugeTLB pages of pageblock
> order. When clearing pageblock skip bits for compaction, the bits are not
> cleared for such pageblocks, because they cannot contain base pages suitable
> for migration, nor free pages to use as migration targets.
> 
> This optimization can be simply extended to all compound pages of order equal
> or larger than pageblock order, because migrating such pages (if they support
> it) cannot help sub-pageblock fragmentation. This includes THP's and also
> gigantic HugeTLB pages, which the current implementation doesn't persistently
> skip due to a strict pageblock_order equality check and not recognizing tail
> pages.
> 
> While THP pages are generally less "persistent" than HugeTLB, we can still
> expect that if a THP exists at the point of __reset_isolation_suitable(), it
> will exist also during the subsequent compaction run. The time difference here
> could be actually smaller than between a compaction run that sets a
> (non-persistent) skip bit on a THP, and the next compaction run that observes
> it.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
