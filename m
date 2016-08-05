Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1E546B0261
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:21:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so155155593lfw.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:15:12 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id x62si8652793wmd.112.2016.08.05.05.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 05:32:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 9424D1C1EB6
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 13:32:53 +0100 (IST)
Date: Fri, 5 Aug 2016 13:32:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] metag: Drop show_mem() from mem_init()
Message-ID: <20160805123251.GT2799@techsingularity.net>
References: <20160805121704.32198-1-james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160805121704.32198-1-james.hogan@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: linux-metag@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 05, 2016 at 01:17:04PM +0100, James Hogan wrote:
> The recent commit 599d0c954f91 ("mm, vmscan: move LRU lists to node"),
> changed memory management code so that show_mem() is no longer safe to
> call prior to setup_per_cpu_pageset(), as pgdat->per_cpu_nodestats will
> still be NULL. This causes an oops on metag due to the call to
> show_mem() from mem_init():
> 
>   node_page_state_snapshot(...) + 0x48
>   pgdat_reclaimable(struct pglist_data * pgdat = 0x402517a0)
>   show_free_areas(unsigned int filter = 0) + 0x2cc
>   show_mem(unsigned int filter = 0) + 0x18
>   mem_init()
>   mm_init()
>   start_kernel() + 0x204
> 
> This wasn't a problem before with zone_reclaimable() as zone_pcp_init()
> was already setting zone->pageset to &boot_pageset, via setup_arch() and
> paging_init(), which happens before mm_init():
> 
>   zone_pcp_init(...)
>   free_area_init_core(...) + 0x138
>   free_area_init_node(int nid = 0, ...) + 0x1a0
>   free_area_init_nodes(...) + 0x440
>   paging_init(unsigned long mem_end = 0x4fe00000) + 0x378
>   setup_arch(char ** cmdline_p = 0x4024e038) + 0x2b8
>   start_kernel() + 0x54
> 
> No other arches appear to call show_mem() during boot, and it doesn't
> really add much value to the log, so lets just drop it from mem_init().
> 
> Signed-off-by: James Hogan <james.hogan@imgtec.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
