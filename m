Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B81CF6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:17:44 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so12921081pab.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 09:17:44 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id kw10si6573557pab.162.2015.09.25.09.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 09:17:44 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so12920855pab.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 09:17:43 -0700 (PDT)
References: <20150925152533.GP16497@dhcp22.suse.cz>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
In-reply-to: <20150925152533.GP16497@dhcp22.suse.cz>
Date: Fri, 25 Sep 2015 09:17:41 -0700
Message-ID: <xr93h9milbh6.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org


Michal Hocko wrote:

> On Tue 22-09-15 15:16:32, Greg Thelen wrote:
>> mem_cgroup_read_stat() returns a page count by summing per cpu page
>> counters.  The summing is racy wrt. updates, so a transient negative sum
>> is possible.  Callers don't want negative values:
>> - mem_cgroup_wb_stats() doesn't want negative nr_dirty or nr_writeback.
>
> OK, this can confuse dirty throttling AFAIU
>
>> - oom reports and memory.stat shouldn't show confusing negative usage.
>
> I guess this is not earth shattering.
>
>> - tree_usage() already avoids negatives.
>> 
>> Avoid returning negative page counts from mem_cgroup_read_stat() and
>> convert it to unsigned.
>> 
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> I guess we want that for stable 4.2 because of the dirty throttling
> part. Longterm we should use generic per-cpu counter.
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!

Correct, this is not an earth shattering patch.  The patch only filters
out negative memcg stat values from mem_cgroup_read_stat() callers.
Negative values should only be temporary due to stat update races.  So
I'm not sure it's worth sending it to stable.  I've heard no reports of
it troubling anyone.  The worst case without this patch is that memcg
temporarily burps up a negative dirty and/or writeback count which
causes balance_dirty_pages() to sleep for a (at most) 200ms nap
(MAX_PAUSE).  Ccing Tejun in case there are more serious consequences to
balance_dirty_pages() occasionally seeing a massive (underflowed) dirty
or writeback count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
