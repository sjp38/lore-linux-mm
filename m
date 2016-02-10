Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 700266B0255
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:00:57 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so15553325pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:00:57 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id c77si6411910pfj.246.2016.02.10.10.00.56
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 10:00:56 -0800 (PST)
Message-ID: <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 10 Feb 2016 10:00:53 -0800
In-Reply-To: <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
	 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Wed, 2016-02-10 at 17:52 +0300, Andrey Ryabinin wrote:
> Currently we use percpu_counter for accounting committed memory. Change
> of committed memory on more than vm_committed_as_batch pages leads to
> grab of counter's spinlock. The batch size is quite small - from 32 pages
> up to 0.4% of the memory/cpu (usually several MBs even on large machines).
> 
> So map/munmap of several MBs anonymous memory in multiple processes leads
> to high contention on that spinlock.
> 
> Instead of percpu_counter we could use ordinary per-cpu variables.
> Dump test case (8-proccesses running map/munmap of 4MB,
> vm_committed_as_batch = 2MB on test setup) showed 2.5x performance
> improvement.
> 
> The downside of this approach is slowdown of vm_memory_committed().
> However, it doesn't matter much since it usually is not in a hot path.
> The only exception is __vm_enough_memory() with overcommit set to
> OVERCOMMIT_NEVER. In that case brk1 test from will-it-scale benchmark
> shows 1.1x - 1.3x performance regression.
> 
> So I think it's a good tradeoff. We've got significantly increased
> scalability for the price of some overhead in vm_memory_committed().

It is a trade off between the counter read speed vs the counter update
speed.  With this change the reading of the counter is slower
because we need to sum over all the cpus each time we need the counter
value.  So this read overhead will grow with the number of cpus and may
not be a good tradeoff for that case.

Wonder if you have tried to tweak the batch size of per cpu counter
and make it a little larger?

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
