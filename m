Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 030716B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:06:40 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so38645292wjb.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:06:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15si1354273wrb.191.2017.01.26.02.06.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:06:38 -0800 (PST)
Date: Thu, 26 Jan 2017 10:05:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct
 reclaim path
Message-ID: <20170126100509.gbf6rxao6gsmqyq3@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:39PM -0500, Johannes Weiner wrote:
> Direct reclaim has been replaced by kswapd reclaim in pretty much all
> common memory pressure situations, so this code most likely doesn't
> accomplish the described effect anymore. The previous patch wakes up
> flushers for all reclaimers when we encounter dirty pages at the tail
> end of the LRU. Remove the crufty old direct reclaim invocation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

In general I like this. I worried first that if kswapd is blocked
writing pages that it won't reach the wakeup_flusher_threads but the
previous patch handles it.

Now though, it occurs to me with the last patch that we always writeout
the world when flushing threads. This may not be a great idea. Consider
for example if there is a heavy writer of short-lived tmp files. In such a
case, it is possible for the files to be truncated before they even hit the
disk. However, if there are multiple "writeout the world" calls, these may
now be hitting the disk. Furthermore, multiplle kswapd and direct reclaimers
could all be requested to writeout the world and each request unplugs.

Is it possible to maintain the property of writing back pages relative
to the numbers of pages scanned or have you determined already that it's
not necessary?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
