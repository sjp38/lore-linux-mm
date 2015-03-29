Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9D26B6B0078
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 11:56:34 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so149809364pdn.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 08:56:34 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id fe5si11273830pdb.39.2015.03.29.08.56.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Mar 2015 08:56:33 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 01:56:28 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 040D72CE8055
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 02:56:22 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2TFuDpv46923984
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 02:56:21 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2TFtlM8031045
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 02:55:48 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound page
In-Reply-To: <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sun, 29 Mar 2015 21:25:29 +0530
Message-ID: <87ego7n6ha.fsf@linux.vnet.ibm.com>
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
> Memory cgroup is not yet ready for new refcouting. Let's disable it on
> Kconfig level.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
.....
.....

>  static inline int page_mapped(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >= 0;
> +	if (compound_mapcount(page))
> +		return 1;
> +	for (i = 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >= 0)
> +			return 1;
> +	}

do we need to loop with head page here ? ie,

page = compound_page(page);

> +	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
