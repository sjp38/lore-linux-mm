Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD1E6B02C4
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 16:28:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so71787651pgb.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:28:38 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id m1si4635469plb.313.2017.01.19.13.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 13:28:37 -0800 (PST)
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
References: <20170116194052.GA9382@dhcp22.suse.cz>
 <1979f5e1-a335-65d8-8f9a-0aef17898ca1@nvidia.com>
 <20170116214822.GB9382@dhcp22.suse.cz>
 <be93f879-6bc7-a09e-26f3-09c82c669d74@nvidia.com>
 <20170117075100.GB19699@dhcp22.suse.cz>
 <bfd34f15-857f-b721-e27a-a6a1faad1aec@nvidia.com>
 <20170118082146.GC7015@dhcp22.suse.cz>
 <37232cc6-af8b-52e2-3265-9ef0c0d26e5f@nvidia.com>
 <20170119084510.GF30786@dhcp22.suse.cz>
 <f1b2ce94-8448-f744-e9d0-c65f6f68fe18@nvidia.com>
 <20170119095610.GL30786@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <dee51149-0442-7b4f-469c-acbcd0e15aca@nvidia.com>
Date: Thu, 19 Jan 2017 13:28:32 -0800
MIME-Version: 1.0
In-Reply-To: <20170119095610.GL30786@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On 01/19/2017 01:56 AM, Michal Hocko wrote:
> On Thu 19-01-17 01:09:35, John Hubbard wrote:
> [...]
>> So that leaves us with maybe this for documentation?
>>
>>  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL should not be passed in.
>>  * Passing in __GFP_REPEAT is supported, and will cause the following behavior:
>>  * for larger (>64KB) allocations, the first part (kmalloc) will do some
>>  * retrying, before falling back to vmalloc.
>
> I am worried this is just too vague. It doesn't really help user to
> decide whether "do some retrying" is what he really want's or needs.
>
> So I would rather see the following.
> "
>  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
>  * is supported only for large (>32kB) allocations and it should be used when using
>  * kmalloc is preferable because vmalloc fallback has visible performance drawbacks.
> "
>
> I would also add
> "
> Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
> "
>
> Does it sound any better?

Yes, that is good. I like that it helps guide the user. Here's some proposed optional grammar 
tweaks, but even without these, the above is understandable, so either way, I'm happy now:

  * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
  * is supported only for large (>32kB) allocations, and it should be used only if
  * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
  * Please consult with mm people before using any gfp flags other than GFP_KERNEL.

thanks
john h

> --
> Michal Hocko
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
