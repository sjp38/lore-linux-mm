Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1EB6B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 21:50:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k17so11612327pfj.10
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 18:50:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6-v6sor5850329plt.105.2018.04.01.18.50.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 18:50:35 -0700 (PDT)
Date: Mon, 2 Apr 2018 09:50:26 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/memblock: fix potential issue in
 memblock_search_pfn_nid()
Message-ID: <20180402015026.GA32938@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180330033055.22340-1-richard.weiyang@gmail.com>
 <20180330135727.67251c7ea8c2db28b404e0e1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330135727.67251c7ea8c2db28b404e0e1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, yinghai@kernel.org, linux-mm@kvack.org, hejianet@gmail.com, "3 . 12+" <stable@vger.kernel.org>

On Fri, Mar 30, 2018 at 01:57:27PM -0700, Andrew Morton wrote:
>On Fri, 30 Mar 2018 11:30:55 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> memblock_search_pfn_nid() returns the nid and the [start|end]_pfn of the
>> memory region where pfn sits in. While the calculation of start_pfn has
>> potential issue when the regions base is not page aligned.
>> 
>> For example, we assume PAGE_SHIFT is 12 and base is 0x1234. Current
>> implementation would return 1 while this is not correct.
>
>Why is this not correct?  The caller might want the pfn of the page
>which covers the base?
>

Hmm... the only caller of memblock_search_pfn_nid() is __early_pfn_to_nid(),
which returns the nid of a pfn and save the [start_pfn, end_pfn] with in the
same memory region to a cache. So this looks not a good practice to store
un-exact pfn in the cache.

>> This patch fixes this by using PFN_UP().
>> 
>> The original commit is commit e76b63f80d93 ("memblock, numa: binary search
>> node id") and merged in v3.12.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> Cc: 3.12+ <stable@vger.kernel.org>
>
>Please fully describe the runtime effects of a bug when fixing that
>bug.  This description doesn't give enough justification for merging
>the patch into mainline, let alone -stable.

Since PFN_UP() and PFN_DOWN() differs when the address is not page aligned, in
theory we may have two situations like below.

Case 1: non-continuous memory region

   [0x1000, 0x2fff]     [0x4123, 0x5fff]

Case 2: continuous memory region

   [0x1000, 0x4ff2]     [0x4ff3, 0x5fff]

memblock_search_pfn_nid() is only used by __early_pfn_to_nid() to search
for node id for pfn and cache the range, there would be two potential issues
at runtime respectively:

    Case 1. Return a node id for an invalid pfn
    Case 2. Return an incorrect node id

Neither of them do some damage to sytem. At most, it affects some performance
of read/write on the page that pfn points to.

For Case 1, pfn 0x4 would be though on the second memory region's node, while
it is not a valid pfn.

For Case 2, pfn 0x4 would be thought on the second memory region's node, while
the node is not defined id in this case.

But these two cases in theory would not happen in reality even we would have
the memory layout like this. Since 0x4 is not a valid pfn at all.

Last but not the least, more important impact on this code is misleading to
the audience. They would thought the pfn range of a memory region is 

	[PFN_DOWN(base), PFN_DOWN(end))

instead of 

	[PFN_UP(base), PFN_DOWN(end))

even in reality they are the same usually.

For example in this discussion thread. https://lkml.org/lkml/2018/3/29/143
The author use this range to search the pfn, which is not exact.

-- 
Wei Yang
Help you, Help me
