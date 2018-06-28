Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF8AF6B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 16:21:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q8-v6so4633808wmc.2
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 13:21:01 -0700 (PDT)
Received: from mx0a-00190b01.pphosted.com (mx0a-00190b01.pphosted.com. [2620:100:9001:583::1])
        by mx.google.com with ESMTPS id o63-v6si4738083wmd.63.2018.06.28.13.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 13:20:59 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
 <20180612074646.GS13364@dhcp22.suse.cz>
 <5a9398f4-453c-5cb5-6bbc-f20c3affc96a@akamai.com>
 <0daccb7c-f642-c5ce-ca7a-3b3e69025a1e@suse.cz>
 <20180613071552.GD13364@dhcp22.suse.cz>
 <7a671035-92dc-f9c0-aa7b-ff916d556e82@akamai.com>
 <20180620110022.GK13685@dhcp22.suse.cz>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <4ab6d77a-3032-3ffb-d556-b736f6b983e6@akamai.com>
Date: Thu, 28 Jun 2018 16:20:54 -0400
MIME-Version: 1.0
In-Reply-To: <20180620110022.GK13685@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net



On 06/20/2018 07:00 AM, Michal Hocko wrote:
> On Fri 15-06-18 15:36:07, Jason Baron wrote:
>>
>>
>> On 06/13/2018 03:15 AM, Michal Hocko wrote:
>>> On Wed 13-06-18 08:32:19, Vlastimil Babka wrote:
> [...]
>>>> BTW I didn't get why we should allow this for MADV_DONTNEED but not
>>>> MADV_FREE. Can you expand on that?
>>>
>>> Well, I wanted to bring this up as well. I guess this would require some
>>> more hacks to handle the reclaim path correctly because we do rely on
>>> VM_LOCK at many places for the lazy mlock pages culling.
>>>
>>
>> The point of not allowing MADV_FREE on mlock'd pages for me was that
>> with mlock and even MLOCK_ON_FAULT, one can always can always determine
>> if a page is present or not (and thus avoid the major fault). Allowing
>> MADV_FREE on lock'd pages breaks that assumption.
> 
> But once you have called MADV_FREE you cannot assume anything about the
> content until you touch the memory again. So you can safely assume a
> major fault for the worst case. Btw. why knowing whether you major fault
> is important in the first place? What is an application going to do
> about that information?
> 

Fair enough, I think that means you end up with a MADV_FREE_FORCE to
support that case? As I said I worked around this by using tmpfs and
fallocate(FALLOC_FL_PUNCH_HOLE). However, I still think there is a
use-case for doing this for anonymous memory, to avoid the unlock() calls.

The use-case I had in mind was simply an application that has a fast
path for when it knows that the requested item is locked in memory.

Thanks,

-Jason
