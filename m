Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 778616B02D8
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:40:29 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id k126so42088wmd.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:40:29 -0800 (PST)
Received: from outbound-smtp11.blacknight.com ([46.22.139.106])
        by mx.google.com with ESMTPS id 89si1535602ede.321.2017.11.28.01.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 01:40:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id C846B1C37A7
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:40:25 +0000 (GMT)
Date: Tue, 28 Nov 2017 09:40:25 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/vmscan: try to optimize branch procedures.
Message-ID: <20171128094025.fcnsmafbsp7cjkf6@techsingularity.net>
References: <1511833785-55392-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1511833785-55392-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Tue, Nov 28, 2017 at 09:49:45AM +0800, Jiang Biao wrote:
> 1. Use unlikely to try to improve branch prediction. The
> *total_scan < 0* branch is unlikely to reach, so use unlikely.
> 
> 2. Optimize *next_deferred >= scanned* condition.
> *next_deferred >= scanned* condition could be optimized into
> *next_deferred > scanned*, because when *next_deferred == scanned*,
> next_deferred shoud be 0, which is covered by the else branch.
> 
> 3. Merge two branch blocks into one. The *next_deferred > 0* branch
> could be merged into *next_deferred > scanned* to simplify the code.
> 
> Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>

These are slow paths. Do you have perf data indicating the branches are
frequently mispredicted? Do you have data showing this improves
performance?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
