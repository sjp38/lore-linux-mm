Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 820326B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 23:09:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so3626341wml.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 20:09:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ea8si5133316wjb.92.2016.08.11.20.09.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 20:09:30 -0700 (PDT)
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
References: <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
 <20160728054947.GL12670@dastard> <20160728102513.GA2799@techsingularity.net>
 <20160729001340.GM12670@dastard> <20160729130005.GE2799@techsingularity.net>
From: Tony Jones <tonyj@suse.de>
Message-ID: <15d2252f-8bb9-287b-0006-ef42bc8efd27@suse.de>
Date: Thu, 11 Aug 2016 20:09:25 -0700
MIME-Version: 1.0
In-Reply-To: <20160729130005.GE2799@techsingularity.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/29/2016 06:00 AM, Mel Gorman wrote:
> On Fri, Jul 29, 2016 at 10:13:40AM +1000, Dave Chinner wrote:
>> On Thu, Jul 28, 2016 at 11:25:13AM +0100, Mel Gorman wrote:
>>> On Thu, Jul 28, 2016 at 03:49:47PM +1000, Dave Chinner wrote:
>>>> Seems you're all missing the obvious.
>>>>
>>>> Add a tracepoint for a shrinker callback that includes a "name"
>>>> field, have the shrinker callback fill it out appropriately. e.g
>>>> in the superblock shrinker:
>>>>
>>>> 	trace_shrinker_callback(shrinker, shrink_control, sb->s_type->name);
>>>>
>>>
>>> That misses capturing the latency of the call unless there is a begin/end
>>> tracepoint.
>>
>> Sure, but I didn't see that in the email talking about how to add a
>> name. Even if it is a requirement, it's not necessary as we've
>> already got shrinker runtime measurements from the
>> trace_mm_shrink_slab_start and trace_mm_shrink_slab_end trace
>> points. With the above callback event, shrinker call runtime is
>> simply the time between the calls to the same shrinker within
>> mm_shrink_slab start/end trace points.
>>
> 
> Fair point. It's not that hard to correlate them.

True but the scan_objects callback is only called if we have >batch_size objects.

It's possible to accumulate quite some time without calling the callback and being able to obtain 
the s_type->name.   So this time all gets associated with just super_cache_scan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
