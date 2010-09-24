Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D61526B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 02:49:41 -0400 (EDT)
Date: Fri, 24 Sep 2010 15:47:14 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 06/10] hugetlb: move refcounting in hugepage allocation
 inside hugetlb_lock
Message-ID: <20100924064714.GB26639@spritzera.linux.bs1.fc.nec.co.jp>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1283908781-13810-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1009231209450.32567@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009231209450.32567@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 23, 2010 at 12:12:55PM -0500, Christoph Lameter wrote:
> On Wed, 8 Sep 2010, Naoya Horiguchi wrote:
> 
> > Currently alloc_huge_page() raises page refcount outside hugetlb_lock.
> > but it causes race when dequeue_hwpoison_huge_page() runs concurrently
> > with alloc_huge_page().
> > To avoid it, this patch moves set_page_refcounted() in hugetlb_lock.
> 
> Reviewed-by: Christoph Lameter <cl@linux.com>
> 
> One wonders though how many other of these huge races are still there
> though.
> 
> "Normal" page migration is based on LRU isolation and therefore does not
> suffer from these problems on allocation since the page is not yet on the
> LRU. Also the LRU isolation is a known issue due to memory reclaim doing
> this.

Yes.
For normal page, allocation and reclaiming and migration are protected from
each other by LRU isolation.
For huge page, however, allocation and migration (reclaiming is not available)
are protected by reference count, and race between allocation and hwpoison
are avoided by hugetlb_lock.
I see that this seems complex and can cause unpredicted races.

> This protection is going away of one goes directly to a page
> without going through the LRU. That should create more races...

To unify these protection mechanism, we need that LRU list become available
for hugepage, but we must wait for the appearance of hugepage swapping
for this. Or implementing dummy LRU list until then? (Maybe it's more messy...)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
