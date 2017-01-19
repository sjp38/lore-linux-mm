Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0A866B0272
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:37:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so48371855pgf.3
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:37:11 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k20si2870865pfa.244.2017.01.19.00.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 00:37:10 -0800 (PST)
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
References: <20170112153717.28943-2-mhocko@kernel.org>
 <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
 <20170116084717.GA13641@dhcp22.suse.cz>
 <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
 <20170116194052.GA9382@dhcp22.suse.cz>
 <1979f5e1-a335-65d8-8f9a-0aef17898ca1@nvidia.com>
 <20170116214822.GB9382@dhcp22.suse.cz>
 <be93f879-6bc7-a09e-26f3-09c82c669d74@nvidia.com>
 <20170117075100.GB19699@dhcp22.suse.cz>
 <bfd34f15-857f-b721-e27a-a6a1faad1aec@nvidia.com>
 <20170118082146.GC7015@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <37232cc6-af8b-52e2-3265-9ef0c0d26e5f@nvidia.com>
Date: Thu, 19 Jan 2017 00:37:08 -0800
MIME-Version: 1.0
In-Reply-To: <20170118082146.GC7015@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>



On 01/18/2017 12:21 AM, Michal Hocko wrote:
> On Tue 17-01-17 21:59:13, John Hubbard wrote:
>>
>> On 01/16/2017 11:51 PM, Michal Hocko wrote:
>>> On Mon 16-01-17 13:57:43, John Hubbard wrote:
>>>>
>>>>
>>>> On 01/16/2017 01:48 PM, Michal Hocko wrote:
>>>>> On Mon 16-01-17 13:15:08, John Hubbard wrote:
>>>>>>
>>>>>>
>>>>>> On 01/16/2017 11:40 AM, Michal Hocko wrote:
>>>>>>> On Mon 16-01-17 11:09:37, John Hubbard wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>> On 01/16/2017 12:47 AM, Michal Hocko wrote:
>>>>>>>>> On Sun 15-01-17 20:34:13, John Hubbard wrote:
>>>>>>> [...]
>>>>>>>>>> Is that "Reclaim modifiers" line still true, or is it a leftover from an
>>>>>>>>>> earlier approach? I am having trouble reconciling it with rest of the
>>>>>>>>>> patchset, because:
>>>>>>>>>>
>>>>>>>>>> a) the flags argument below is effectively passed on to either kmalloc_node
>>>>>>>>>> (possibly adding, but not removing flags), or to __vmalloc_node_flags.
>>>>>>>>>
>>>>>>>>> The above only says thos are _unsupported_ - in other words the behavior
>>>>>>>>> is not defined. Even if flags are passed down to kmalloc resp. vmalloc
>>>>>>>>> it doesn't mean they are used that way.  Remember that vmalloc uses
>>>>>>>>> some hardcoded GFP_KERNEL allocations.  So while I could be really
>>>>>>>>> strict about this and mask away these flags I doubt this is worth the
>>>>>>>>> additional code.
>>>>>>>>
>>>>>>>> I do wonder about passing those flags through to kmalloc. Maybe it is worth
>>>>>>>> stripping out __GFP_NORETRY and __GFP_NOFAIL, after all. It provides some
>>>>>>>> insulation from any future changes to the implementation of kmalloc, and it
>>>>>>>> also makes the documentation more believable.
>>>>>>>
>>>>>>> I am not really convinced that we should take an extra steps for these
>>>>>>> flags. There are no existing users for those flags and new users should
>>>>>>> follow the documentation.
>>>>>>
>>>>>> OK, let's just fortify the documentation ever so slightly, then, so that
>>>>>> users are more likely to do the right thing. How's this sound:
>>>>>>
>>>>>> * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. (Even
>>>>>> * though the current implementation passes the flags on through to kmalloc and
>>>>>> * vmalloc, that is done for efficiency and to avoid unnecessary code. The caller
>>>>>> * should not pass in these flags.)
>>>>>> *
>>>>>> * __GFP_REPEAT is supported, but only for large (>64kB) allocations.
>>>>>>
>>>>>>
>>>>>> ? Or is that documentation overkill?
>>>>>
>>>>> Dunno, it sounds like an overkill to me. It is telling more than
>>>>> necessary. If we want to be so vocal about gfp flags then we would have
>>>>> to say much more I suspect. E.g. what about __GFP_HIGHMEM? This flag is
>>>>> supported for vmalloc while unsupported for kmalloc. I am pretty sure
>>>>> there would be other gfp flags to consider and then this would grow
>>>>> borringly large and uninteresting to the point when people simply stop
>>>>> reading it. Let's just be as simple as possible.
>>>>
>>>> Agreed, on the simplicity point: simple and clear is ideal. But here, it's
>>>> merely short, and not quite simple. :)  People will look at that short bit
>>>> of documentation, and then notice that the flags are, in fact, all passed
>>>> right on through down to both kmalloc_node and __vmalloc_node_flags.
>>>>
>>>> If you don't want too much documentation, then I'd be inclined to say
>>>> something higher-level, about the intent, rather than mentioning those two
>>>> flags directly. Because as it stands, the documentation contradicts what the
>>>> code does.
>>>
>>> Feel free to suggest a better wording. I am, of course, open to any
>>> changes.
>>
>> OK, here's the best I've got, I tried to keep it concise, but (as you
>> suspected) I'm not sure it's actually any better than the original:
>>
>>  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL should not be passed in.
>>  * Passing in __GFP_REPEAT is supported, but note that it is ignored for small
>>  * (<=64KB) allocations, during the kmalloc attempt.
>
>> __GFP_REPEAT is fully
>>  * honored for  all allocation sizes during the second part: the vmalloc attempt.
>
> this is not true to be really precise because vmalloc doesn't respect
> the given gfp mask all the way down (look at the pte initialization).
>

I'm having some difficulty in locating that pte initialization part, am I on the 
wrong code path? Here's what I checked, before making the claim about __GFP_REPEAT 
being honored:

kvmalloc_node
   __vmalloc_node_flags
     __vmalloc_node
       __vmalloc_node_range
         __vmalloc_area_node
             alloc_pages_node
               __alloc_pages_node
                 __alloc_pages
                   __alloc_pages_nodemask
                     __alloc_pages_slowpath


...and __alloc_pages_slowpath does the __GFP_REPEAT handling:

     /*
      * Do not retry costly high order allocations unless they are
      * __GFP_REPEAT
      */
     if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
         goto nopage;

thanks,
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
