Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84A106B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 08:59:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k1-v6so615439pgq.20
        for <linux-mm@kvack.org>; Thu, 24 May 2018 05:59:11 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id z3-v6si20006655pln.292.2018.05.24.05.59.09
        for <linux-mm@kvack.org>;
        Thu, 24 May 2018 05:59:10 -0700 (PDT)
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
 <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
 <20180522185407.GC20441@dhcp22.suse.cz>
 <455b1a07-d7e3-102b-65e7-3892947b7675@ascade.co.jp>
 <20180524082044.GW20441@dhcp22.suse.cz>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <b2afbff6-b59f-7105-3808-64d41bd4a3a8@ascade.co.jp>
Date: Thu, 24 May 2018 21:58:49 +0900
MIME-Version: 1.0
In-Reply-To: <20180524082044.GW20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 2018/05/24 17:20, Michal Hocko wrote:
> On Thu 24-05-18 13:39:59, TSUKADA Koutaro wrote:
>> On 2018/05/23 3:54, Michal Hocko wrote:
> [...]
>>> I am also quite confused why you keep distinguishing surplus hugetlb
>>> pages from regular preallocated ones. Being a surplus page is an
>>> implementation detail that we use for an internal accounting rather than
>>> something to exhibit to the userspace even more than we do currently.
>>
>> I apologize for having confused.
>>
>> The hugetlb pages obtained from the pool do not waste the buddy pool.
> 
> Because they have already allocated from the buddy allocator so the end
> result is very same.
> 
>> On
>> the other hand, surplus hugetlb pages waste the buddy pool. Due to this
>> difference in property, I thought it could be distinguished.
> 
> But this is simply not correct. Surplus pages are fluid. If you increase
> the hugetlb size they will become regular persistent hugetlb pages.

I really can not understand what's wrong with this. That page is obviously
released before being added to the persistent pool, and at that time it is
uncharged from memcg to which the task belongs(This assumes my patch-set).
After that, the same page obtained from the pool is not surplus hugepage
so it will not be charged to memcg again.

>> Although my memcg knowledge is extremely limited, memcg is accounting for
>> various kinds of pages obtained from the buddy pool by the task belonging
>> to it. I would like to argue that surplus hugepage has specificity in
>> terms of obtaining from the buddy pool, and that it is specially permitted
>> charge requirements for memcg.
> 
> Not really. Memcg accounts primarily for reclaimable memory. We do
> account for some non-reclaimable slabs but the life time should be at
> least bound to a process life time. Otherwise the memcg oom killer
> behavior is not guaranteed to unclutter the situation. Hugetlb pages are
> simply persistent. Well, to be completely honest tmpfs pages have a
> similar problem but lacking the swap space for them is kinda
> configuration bug.

Absolutely you are saying the right thing, but, for example, can mlock(2)ed
pages be swapped out by reclaim?(What is the difference between mlock(2)ed
pages and hugetlb page?)

>> It seems very strange that charge hugetlb page to memcg, but essentially
>> it only charges the usage of the compound page obtained from the buddy pool,
>> and even if that page is used as hugetlb page after that, memcg is not
>> interested in that.
> 
> Ohh, it is very much interested. The primary goal of memcg is to enforce
> the limit. How are you going to do that in an absence of the reclaimable
> memory? And quite a lot of it because hugetlb pages usually consume a
> lot of memory.

Simply kill any of the tasks belonging to that memcg. Maybe, no one wants
reclaim at the time of account of with surplus hugepages.

[...]
>> I could not understand the intention of this question, sorry. When resize
>> the pool, I think that the number of surplus hugepages in use does not
>> change. Could you explain what you were concerned about?
> 
> It does change when you change the hugetlb pool size, migrate pages
> between per-numa pools (have a look at adjust_pool_surplus).

As I looked at, what kind of fatal problem is caused by charging surplus
hugepages to memcg by just manipulating counter of statistical information?

-- 
Thanks,
Tsukada
