Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3F27B82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 08:47:28 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so9954919wic.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 05:47:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o70si8444324wmd.21.2015.11.05.05.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Nov 2015 05:47:26 -0800 (PST)
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B5DE9.70803@suse.cz>
Date: Thu, 5 Nov 2015 14:47:21 +0100
MIME-Version: 1.0
In-Reply-To: <20151020195317.ADA052D8@viggo.jf.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On 10/20/2015 09:53 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I have a hugetlbfs user which is never explicitly allocating huge pages
> with 'nr_hugepages'.  They only set 'nr_overcommit_hugepages' and then let
> the pages be allocated from the buddy allocator at fault time.
> 
> This works, but they noticed that mbind() was not doing them any good and
> the pages were being allocated without respect for the policy they
> specified.
> 
> The code in question is this:
> 
>> struct page *alloc_huge_page(struct vm_area_struct *vma,
> ...
>>         page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
>>         if (!page) {
>>                 page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> 
> dequeue_huge_page_vma() is smart and will respect the VMA's memory policy.
> But, it only grabs _existing_ huge pages from the huge page pool.  If the
> pool is empty, we fall back to alloc_buddy_huge_page() which obviously
> can't do anything with the VMA's policy because it isn't even passed the
> VMA.
> 
> Almost everybody preallocates huge pages.  That's probably why nobody has
> ever noticed this.  Looking back at the git history, I don't think this
> _ever_ worked from when alloc_buddy_huge_page() was introduced in 7893d1d5,
> 8 years ago.
> 
> The fix is to pass vma/addr down in to the places where we actually call in
> to the buddy allocator.  It's fairly straightforward plumbing.  This has
> been lightly tested.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Together with the fix and NUMA=n cleanup

Acked=by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
