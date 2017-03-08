Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2248831FA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:46:43 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u108so12055418wrb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:46:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r124si616662wma.43.2017.03.08.08.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:46:42 -0800 (PST)
Date: Wed, 8 Mar 2017 11:46:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 0/8] try to reduce fragmenting fallbacks
Message-ID: <20170308164631.GA12130@cmpxchg.org>
References: <20170307131545.28577-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com

On Tue, Mar 07, 2017 at 02:15:37PM +0100, Vlastimil Babka wrote:
> Last year, Johannes Weiner has reported a regression in page mobility
> grouping [1] and while the exact cause was not found, I've come up with some
> ways to improve it by reducing the number of allocations falling back to
> different migratetype and causing permanent fragmentation.

I finally managed to get a handful of our machines on 4.10 with these
patches applied and a 4.10 vanilla control group.

The sampling period is over twelve hours, which is on the short side
for evaluating that load, so take the results with a grain of salt.

The allocstall rate (events per second) is down on average, but there
are occasionally fairly high spikes that exceed the peaks in 4.10:

http://cmpxchg.org/antifrag/allocstallrate.png

Activity from the compaction free scanner is down, while the migration
scanner does more work. I would assume most of this is coming from the
same-migratetype restriction on the source blocks:

http://cmpxchg.org/antifrag/compactfreescannedrate.png
http://cmpxchg.org/antifrag/compactmigratescannedrate.png

Unfortunately, the average compaction stall rate is consistently much
higher with the patches. The 1h rate averages are 2-3x higher:

http://cmpxchg.org/antifrag/compactstallrate.png

An increase in direct compaction is a bit worrisome, but the task
completion rates - the bottom line metric for this workload - are
still too chaotic to say whether the increased allocation latency
affects us meaningfully here. I'll give it a few more days.

Is there any other data you would like me to gather?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
