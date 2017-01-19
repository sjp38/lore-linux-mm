Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86B4A6B027D
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:09:41 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so49768488pfb.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:09:41 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w72si2950932pfa.220.2017.01.19.01.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 01:09:38 -0800 (PST)
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
References: <20170116084717.GA13641@dhcp22.suse.cz>
 <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
 <20170116194052.GA9382@dhcp22.suse.cz>
 <1979f5e1-a335-65d8-8f9a-0aef17898ca1@nvidia.com>
 <20170116214822.GB9382@dhcp22.suse.cz>
 <be93f879-6bc7-a09e-26f3-09c82c669d74@nvidia.com>
 <20170117075100.GB19699@dhcp22.suse.cz>
 <bfd34f15-857f-b721-e27a-a6a1faad1aec@nvidia.com>
 <20170118082146.GC7015@dhcp22.suse.cz>
 <37232cc6-af8b-52e2-3265-9ef0c0d26e5f@nvidia.com>
 <20170119084510.GF30786@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f1b2ce94-8448-f744-e9d0-c65f6f68fe18@nvidia.com>
Date: Thu, 19 Jan 2017 01:09:35 -0800
MIME-Version: 1.0
In-Reply-To: <20170119084510.GF30786@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On 01/19/2017 12:45 AM, Michal Hocko wrote:
> On Thu 19-01-17 00:37:08, John Hubbard wrote:
>>
>>
>> On 01/18/2017 12:21 AM, Michal Hocko wrote:
>>> On Tue 17-01-17 21:59:13, John Hubbard wrote:
> [...]
>>>>  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL should not be passed in.
>>>>  * Passing in __GFP_REPEAT is supported, but note that it is ignored for small
>>>>  * (<=64KB) allocations, during the kmalloc attempt.
>>>
>>>> __GFP_REPEAT is fully
>>>>  * honored for  all allocation sizes during the second part: the vmalloc attempt.
>>>
>>> this is not true to be really precise because vmalloc doesn't respect
>>> the given gfp mask all the way down (look at the pte initialization).
>>>
>>
>> I'm having some difficulty in locating that pte initialization part, am I on
>> the wrong code path? Here's what I checked, before making the claim about
>> __GFP_REPEAT being honored:
>>
>> kvmalloc_node
>>   __vmalloc_node_flags
>>     __vmalloc_node
>>       __vmalloc_node_range
>>         __vmalloc_area_node
> 	    map_vm_area
> 	      vmap_page_range
> 	        vmap_page_range_noflush
> 		  vmap_pud_range
> 		    pud_alloc
> 		      __pud_alloc
> 		        pud_alloc_one
>
> pud will be allocated but the same pattern repeats on the pmd and pte
> levels. This is btw. one of the reasons why vmalloc with gfp flags is
> tricky!

Yes, I see that now, thank you for explaining, much appreciated. The flags are left 
way behind in the code path.

So that leaves us with maybe this for documentation?

  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL should not be passed in.
  * Passing in __GFP_REPEAT is supported, and will cause the following behavior:
  * for larger (>64KB) allocations, the first part (kmalloc) will do some
  * retrying, before falling back to vmalloc.


>
> moreover
>>             alloc_pages_node
>
> this is order-0 request so...
>
>>               __alloc_pages_node
>>                 __alloc_pages
>>                   __alloc_pages_nodemask
>>                     __alloc_pages_slowpath
>>
>>
>> ...and __alloc_pages_slowpath does the __GFP_REPEAT handling:
>>
>>     /*
>>      * Do not retry costly high order allocations unless they are
>>      * __GFP_REPEAT
>>      */
>>     if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>>         goto nopage;
>
> ... this doesn't apply
>

yes, true.

thanks
john h

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
