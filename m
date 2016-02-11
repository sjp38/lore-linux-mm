Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 553E86B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:20:51 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x65so33264473pfb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:20:51 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id l80si14000930pfj.31.2016.02.11.10.20.49
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 10:20:50 -0800 (PST)
Message-ID: <1455214844.715.86.camel@schen9-desk2.jf.intel.com>
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 11 Feb 2016 10:20:44 -0800
In-Reply-To: <56BC9281.6090505@virtuozzo.com>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
	 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
	 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
	 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
	 <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
	 <56BC9281.6090505@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Hansen <dave@sr71.net>

On Thu, 2016-02-11 at 16:54 +0300, Andrey Ryabinin wrote:
> 
> On 02/11/2016 03:24 AM, Tim Chen wrote:
> > On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:
> > 
> >>
> >> If a process is unmapping 4MB then it's pretty crazy for us to be
> >> hitting the percpu_counter 32 separate times for that single operation.
> >>
> >> Is there some way in which we can batch up the modifications within the
> >> caller and update the counter less frequently?  Perhaps even in a
> >> single hit?
> > 
> > I think the problem is the batch size is too small and we overflow
> > the local counter into the global counter for 4M allocations.
> > The reason for the small batch size was because we use
> > percpu_counter_read_positive in __vm_enough_memory and it is not precise
> > and the error could grow with large batch size.
> > 
> > Let's switch to the precise __percpu_counter_compare that is 
> > unaffected by batch size.  It will do precise comparison and only add up
> > the local per cpu counters when the global count is not precise
> > enough.  
> > 
> 
> I'm not certain about this. for_each_online_cpu() under spinlock somewhat doubtful.
> And if we are close to limit we will be hitting slowpath all the time.
> 

Yes, it is a trade-off between faster allocation for the general case vs
being on slowpath when we are within 3% of the memory limit. I'm
thinking when we are that close to the memory limit, it probably 
takes more time to do page reclaim and this slow path might be a
secondary effect.  But still it will be better than the original
proposal that strictly uses per cpu variables as we will then 
need to sum the variables up all the time.

The brk1 test is also somewhat pathologic.  It
does nothing but brk which is unlikely for real workload.
So we have to be careful when we are tuning our system
behavior for brk1 throughput. We'll need to make sure
whatever changes we made don't impact other more useful
workloads adversely.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
