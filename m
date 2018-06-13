Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9B5F6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 03:51:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4-v6so1127651wmh.0
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 00:51:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x42-v6si2304995edm.257.2018.06.13.00.51.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jun 2018 00:51:26 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5eb9a018-d5ac-5732-04f1-222c343b840a@suse.cz>
Date: Wed, 13 Jun 2018 09:51:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180613071552.GD13364@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jason Baron <jbaron@akamai.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net

On 06/13/2018 09:15 AM, Michal Hocko wrote:
> On Wed 13-06-18 08:32:19, Vlastimil Babka wrote:
>> On 06/12/2018 04:11 PM, Jason Baron wrote:
>>>
>>>
>>> On 06/12/2018 03:46 AM, Michal Hocko wrote:
>>>> On Mon 11-06-18 12:23:58, Jason Baron wrote:
>>>>> On 06/11/2018 11:03 AM, Michal Hocko wrote:
>>>>>> So can we start discussing whether we want to allow MADV_DONTNEED on
>>>>>> mlocked areas and what downsides it might have? Sure it would turn the
>>>>>> strong mlock guarantee to have the whole vma resident but is this
>>>>>> acceptable for something that is an explicit request from the owner of
>>>>>> the memory?
>>>>>>
>>>>>
>>>>> If its being explicity requested by the owner it makes sense to me. I
>>>>> guess there could be a concern about this breaking some userspace that
>>>>> relied on MADV_DONTNEED not freeing locked memory?
>>>>
>>>> Yes, this is always the fear when changing user visible behavior.  I can
>>>> imagine that a userspace allocator calling MADV_DONTNEED on free could
>>>> break. The same would apply to MLOCK_ONFAULT/MCL_ONFAULT though. We
>>>> have the new flag much shorter so the probability is smaller but the
>>>> problem is very same. So I _think_ we should treat both the same because
>>>> semantically they are indistinguishable from the MADV_DONTNEED POV. Both
>>>> remove faulted and mlocked pages. Mlock, once applied, should guarantee
>>>> no later major fault and MADV_DONTNEED breaks that obviously.
>>
>> I think more concerning than guaranteeing no later major fault is
>> possible data loss, e.g. replacing data with zero-filled pages.
> 
> But MADV_DONTNEED is an explicit call for data loss. Or do I miss your
> point?

My point is that if somebody is relying on MADV_DONTNEED not affecting
mlocked pages, the consequences will be unexpected data loss, not just
extra page faults.

>> The madvise manpage is also quite specific about not allowing
>> MADV_DONTNEED and MADV_FREE for locked pages.
> 
> Yeah, but that seems to describe the state of the art rather than
> explain why.

Right, but as it's explicitly described there, it makes it more likely
that somebody is relying on it.

>> So I don't think we should risk changing that for all mlocked pages.
>> Maybe we can risk MCL_ONFAULT, since it's relatively new and has few users?
> 
> That is what Jason wanted but I argued that the two are the same from
> MADV_DONTNEED point of view. I do not see how treating them differently
> would be less confusing or error prone. It's new so we can make it
> behave differently is certainly not an argument.

Right. Might be either this inconsistency, or a new flag.
