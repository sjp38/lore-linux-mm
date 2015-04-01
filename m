Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B12856B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 02:38:46 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so43009926pac.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 23:38:46 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id hm17si1433603pad.46.2015.03.31.23.38.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 23:38:45 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 1 Apr 2015 12:08:42 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id CEB8C125804F
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 12:10:20 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t316caCl65929228
	for <linux-mm@kvack.org>; Wed, 1 Apr 2015 12:08:36 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t316cZ04014682
	for <linux-mm@kvack.org>; Wed, 1 Apr 2015 12:08:36 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound page
In-Reply-To: <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 01 Apr 2015 12:08:35 +0530
Message-ID: <87lhicbbf8.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Current split_huge_page() combines two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> changes split_huge_pmd() implementation to split the given PMD without
> splitting other PMDs this page mapped with or underlying compound page.
>
> In order to do this we have to get rid of tail page refcounting, which
> uses _mapcount of tail pages. Tail page refcounting is needed to be able
> to split THP page at any point: we always know which of tail pages is
> pinned (i.e. by get_user_pages()) and can distribute page count
> correctly.
>
> We can avoid this by allowing split_huge_page() to fail if the compound
> page is pinned. This patch removes all infrastructure for tail page
> refcounting and make split_huge_page() to always return -EBUSY. All
> split_huge_page() users already know how to handle its fail. Proper
> implementation will be added later.
>
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>

With this we now have pte mapping part of a compound page(). Now the
gneric gup implementation does

gup_pte_range()
	ptem = ptep = pte_offset_map(&pmd, addr);
	do {

....
...
		if (!page_cache_get_speculative(page))
			goto pte_unmap;
.....
        }

That page_cache_get_speculative will fail in our case because it does
if (unlikely(!get_page_unless_zero(page))) on a tail page. ??

-aneesh
	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
