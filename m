Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 170D86B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 20:57:54 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j26so6308467pff.8
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:57:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r1si3722737pgp.308.2017.12.14.17.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 17:57:53 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap operations
References: <20171214133832.11266-1-ying.huang@intel.com>
	<20171214151718.GS16951@dhcp22.suse.cz>
	<20171214124246.ceebc9c955bd32601c01a28b@linux-foundation.org>
Date: Fri, 15 Dec 2017 09:57:47 +0800
In-Reply-To: <20171214124246.ceebc9c955bd32601c01a28b@linux-foundation.org>
	(Andrew Morton's message of "Thu, 14 Dec 2017 12:42:46 -0800")
Message-ID: <87wp1olplw.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 14 Dec 2017 16:17:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:
>
>> > as fast as possible, SRCU instead of reference count is used to
>> > implement get/put_swap_device().  From get_swap_device() to
>> > put_swap_device(), the reader side of SRCU is locked, so
>> > synchronize_srcu() in swapoff() will wait until put_swap_device() is
>> > called.
>> 
>> It is quite unfortunate to pull SRCU as a dependency to the core kernel.
>> Different attempts to do this have failed in the past. This one is
>> slightly different though because I would suspect that those tiny
>> systems do not configure swap. But who knows, maybe they do.
>> 
>> Anyway, if you are worried about performance then I would expect some
>> numbers to back that worry. So why don't simply start with simpler
>> ref count based and then optimize it later based on some actual numbers.
>> Btw. have you considered pcp refcount framework. I would suspect that
>> this would give you close to SRCU performance.
>
> <squeaky-wheel>Or use stop_kernel() ;)</squeaky-wheel>

Although I still thought SRCU based solution is better, I will prepare a
version with preempt_disable() + stop_machine() or rcu_read_lock() +
synchronize_rcu() based version for people to compare between them.

BTW, it appears that rcu_read_lock() + synchronize_rcu() is better than
preempt_disable() + stop_machine(), why not use it?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
