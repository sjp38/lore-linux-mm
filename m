Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EF8226B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:14:07 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so4173011pab.7
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:14:07 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id cb9si6468034pdb.114.2014.11.20.22.13.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 22:14:06 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 16:13:18 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1CA922BB006A
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:13:11 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAL6F4h722020104
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:15:04 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAL6DAWE016127
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:13:10 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
In-Reply-To: <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com> <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 21 Nov 2014 11:42:51 +0530
Message-ID: <87h9xt6pzw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> We're going to allow mapping of individual 4k pages of THP compound and
> we need a cheap way to find out how many time the compound page is
> mapped with PMD -- compound_mapcount() does this.
>
> page_mapcount() counts both: PTE and PMD mappings of the page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h   | 17 +++++++++++++++--
>  include/linux/rmap.h |  4 ++--
>  mm/huge_memory.c     | 23 ++++++++++++++---------
>  mm/hugetlb.c         |  4 ++--
>  mm/memory.c          |  2 +-
>  mm/migrate.c         |  2 +-
>  mm/page_alloc.c      | 13 ++++++++++---
>  mm/rmap.c            | 50 +++++++++++++++++++++++++++++++++++++++++++-------
>  8 files changed, 88 insertions(+), 27 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1825c468f158..aef03acff228 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -435,6 +435,19 @@ static inline struct page *compound_head(struct page *page)
>  	return page;
>  }
>  
> +static inline atomic_t *compound_mapcount_ptr(struct page *page)
> +{
> +	return (atomic_t *)&page[1].mapping;
> +}
> +
> +static inline int compound_mapcount(struct page *page)
> +{
> +	if (!PageCompound(page))
> +		return 0;
> +	page = compound_head(page);
> +	return atomic_read(compound_mapcount_ptr(page)) + 1;
> +}


How about 

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6e0b286649f1..59c9cf3d8510 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -46,6 +46,11 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
+		/*
+		  * For THP we use this to track the compound
+		  * page mapcount.
+		  */
+		atomic_t _compound_mapcount;
 		struct address_space *mapping;	/* If low bit clear, points to
 						 * inode address_space, or NULL.
 						 * If page mapped as anonymous

and 

static inline atomic_t *compound_mapcount_ptr(struct page *page)
{
        return (atomic_t *)&page[1]._compound_mapcount;
}



-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
