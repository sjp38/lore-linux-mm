Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 89E124403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 19:15:02 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so5664149wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 16:15:02 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id vn10si20812070wjc.166.2016.02.04.16.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 16:15:01 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id p63so5579360wmp.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 16:15:01 -0800 (PST)
Date: Fri, 5 Feb 2016 02:14:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, hugetlb: don't require CMA for runtime gigantic pages
Message-ID: <20160205001459.GA24412@node.shutemov.name>
References: <1454521811-11409-1-git-send-email-vbabka@suse.cz>
 <20160204060221.GA14877@js1304-P5Q-DELUXE>
 <56B31A31.3070406@suse.cz>
 <56B324D4.6030703@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56B324D4.6030703@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, Feb 04, 2016 at 11:15:48AM +0100, Vlastimil Babka wrote:
> On 02/04/2016 10:30 AM, Vlastimil Babka wrote:
> > On 02/04/2016 07:02 AM, Joonsoo Kim wrote:
> >> On Wed, Feb 03, 2016 at 06:50:11PM +0100, Vlastimil Babka wrote:
> >>> Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
> >>> runtime") has added the runtime gigantic page allocation via
> >>> alloc_contig_range(), making this support available only when CONFIG_CMA is
> >>> enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
> >>> associated infrastructure, it is possible with few simple adjustments to
> >>> require only CONFIG_MEMORY_ISOLATION instead of full CONFIG_CMA.
> >>>
> >>> After this patch, alloc_contig_range() and related functions are available
> >>> and used for gigantic pages with just CONFIG_MEMORY_ISOLATION enabled. Note
> >>> CONFIG_CMA selects CONFIG_MEMORY_ISOLATION. This allows supporting runtime
> >>> gigantic pages without the CMA-specific checks in page allocator fastpaths.
> >>
> >> You need to set CONFIG_COMPACTION or CONFIG_CMA to use
> >> isolate_migratepages_range() and others in alloc_contig_range().
> > 
> > Hm, right, thanks for catching this. I admit I didn't try disabling
> > compaction during the tests.
> 
> Here's a v2. Not the prettiest thing, admittedly.
> 
> ----8<----
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 3 Feb 2016 17:45:26 +0100
> Subject: [PATCH v2] mm, hugetlb: don't require CMA for runtime gigantic pages
> 
> Commit 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at
> runtime") has added the runtime gigantic page allocation via
> alloc_contig_range(), making this support available only when CONFIG_CMA is
> enabled. Because it doesn't depend on MIGRATE_CMA pageblocks and the
> associated infrastructure, it is possible with few simple adjustments to
> require only CONFIG_MEMORY_ISOLATION and CONFIG_COMPACTION instead of full
> CONFIG_CMA.
> 
> After this patch, alloc_contig_range() and related functions are available
> and used for gigantic pages with just CONFIG_MEMORY_ISOLATION and
> CONFIG_COMPACTION enabled (or CONFIG_CMA as before). Note CONFIG_CMA selects
> CONFIG_MEMORY_ISOLATION. This allows supporting runtime gigantic pages without
> the CMA-specific checks in page allocator fastpaths.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Luiz Capitulino <lcapitulino@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/linux/gfp.h | 6 +++---
>  mm/hugetlb.c        | 2 +-
>  mm/page_alloc.c     | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)

One more place missed: gigantic_pages_init() in arch/x86/mm/hugetlbpage.c
Could you relax the check there as well?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
