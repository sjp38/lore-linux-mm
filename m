Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 806956B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:11:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k14so17831695wrc.16
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 00:11:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si19251337wrd.272.2017.04.18.00.11.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 00:11:56 -0700 (PDT)
Date: Tue, 18 Apr 2017 09:11:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <20170418071153.GC22360@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-04-17 17:06:20, David Rientjes wrote:
> The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> not swap anon pages just because free+file is low'") reintroduces is to
> prefer swapping anonymous memory rather than trashing the file lru.
> 
> If all anonymous memory is unevictable, however, this insistance on
> SCAN_ANON ends up thrashing that lru instead.

Why would be the anonymous memory unevictable? If the swap is depleted
then we enforce file scanning AFAIR. Are those pages pinned somehow, by
who? It would be great if you could describe the workload which triggers
a problem which you are trying to fix.

> Check that enough evictable anon memory is actually on this lruvec before
> insisting on SCAN_ANON.  SWAP_CLUSTER_MAX is used as the threshold to
> determine if only scanning anon is beneficial.
>
> Otherwise, fallback to balanced reclaim so the file lru doesn't remain
> untouched.

Why should we treat anonymous and file pages any different here. In
other words why should file pages check for high wmark and anonymous for
SWAP_CLUSTER_MAX.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
