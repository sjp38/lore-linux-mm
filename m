Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C261F6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 04:07:02 -0400 (EDT)
Received: by padbj2 with SMTP id bj2so607156pad.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 01:07:02 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id zp7si35918658pac.216.2015.09.21.01.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 01:07:01 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so112262681pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 01:07:01 -0700 (PDT)
References: <55FC24C2.8020501@intel.com>
From: Greg Thelen <gthelen@google.com>
Subject: Re: 4.3-rc1 dirty page count underflow (cgroup-related?)
In-reply-to: <55FC24C2.8020501@intel.com>
Date: Mon, 21 Sep 2015 01:06:58 -0700
Message-ID: <xr93pp1cmc0t.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>


Dave Hansen wrote:

> On 09/17/2015 11:09 PM, Greg Thelen wrote:
>> I'm not denying the issue, bug the WARNING splat isn't necessarily
>> catching a problem.  The corresponding code comes from your debug patch:
>> +		WARN_ONCE(__this_cpu_read(memcg->stat->count[MEM_CGROUP_STAT_DIRTY]) > (1UL<<30), "MEM_CGROUP_STAT_DIRTY bogus");
>> 
>> This only checks a single cpu's counter, which can be negative.  The sum
>> of all counters is what matters.
>> Imagine:
>> cpu1) dirty page: inc
>> cpu2) clean page: dec
>> The sum is properly zero, but cpu2 is -1, which will trigger the WARN.
>> 
>> I'll look at the code and also see if I can reproduce the failure using
>> mem_cgroup_read_stat() for all of the new WARNs.
>
> D'oh.  I'll replace those with the proper mem_cgroup_read_stat() and
> test with your patch to see if anything still triggers.

Thanks Dave.

Here's what I think we should use to fix the issue.  I tagged this for
v4.2 stable given the way that unpatched performance falls apart without
warning or workaround (besides deleting and recreating affected memcg).
Feedback welcome.
