Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id DCC9E6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 08:53:05 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id y8so5839996igp.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 05:53:05 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rh6si38045739igc.2.2016.02.11.05.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 05:53:05 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
 <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56BC9281.6090505@virtuozzo.com>
Date: Thu, 11 Feb 2016 16:54:09 +0300
MIME-Version: 1.0
In-Reply-To: <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>



On 02/11/2016 03:24 AM, Tim Chen wrote:
> On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:
> 
>>
>> If a process is unmapping 4MB then it's pretty crazy for us to be
>> hitting the percpu_counter 32 separate times for that single operation.
>>
>> Is there some way in which we can batch up the modifications within the
>> caller and update the counter less frequently?  Perhaps even in a
>> single hit?
> 
> I think the problem is the batch size is too small and we overflow
> the local counter into the global counter for 4M allocations.
> The reason for the small batch size was because we use
> percpu_counter_read_positive in __vm_enough_memory and it is not precise
> and the error could grow with large batch size.
> 
> Let's switch to the precise __percpu_counter_compare that is 
> unaffected by batch size.  It will do precise comparison and only add up
> the local per cpu counters when the global count is not precise
> enough.  
> 

I'm not certain about this. for_each_online_cpu() under spinlock somewhat doubtful.
And if we are close to limit we will be hitting slowpath all the time.


> So maybe something like the following patch with a relaxed batch size.
> I have not tested this patch much other than compiling and booting
> the kernel.  I wonder if this works for Andrey. We could relax the batch
> size further, but that will mean that we will incur the overhead
> of summing the per cpu counters earlier when the global count get close
> to the allowed limit.
> 
> Thanks.
> 
> Tim
> 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
