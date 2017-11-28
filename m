Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8416A6B02DF
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:46:05 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i17so70502wmb.7
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:46:05 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id y89si3698257eda.294.2017.11.28.01.46.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 01:46:04 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 2214E99101
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:46:04 +0000 (UTC)
Date: Tue, 28 Nov 2017 09:46:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/vmscan: try to optimize branch procedures.
Message-ID: <20171128094603.2umepkakzhh44eqa@techsingularity.net>
References: <20171128080339.i3ktwm565pz7om4v@dhcp22.suse.cz>
 <201711281719103258154@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201711281719103258154@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.biao2@zte.com.cn
Cc: mhocko@kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Tue, Nov 28, 2017 at 05:19:10PM +0800, jiang.biao2@zte.com.cn wrote:
> > On Tue 28-11-17 09:49:45, Jiang Biao wrote:> > 1. Use unlikely to try to improve branch prediction. The
> > > *total_scan < 0* branch is unlikely to reach, so use unlikely.
> > >
> > > 2. Optimize *next_deferred >= scanned* condition.
> > > *next_deferred >= scanned* condition could be optimized into
> > > *next_deferred > scanned*, because when *next_deferred == scanned*,
> > > next_deferred shoud be 0, which is covered by the else branch.
> > >
> > > 3. Merge two branch blocks into one. The *next_deferred > 0* branch
> > > could be merged into *next_deferred > scanned* to simplify the code.
> > 
> > How have you measured benefit of this patch?
> No accurate measurement for now.
> Theoretically, unlikely could improve branch prediction for unlikely branch.

In general, it only really matters for a heavily mispredicted path in a
fast path. It's not enforced very often but seeing a dedicated patch
making the change to a slow path is not very convincing.

> It's hard to measure the benefit of 2 and 3, any idea to do that enlightened 
> would be greatly appreciated. :)

Typically done using perf to check for mispredictions and showing a
reduction. It can also have icache benefits if code that is almost dead
is moved to another part of the function by the compiler reducing icache
pressure overall. Again, it only really matters in fast path.

> But it could simply code logic from coding 
> perspective???

It doesn't carry enough weight to stand on its own.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
