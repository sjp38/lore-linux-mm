Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEAE6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:32:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so12649972wme.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:32:29 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id yy9si5912091wjc.217.2016.06.24.02.32.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:32:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id EF4569890B
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 09:32:27 +0000 (UTC)
Date: Fri, 24 Jun 2016 10:32:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, vmscan: Make kswapd reclaim no more than needed
Message-ID: <20160624093226.GE1868@techsingularity.net>
References: <082f01d1cdf6$c789a2b0$569ce810$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <082f01d1cdf6$c789a2b0$569ce810$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 24, 2016 at 04:59:55PM +0800, Hillf Danton wrote:
> We stop reclaiming pages if any eligible zone is balanced.
> 
> Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>

wakeup_kswapd avoids waking kswapd in the first place if there are balanced
zones. The current code will do at least one reclaim pass if the situation
changes between the wakeup request and kswapd actually waking so some
progress will be made. The risk for strict enforcement is that small low
zones like DMA will be quickly generally balanced but only for very short
periods of time and kswapd will fall behind. It *shouldn't* matter as
the pages allocated from DMA will remain resident until the full node
LRU cycles through but it's a possibility.

I'll test the patch and make sure kswapd still reclaims at the correct
rate. Did you this test yourself with any reclaim intensive workload to
see if kswapd fell behind forcing more stalls in direct reclaim?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
