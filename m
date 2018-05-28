Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEEB6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:49:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e26-v6so8110466wmh.7
        for <linux-mm@kvack.org>; Mon, 28 May 2018 01:49:43 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id h10-v6si9773889edr.245.2018.05.28.01.49.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 01:49:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id C6C7698A2C
	for <linux-mm@kvack.org>; Mon, 28 May 2018 08:49:41 +0000 (UTC)
Date: Mon, 28 May 2018 09:49:40 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
Message-ID: <20180528084940.avqh7unxdghvx7ow@techsingularity.net>
References: <20180525130853.13915-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180525130853.13915-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On Fri, May 25, 2018 at 03:08:53PM +0200, Vlastimil Babka wrote:
> In __alloc_pages_slowpath() we reset zonelist and preferred_zoneref for
> allocations that can ignore memory policies. The zonelist is obtained from
> current CPU's node. This is a problem for __GFP_THISNODE allocations that want
> to allocate on a different node, e.g. because the allocating thread has been
> migrated to a different CPU.
> 
> This has been observed to break SLAB in our 4.4-based kernel, because there it
> relies on __GFP_THISNODE working as intended. If a slab page is put on wrong
> node's list, then further list manipulations may corrupt the list because
> page_to_nid() is used to determine which node's list_lock should be locked and
> thus we may take a wrong lock and race.
> 
> Current SLAB implementation seems to be immune by luck thanks to commit
> 511e3a058812 ("mm/slab: make cache_grow() handle the page allocated on
> arbitrary node") but there may be others assuming that __GFP_THISNODE works as
> promised.
> 
> We can fix it by simply removing the zonelist reset completely. There is
> actually no reason to reset it, because memory policies and cpusets don't
> affect the zonelist choice in the first place. This was different when commit
> 183f6371aac2 ("mm: ignore mempolicies when using ALLOC_NO_WATERMARK")
> introduced the code, as mempolicies provided their own restricted zonelists.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Fixes: 183f6371aac2 ("mm: ignore mempolicies when using ALLOC_NO_WATERMARK")

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks.

-- 
Mel Gorman
SUSE Labs
