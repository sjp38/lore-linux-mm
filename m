Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B660D6B004A
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 13:12:59 -0400 (EDT)
Date: Thu, 23 Sep 2010 12:12:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 06/10] hugetlb: move refcounting in hugepage allocation
 inside hugetlb_lock
In-Reply-To: <1283908781-13810-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1009231209450.32567@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, Naoya Horiguchi wrote:

> Currently alloc_huge_page() raises page refcount outside hugetlb_lock.
> but it causes race when dequeue_hwpoison_huge_page() runs concurrently
> with alloc_huge_page().
> To avoid it, this patch moves set_page_refcounted() in hugetlb_lock.

Reviewed-by: Christoph Lameter <cl@linux.com>

One wonders though how many other of these huge races are still there
though.

"Normal" page migration is based on LRU isolation and therefore does not
suffer from these problems on allocation since the page is not yet on the
LRU. Also the LRU isolation is a known issue due to memory reclaim doing
this.  This protection is going away of one goes directly to a page
without going through the LRU. That should create more races...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
