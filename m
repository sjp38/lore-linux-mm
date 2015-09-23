Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7F26B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 20:42:21 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so5543416pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:42:21 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id tq7si6311333pbc.242.2015.09.22.17.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 17:42:20 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so24175716pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:42:20 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
Date: Tue, 22 Sep 2015 17:42:13 -0700
Message-ID: <xr93bncum0ey.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Andrew Morton wrote:

> On Tue, 22 Sep 2015 15:16:32 -0700 Greg Thelen <gthelen@google.com> wrote:
>
>> mem_cgroup_read_stat() returns a page count by summing per cpu page
>> counters.  The summing is racy wrt. updates, so a transient negative sum
>> is possible.  Callers don't want negative values:
>> - mem_cgroup_wb_stats() doesn't want negative nr_dirty or nr_writeback.
>> - oom reports and memory.stat shouldn't show confusing negative usage.
>> - tree_usage() already avoids negatives.
>>
>> Avoid returning negative page counts from mem_cgroup_read_stat() and
>> convert it to unsigned.
>
> Someone please remind me why this code doesn't use the existing
> percpu_counter library which solved this problem years ago.
>
>>   for_each_possible_cpu(cpu)
>
> and which doesn't iterate across offlined CPUs.

I found [1] and [2] discussing memory layout differences between:
a) existing memcg hand rolled per cpu arrays of counters
vs
b) array of generic percpu_counter
The current approach was claimed to have lower memory overhead and
better cache behavior.

I assume it's pretty straightforward to create generic
percpu_counter_array routines which memcg could use.  Possibly something
like this could be made general enough could be created to satisfy
vmstat, but less clear.

[1] http://www.spinics.net/lists/cgroups/msg06216.html
[2] https://lkml.org/lkml/2014/9/11/1057

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
