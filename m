Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4765C8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 09:11:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so2980085edd.11
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 06:11:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13-v6si1366951ejj.300.2019.01.09.06.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 06:11:15 -0800 (PST)
Date: Wed, 9 Jan 2019 15:11:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Message-ID: <20190109141113.GW31793@dhcp22.suse.cz>
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, josef@toxicpanda.com, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 09-01-19 15:20:18, Kirill Tkhai wrote:
> On nodes without memory overcommit, it's common a situation,
> when memcg exceeds its limit and pages from pagecache are
> shrinked on reclaim, while node has a lot of free memory.

Yes, that is the semantic of the hard limit. If the system is not
overcommitted then the hard limit can be used to prevent unexpected
direct reclaim from unrelated activity.

> Further access to the pages requires real device IO, while
> IO causes time delays, worse powerusage, worse throughput
> for other users of the device, etc.

It is to be expected that a memory throttled usage will have this side
effect IMO.

> Cleancache is not a good solution for this problem, since
> it implies copying of page on every cleancache_put_page()
> and cleancache_get_page(). Also, it requires introduction
> of internal per-cleancache_ops data structures to manage
> cached pages and their inodes relationships, which again
> introduces overhead.
> 
> This patchset introduces another solution. It introduces
> a new scheme for evicting memcg pages:
> 
>   1)__remove_mapping() uncharges unmapped page memcg
>     and leaves page in pagecache on memcg reclaim;
> 
>   2)putback_lru_page() places page into root_mem_cgroup
>     list, since its memcg is NULL. Page may be evicted
>     on global reclaim (and this will be easily, as
>     page is not mapped, so shrinker will shrink it
>     with 100% probability of success);
> 
>   3)pagecache_get_page() charges page into memcg of
>     a task, which takes it first.

But this also means that any hard limited memcg can fill up all the
memory and break the above assumption about the isolation from direct
reclaim. Not to mention the OOM or is there anything you do anything
about preventing that?

That beig said, I do not think we want to or even can change the
semantic of the hard limit and break existing setups. I am still
interested to hear more about more detailed/specific usecases that might
benefit from this behavior. Why do those users even use hard limit at
all? To protect from anon memory leaks? Do different memcgs share the
page cache heavily?
-- 
Michal Hocko
SUSE Labs
