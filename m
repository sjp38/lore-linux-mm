Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 01AC16B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 10:18:56 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so249852bkb.6
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:18:56 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lv5si293290bkb.202.2013.12.18.07.18.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 07:18:56 -0800 (PST)
Date: Wed, 18 Dec 2013 10:18:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218151846.GM21724@cmpxchg.org>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218145111.GA27510@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218145111.GA27510@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 03:51:11PM +0100, Michal Hocko wrote:
> On Tue 17-12-13 15:02:10, Johannes Weiner wrote:
> [...]
> > +pagecache_mempolicy_mode:
> > +
> > +This is available only on NUMA kernels.
> > +
> > +Per default, the configured memory policy is applicable to anonymous
> > +memory, shmem, tmpfs, etc., whereas pagecache is allocated in an
> > +interleaving fashion over all allowed nodes (hardbindings and
> > +zone_reclaim_mode excluded).
> > +
> > +The assumption is that, when it comes to pagecache, users generally
> > +prefer predictable replacement behavior regardless of NUMA topology
> > +and maximizing the cache's effectiveness in reducing IO over memory
> > +locality.
> 
> Isn't page spreading (PF_SPREAD_PAGE) intended to do the same thing
> semantically? The setting is per-cpuset rather than global which makes
> it harder to use but essentially it tries to distribute page cache pages
> across all the nodes.
>
> This is really getting confusing. We have zone_reclaim_mode to keep
> memory local in general, pagecache_mempolicy_mode to keep page cache
> local and PF_SPREAD_PAGE to spread the page cache around nodes.

zone_reclaim_mode is a global setting to go through great lengths to
stay on local nodes, intended to be used depending on the hardware,
not the workload.

Mempolicy on the other hand is to optimize placement for maximum
locality depending on access patterns of a workload or even just the
subset of a workload.  I'm trying to change whether this applies to
page cache (due to different locality / cache effectiveness tradeoff)
and we want to provide pagecache_mempolicy_mode to revert in the field
in case this is a mistake.

PF_SPREAD_PAGE becomes implied per default and should eventually be
removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
