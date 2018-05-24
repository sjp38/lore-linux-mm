Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99BF96B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 10:28:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 142-v6so1322876wmt.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 07:28:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f23-v6si746072edb.409.2018.05.24.07.28.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 07:28:53 -0700 (PDT)
Date: Thu, 24 May 2018 15:24:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
Message-ID: <20180524132414.GI20441@dhcp22.suse.cz>
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <240f1b14-ed7d-4983-6c52-be4899d4caa5@oracle.com>
 <8711fed5-fc35-a11a-3a17-740a9dca1f2a@ascade.co.jp>
 <20180522185407.GC20441@dhcp22.suse.cz>
 <455b1a07-d7e3-102b-65e7-3892947b7675@ascade.co.jp>
 <20180524082044.GW20441@dhcp22.suse.cz>
 <b2afbff6-b59f-7105-3808-64d41bd4a3a8@ascade.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b2afbff6-b59f-7105-3808-64d41bd4a3a8@ascade.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 24-05-18 21:58:49, TSUKADA Koutaro wrote:
> On 2018/05/24 17:20, Michal Hocko wrote:
> > On Thu 24-05-18 13:39:59, TSUKADA Koutaro wrote:
> >> On 2018/05/23 3:54, Michal Hocko wrote:
> > [...]
> >>> I am also quite confused why you keep distinguishing surplus hugetlb
> >>> pages from regular preallocated ones. Being a surplus page is an
> >>> implementation detail that we use for an internal accounting rather than
> >>> something to exhibit to the userspace even more than we do currently.
> >>
> >> I apologize for having confused.
> >>
> >> The hugetlb pages obtained from the pool do not waste the buddy pool.
> > 
> > Because they have already allocated from the buddy allocator so the end
> > result is very same.
> > 
> >> On
> >> the other hand, surplus hugetlb pages waste the buddy pool. Due to this
> >> difference in property, I thought it could be distinguished.
> > 
> > But this is simply not correct. Surplus pages are fluid. If you increase
> > the hugetlb size they will become regular persistent hugetlb pages.
> 
> I really can not understand what's wrong with this. That page is obviously
> released before being added to the persistent pool, and at that time it is
> uncharged from memcg to which the task belongs(This assumes my patch-set).
> After that, the same page obtained from the pool is not surplus hugepage
> so it will not be charged to memcg again.

I do not see anything like that. adjust_pool_surplus is simply and
accounting thing. At least the last time I've checked. Maybe your
patchset handles that?
 
> >> Although my memcg knowledge is extremely limited, memcg is accounting for
> >> various kinds of pages obtained from the buddy pool by the task belonging
> >> to it. I would like to argue that surplus hugepage has specificity in
> >> terms of obtaining from the buddy pool, and that it is specially permitted
> >> charge requirements for memcg.
> > 
> > Not really. Memcg accounts primarily for reclaimable memory. We do
> > account for some non-reclaimable slabs but the life time should be at
> > least bound to a process life time. Otherwise the memcg oom killer
> > behavior is not guaranteed to unclutter the situation. Hugetlb pages are
> > simply persistent. Well, to be completely honest tmpfs pages have a
> > similar problem but lacking the swap space for them is kinda
> > configuration bug.
> 
> Absolutely you are saying the right thing, but, for example, can mlock(2)ed
> pages be swapped out by reclaim?(What is the difference between mlock(2)ed
> pages and hugetlb page?)

No mlocked pages cannot be reclaimed and that is why we restrict them to
a relatively small amount.
 
> >> It seems very strange that charge hugetlb page to memcg, but essentially
> >> it only charges the usage of the compound page obtained from the buddy pool,
> >> and even if that page is used as hugetlb page after that, memcg is not
> >> interested in that.
> > 
> > Ohh, it is very much interested. The primary goal of memcg is to enforce
> > the limit. How are you going to do that in an absence of the reclaimable
> > memory? And quite a lot of it because hugetlb pages usually consume a
> > lot of memory.
> 
> Simply kill any of the tasks belonging to that memcg. Maybe, no one wants
> reclaim at the time of account of with surplus hugepages.

But that will not release the hugetlb memory, does it?
 
> [...]
> >> I could not understand the intention of this question, sorry. When resize
> >> the pool, I think that the number of surplus hugepages in use does not
> >> change. Could you explain what you were concerned about?
> > 
> > It does change when you change the hugetlb pool size, migrate pages
> > between per-numa pools (have a look at adjust_pool_surplus).
> 
> As I looked at, what kind of fatal problem is caused by charging surplus
> hugepages to memcg by just manipulating counter of statistical information?

Fatal? Not sure. It simply tries to add an alien memory to the memcg
concept so I would pressume an unexpected behavior (e.g. not being able
to reclaim memcg or, over reclaim, trashing etc.).
-- 
Michal Hocko
SUSE Labs
