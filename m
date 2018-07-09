Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4796B0273
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 03:38:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so9548224plo.9
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 00:38:56 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d5-v6si14586032pla.337.2018.07.09.00.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 00:38:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-4-ying.huang@intel.com>
	<CAA9_cmc2YteXBhrLOFN0rAZ4UFDRPcXaE1OPNv06P+Fu9e+zeA@mail.gmail.com>
Date: Mon, 09 Jul 2018 15:38:39 +0800
In-Reply-To: <CAA9_cmc2YteXBhrLOFN0rAZ4UFDRPcXaE1OPNv06P+Fu9e+zeA@mail.gmail.com>
	(Dan Williams's message of "Sat, 7 Jul 2018 16:22:54 -0700")
Message-ID: <8736wsluyo.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, n-horiguchi@ah.jp.nec.com, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

Dan Williams <dan.j.williams@gmail.com> writes:

> On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> To support to swapin the THP as a whole, we need to create PMD swap
>> mapping during swapout, and maintain PMD swap mapping count.  This
>> patch implements the support to increase the PMD swap mapping
>> count (for swapout, fork, etc.)  and set SWAP_HAS_CACHE flag (for
>> swapin, etc.) for a huge swap cluster in swap_duplicate() function
>> family.  Although it only implements a part of the design of the swap
>> reference count with PMD swap mapping, the whole design is described
>> as follow to make it easy to understand the patch and the whole
>> picture.
>>
>> A huge swap cluster is used to hold the contents of a swapouted THP.
>> After swapout, a PMD page mapping to the THP will become a PMD
>> swap mapping to the huge swap cluster via a swap entry in PMD.  While
>> a PTE page mapping to a subpage of the THP will become the PTE swap
>> mapping to a swap slot in the huge swap cluster via a swap entry in
>> PTE.
>>
>> If there is no PMD swap mapping and the corresponding THP is removed
>> from the page cache (reclaimed), the huge swap cluster will be split
>> and become a normal swap cluster.
>>
>> The count (cluster_count()) of the huge swap cluster is
>> SWAPFILE_CLUSTER (= HPAGE_PMD_NR) + PMD swap mapping count.  Because
>> all swap slots in the huge swap cluster are mapped by PTE or PMD, or
>> has SWAP_HAS_CACHE bit set, the usage count of the swap cluster is
>> HPAGE_PMD_NR.  And the PMD swap mapping count is recorded too to make
>> it easy to determine whether there are remaining PMD swap mappings.
>>
>> The count in swap_map[offset] is the sum of PTE and PMD swap mapping
>> count.  This means when we increase the PMD swap mapping count, we
>> need to increase swap_map[offset] for all swap slots inside the swap
>> cluster.  An alternative choice is to make swap_map[offset] to record
>> PTE swap map count only, given we have recorded PMD swap mapping count
>> in the count of the huge swap cluster.  But this need to increase
>> swap_map[offset] when splitting the PMD swap mapping, that may fail
>> because of memory allocation for swap count continuation.  That is
>> hard to dealt with.  So we choose current solution.
>>
>> The PMD swap mapping to a huge swap cluster may be split when unmap a
>> part of PMD mapping etc.  That is easy because only the count of the
>> huge swap cluster need to be changed.  When the last PMD swap mapping
>> is gone and SWAP_HAS_CACHE is unset, we will split the huge swap
>> cluster (clear the huge flag).  This makes it easy to reason the
>> cluster state.
>>
>> A huge swap cluster will be split when splitting the THP in swap
>> cache, or failing to allocate THP during swapin, etc.  But when
>> splitting the huge swap cluster, we will not try to split all PMD swap
>> mappings, because we haven't enough information available for that
>> sometimes.  Later, when the PMD swap mapping is duplicated or swapin,
>> etc, the PMD swap mapping will be split and fallback to the PTE
>> operation.
>>
>> When a THP is added into swap cache, the SWAP_HAS_CACHE flag will be
>> set in the swap_map[offset] of all swap slots inside the huge swap
>> cluster backing the THP.  This huge swap cluster will not be split
>> unless the THP is split even if its PMD swap mapping count dropped to
>> 0.  Later, when the THP is removed from swap cache, the SWAP_HAS_CACHE
>> flag will be cleared in the swap_map[offset] of all swap slots inside
>> the huge swap cluster.  And this huge swap cluster will be split if
>> its PMD swap mapping count is 0.
>>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>> ---
>>  include/linux/huge_mm.h |   5 +
>>  include/linux/swap.h    |   9 +-
>>  mm/memory.c             |   2 +-
>>  mm/rmap.c               |   2 +-
>>  mm/swap_state.c         |   2 +-
>>  mm/swapfile.c           | 287 +++++++++++++++++++++++++++++++++---------------
>>  6 files changed, 214 insertions(+), 93 deletions(-)
>
> I'm probably missing some background, but I find the patch hard to
> read. Can you disseminate some of this patch changelog into kernel-doc
> commentary so it's easier to follow which helpers do what relative to
> THP swap.

Yes.  This is a good idea.  Thanks for pointing it out.  I will add more
kernel-doc commentary to make the code easier to be understood.

>>
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index d3bbf6bea9e9..213d32e57c39 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -80,6 +80,11 @@ extern struct kobj_attribute shmem_enabled_attr;
>>  #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
>>  #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
>>
>> +static inline bool thp_swap_supported(void)
>> +{
>> +       return IS_ENABLED(CONFIG_THP_SWAP);
>> +}
>> +
>>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>  #define HPAGE_PMD_SHIFT PMD_SHIFT
>>  #define HPAGE_PMD_SIZE ((1UL) << HPAGE_PMD_SHIFT)
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index f73eafcaf4e9..57aa655ab27d 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -451,8 +451,8 @@ extern swp_entry_t get_swap_page_of_type(int);
>>  extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
>>  extern int add_swap_count_continuation(swp_entry_t, gfp_t);
>>  extern void swap_shmem_alloc(swp_entry_t);
>> -extern int swap_duplicate(swp_entry_t);
>> -extern int swapcache_prepare(swp_entry_t);
>> +extern int swap_duplicate(swp_entry_t *entry, bool cluster);
>
> This patch introduces a new flag to swap_duplicate(), but then all all
> usages still pass 'false' so why does this patch change the argument.
> Seems this change belongs to another patch?

This patch just introduce the capability to deal with huge swap entry in
swap_duplicate() family functions.  The first user of the huge swap
entry is in

[PATCH -mm -v4 08/21] mm, THP, swap: Support to read a huge swap cluster for swapin a THP

via swapcache_prepare().

Yes, it is generally better to put the implementation and the user into
one patch.  But I found in that way, I have to put most code of this
patchset into single huge patch, that is not good for review too.  So I
made some compromise to separate the implementation and the users into
different patches to make the size of single patch not too huge.  Does
this make sense to you?

>> +extern int swapcache_prepare(swp_entry_t entry, bool cluster);
>
> Rather than add a cluster flag to these helpers can the swp_entry_t
> carry the cluster flag directly?

Matthew Wilcox suggested to replace the "cluster" flag with the number
of entries to make the interface more flexible.  And he suggest to use a
very smart way to encode the nr_entries into swap_entry_t with something
like,

https://plus.google.com/117536210417097546339/posts/hvctn17WUZu

But I think we need to

- encode swap type, swap offset, nr_entries into a new swp_entry_t
- call a function
- decode the new swp_entry_t in the function

So it appears that it doesn't bring real value except reduce one
parameter.  Or you suggest something else?

Best Regards,
Huang, Ying
