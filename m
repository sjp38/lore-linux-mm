Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id F16456B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 18:57:46 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so47242875pdb.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 15:57:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id de2si6390341pad.182.2015.02.17.15.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 15:57:46 -0800 (PST)
Date: Tue, 17 Feb 2015 15:57:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, hugetlb: set PageLRU for in-use/active hugepages
Message-Id: <20150217155744.04db5a98d5a1820240eb2317@linux-foundation.org>
In-Reply-To: <20150217093153.GA12875@hori1.linux.bs1.fc.nec.co.jp>
References: <1424143299-7557-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20150217093153.GA12875@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 17 Feb 2015 09:32:08 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently we are not safe from concurrent calls of isolate_huge_page(),
> which can make the victim hugepage in invalid state and results in BUG_ON().
> 
> The root problem of this is that we don't have any information on struct page
> (so easily accessible) about the hugepage's activeness. Note that hugepages'
> activeness means just being linked to hstate->hugepage_activelist, which is
> not the same as normal pages' activeness represented by PageActive flag.
> 
> Normal pages are isolated by isolate_lru_page() which prechecks PageLRU before
> isolation, so let's do similarly for hugetlb. PageLRU is unused on hugetlb now,
> so the change is mostly just inserting Set/ClearPageLRU (no conflict with
> current usage.) And the other changes are justified like below:
> - __put_compound_page() calls __page_cache_release() to do some LRU works,
>   but this is obviously for thps and assumes that hugetlb has always !PageLRU.
>   This assumption is not true any more, so this patch simply adds if (!PageHuge)
>   to avoid calling __page_cache_release() for hugetlb.
> - soft_offline_huge_page() now just calls list_move(), but generally callers
>   of page migration should use the common routine in isolation, so let's
>   replace the list_move() with isolate_huge_page() rather than inserting
>   ClearPageLRU.
> 
> Set/ClearPageLRU should be called within hugetlb_lock, but hugetlb_cow() and
> hugetlb_no_page() don't do this. This is justified because in these function
> SetPageLRU is called right after the hugepage is allocated and no other thread
> tries to isolate it.

Whoa.

So if I'm understanding this correctly, hugepages never have PG_lru set
and so you are overloading that bit on hugepages to indicate that the
page is present on hstate->hugepage_activelist?

This is somewhat of a big deal and the patch doesn't make it very clear
at all.  We should

- document PG_lru, for both of its identities

- consider adding a new PG_hugepage_active(?) flag which has the same
  value as PG_lru (see how PG_savepinned was done).

- create suitable helper functions for the new PG_lru meaning. 
  Simply calling PageLRU/SetPageLRU for pages which *aren't on the LRU*
  is lazy and misleading.  Create a name for the new concept
  (hugepage_active?) and document it and use it consistently.


> @@ -75,7 +76,8 @@ static void __put_compound_page(struct page *page)
>  {
>  	compound_page_dtor *dtor;
>  
> -	__page_cache_release(page);
> +	if (!PageHuge(page))
> +		__page_cache_release(page);
>  	dtor = get_compound_page_dtor(page);
>  	(*dtor)(page);

And this needs a good comment - there's no way that a reader can work
out why this code is here unless he goes dumpster diving in the git
history.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
