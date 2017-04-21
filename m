Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21BF76B0038
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:31:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b87so578159wmi.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 21:31:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z10si664511wmh.69.2017.04.20.21.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 21:31:32 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L4SgJJ055557
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:31:31 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29xucare7b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:31:27 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Apr 2017 14:30:47 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L4UZeY4784422
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:30:43 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L4U6sJ004848
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:30:06 +1000
Subject: Re: [PATCH v5 03/11] mm: thp: introduce separate TTU flag for thp
 freezing
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-4-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 09:59:43 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-4-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4806dc43-c416-cdb4-f4b5-60553afae036@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> TTU_MIGRATION is used to convert pte into migration entry until thp split
> completes. This behavior conflicts with thp migration added later patches,
> so let's introduce a new TTU flag specifically for freezing.
> 
> try_to_unmap() is used both for thp split (via freeze_page()) and page
> migration (via __unmap_and_move()). In freeze_page(), ttu_flag given for
> head page is like below (assuming anonymous thp):
> 
>     (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
>      TTU_MIGRATION | TTU_SPLIT_HUGE_PMD)
> 
> and ttu_flag given for tail pages is:
> 
>     (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
>      TTU_MIGRATION)
> 
> __unmap_and_move() calls try_to_unmap() with ttu_flag:
> 
>     (TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS)
> 
> Now I'm trying to insert a branch for thp migration at the top of
> try_to_unmap_one() like below
> 
> static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>                        unsigned long address, void *arg)
>   {
>           ...
>           if (flags & TTU_MIGRATION) {
>               if (!pvmw.pte && page) {
>                   set_pmd_migration_entry(&pvmw, page);
>                   continue;
>               }
>           }
> 
> , so try_to_unmap() for tail pages called by thp split can go into thp
> migration code path (which converts *pmd* into migration entry), while
> the expectation is to freeze thp (which converts *pte* into migration entry.)
> 
> I detected this failure as a "bad page state" error in a testcase where
> split_huge_page() is called from queue_pages_pte_range().
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

It had Kirril's acked-by (https://patchwork.kernel.org/patch/9416221/)
last time around. Please include again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
