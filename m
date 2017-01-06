Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46EE46B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 03:57:09 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id j10so125000322wjb.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 00:57:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y184si2007099wmy.123.2017.01.06.00.57.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 00:57:08 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
References: <20161230131412.GI13301@dhcp22.suse.cz>
 <20161230140651.nud2ozpmvmziqyx4@suse.de>
 <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
 <20170105102722.GH21618@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <69fedf28-dcbe-0fcc-2fa3-2ceb06ed47bf@suse.cz>
Date: Fri, 6 Jan 2017 09:57:05 +0100
MIME-Version: 1.0
In-Reply-To: <20170105102722.GH21618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>

On 01/05/2017 11:27 AM, Michal Hocko wrote:
> On Thu 05-01-17 10:53:59, Vlastimil Babka wrote:
>>>> Therefore I believe we need a watermark based pro-active compaction
>>>> which would keep the background compaction busy as long as we have
>>>> less pages of the configured order.
>>
>> Again, configured by what, admin? I would rather try to avoid tunables
>> here, if possible. While THP is quite well known example with stable
>> order, the pressure for other orders is rather implementation specific
>> (drivers, SLAB/SLUB) and may change with kernel versions (e.g. virtually
>> mapped stacks, although that example is about non-costly order). Would
>> the admin be expected to study the implementation to know which orders
>> are needed, or react to page allocation failure reports? Neither sounds
>> nice.
> 
> That is a good question but I expect that there are more users than THP
> which use stable orders. E.g. networking stack tends to depend on the
> packet size. A tracepoint with some histogram output would tell us what
> is the requested orders distribution.

Maybe, but there might be also multiple users of the same order but
different "importance"...

>>>> kcompactd should wake up
>>>> periodically, I think, and check for the status so that we can catch
>>>> the fragmentation before we get low on memory.
>>>> The interface could look something like:
>>>> /proc/sys/vm/compact_wmark
>>>> time_period order count
>>
>> IMHO it would be better if the system could auto-tune this, e.g. by
>> counting high-order alloc failures/needs for direct compaction per order
>> between wakeups, and trying to bring them to zero.
> 
> auto-tunning is usually preferable I am just wondering how the admin can
> tell what is still the system load price he is willing to pay. I suspect
> we will see growing number of opportunistic high order requests over
> time and  auto tunning shouldn't try to accomodate with it without
> any bounds.There is still some cost/benefit to be evaluated from the
> system level point of view which I am afraid is hard to achive from the
> kcompactd POV.

That's why I mentioned that importance should be judged somehow.
Opportunistic requests should be recognizable by their gfp flags, so
hopefully there's a way. I wouldn't mind some general tunable(s) to
express how much effort to give to "important" allocations and
opportunistic ones, but rather not in such implementation-detail form as
"time_period order count".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
