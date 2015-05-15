Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 86E4A6B0070
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:36:59 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so58447911wic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:36:59 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id fa5si146423wjc.199.2015.05.15.04.36.57
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 04:36:58 -0700 (PDT)
Date: Fri, 15 May 2015 14:36:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 05/28] mm: adjust FOLL_SPLIT for new refcounting
Message-ID: <20150515113646.GE6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-6-git-send-email-kirill.shutemov@linux.intel.com>
 <5555D2F7.5070301@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5555D2F7.5070301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 01:05:27PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >We need to prepare kernel to allow transhuge pages to be mapped with
> >ptes too. We need to handle FOLL_SPLIT in follow_page_pte().
> >
> >Also we use split_huge_page() directly instead of split_huge_page_pmd().
> >split_huge_page_pmd() will gone.
> 
> You still call split_huge_page_pmd() for the is_huge_zero_page(page) case.

For huge zero page we split PMD into table of zero pages and don't touch
compound page under it. That's what split_huge_page_pmd() (renamed into
split_huge_pmd()) will do by the end of patchset.

> Also, of the code around split_huge_page() you basically took from
> split_huge_page_pmd() and open-coded into follow_page_mask(), you didn't
> include the mmu notifier calls. Why are they needed in split_huge_page_pmd()
> but not here?

We do need mmu notifier in split_huge_page_pmd() for huge zero page. When
we need to split compound page we go into split_huge_page() which takes
care about mmut notifiers.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
