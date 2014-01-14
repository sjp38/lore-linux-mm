Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 21B256B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 01:56:29 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id n7so1136690lam.15
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 22:56:28 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w6si10633141lag.178.2014.01.13.22.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 22:56:27 -0800 (PST)
Message-ID: <52D4DF97.1010409@parallels.com>
Date: Tue, 14 Jan 2014 10:56:23 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm: vmscan: respect NUMA policy mask when shrinking
 slab on direct reclaim
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com> <a39e4c57c5a8db4d6e5bb8cd070ac807c8c6fce8.1389443272.git.vdavydov@parallels.com> <20140113151132.d07cbc938baf5af70f929120@linux-foundation.org>
In-Reply-To: <20140113151132.d07cbc938baf5af70f929120@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 01/14/2014 03:11 AM, Andrew Morton wrote:
> On Sat, 11 Jan 2014 16:36:33 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> When direct reclaim is executed by a process bound to a set of NUMA
>> nodes, we should scan only those nodes when possible, but currently we
>> will scan kmem from all online nodes even if the kmem shrinker is NUMA
>> aware. That said, binding a process to a particular NUMA node won't
>> prevent it from shrinking inode/dentry caches from other nodes, which is
>> not good. Fix this.
> Seems right.  I worry that reducing the amount of shrinking which
> node-bound processes perform might affect workloads in unexpected ways.

Theoretically, it might, especially for NUMA unaware shrinkers. But
that's how it works for cpusets right now - we do not count pages from
nodes that are not allowed for the current process. Besides, when
counting lru pages for kswapd_shrink_zones(), we also consider only the
node this kswapd runs on so that NUMA unaware shrinkers will be scanned
more aggressively on NUMA enabled setups than NUMA aware ones. So, in
fact, this patch makes policy masks handling consistent with the rest of
the vmscan code.

> I think I'll save this one for 3.15-rc1, OK?

OK, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
