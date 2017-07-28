Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAF96B051D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:43:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k68so8504102wmd.14
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:43:56 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 6si10709299edc.550.2017.07.28.03.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 03:43:55 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 237E51C1FAA
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:43:55 +0100 (IST)
Date: Fri, 28 Jul 2017 11:43:54 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 5/6] mm, compaction: stop when number of free pages
 goes below watermark
Message-ID: <20170728104354.tjctext47mkxlfyc@techsingularity.net>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <20170727160701.9245-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727160701.9245-6-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 27, 2017 at 06:07:00PM +0200, Vlastimil Babka wrote:
> When isolating free pages as miration targets in __isolate_free_page(),

s/miration/migration/

> compaction respects the min watermark. Although it checks that there's enough
> free pages above the watermark in __compaction_suitable() before starting to
> compact, parallel allocation may result in their depletion. Compaction will
> detect this only after needlessly scanning many pages for migration,
> potentially wasting CPU time.
> 
> After this patch, we check if we are still above the watermark in
> __compact_finished(). For kcompactd, we check the low watermark instead of min
> watermark, because that's the point when kswapd is woken up and it's better to
> let kswapd finish freeing memory before doing kcompactd work.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Otherwise I cannot see a problem. Some compaction opportunities might be
"missed" but they're ones that potentially cause increased direct
reclaim or kswapd reclaim activity.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
