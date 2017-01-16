Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9BE6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:15:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so265131218pfy.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 13:15:11 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n22si22637033pfj.253.2017.01.16.13.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 13:15:10 -0800 (PST)
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-2-mhocko@kernel.org>
 <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
 <20170116084717.GA13641@dhcp22.suse.cz>
 <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
 <20170116194052.GA9382@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1979f5e1-a335-65d8-8f9a-0aef17898ca1@nvidia.com>
Date: Mon, 16 Jan 2017 13:15:08 -0800
MIME-Version: 1.0
In-Reply-To: <20170116194052.GA9382@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>



On 01/16/2017 11:40 AM, Michal Hocko wrote:
> On Mon 16-01-17 11:09:37, John Hubbard wrote:
>>
>>
>> On 01/16/2017 12:47 AM, Michal Hocko wrote:
>>> On Sun 15-01-17 20:34:13, John Hubbard wrote:
> [...]
>>>> Is that "Reclaim modifiers" line still true, or is it a leftover from an
>>>> earlier approach? I am having trouble reconciling it with rest of the
>>>> patchset, because:
>>>>
>>>> a) the flags argument below is effectively passed on to either kmalloc_node
>>>> (possibly adding, but not removing flags), or to __vmalloc_node_flags.
>>>
>>> The above only says thos are _unsupported_ - in other words the behavior
>>> is not defined. Even if flags are passed down to kmalloc resp. vmalloc
>>> it doesn't mean they are used that way.  Remember that vmalloc uses
>>> some hardcoded GFP_KERNEL allocations.  So while I could be really
>>> strict about this and mask away these flags I doubt this is worth the
>>> additional code.
>>
>> I do wonder about passing those flags through to kmalloc. Maybe it is worth
>> stripping out __GFP_NORETRY and __GFP_NOFAIL, after all. It provides some
>> insulation from any future changes to the implementation of kmalloc, and it
>> also makes the documentation more believable.
>
> I am not really convinced that we should take an extra steps for these
> flags. There are no existing users for those flags and new users should
> follow the documentation.

OK, let's just fortify the documentation ever so slightly, then, so that users are more likely to do 
the right thing. How's this sound:

* Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. (Even
* though the current implementation passes the flags on through to kmalloc and
* vmalloc, that is done for efficiency and to avoid unnecessary code. The caller
* should not pass in these flags.)
*
* __GFP_REPEAT is supported, but only for large (>64kB) allocations.


? Or is that documentation overkill?

thanks
john h

>
> --
> Michal Hocko
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
