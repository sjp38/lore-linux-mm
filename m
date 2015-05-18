Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 843286B00A6
	for <linux-mm@kvack.org>; Mon, 18 May 2015 08:14:17 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so76533347wic.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 05:14:16 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id m11si12363877wij.110.2015.05.18.05.14.15
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 05:14:15 -0700 (PDT)
Date: Mon, 18 May 2015 15:13:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 14/28] futex, thp: remove special case for THP in
 get_futex_key
Message-ID: <20150518121354.GA1948@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-15-git-send-email-kirill.shutemov@linux.intel.com>
 <5559D1D3.8080503@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5559D1D3.8080503@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 18, 2015 at 01:49:39PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >With new THP refcounting, we don't need tricks to stabilize huge page.
> >If we've got reference to tail page, it can't split under us.
> >
> >This patch effectively reverts a5b338f2b0b1.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> >---
> >  kernel/futex.c | 61 ++++++++++++----------------------------------------------
> >  1 file changed, 12 insertions(+), 49 deletions(-)
> >
> >diff --git a/kernel/futex.c b/kernel/futex.c
> >index f4d8a85641ed..cf0192e60ef9 100644
> >--- a/kernel/futex.c
> >+++ b/kernel/futex.c
> >@@ -399,7 +399,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
> >  {
> >  	unsigned long address = (unsigned long)uaddr;
> >  	struct mm_struct *mm = current->mm;
> >-	struct page *page, *page_head;
> >+	struct page *page;
> >  	int err, ro = 0;
> >
> >  	/*
> >@@ -442,46 +442,9 @@ again:
> >  	else
> >  		err = 0;
> >
> >-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >-	page_head = page;
> >-	if (unlikely(PageTail(page))) {
> >-		put_page(page);
> >-		/* serialize against __split_huge_page_splitting() */
> >-		local_irq_disable();
> >-		if (likely(__get_user_pages_fast(address, 1, !ro, &page) == 1)) {
> >-			page_head = compound_head(page);
> >-			/*
> >-			 * page_head is valid pointer but we must pin
> >-			 * it before taking the PG_lock and/or
> >-			 * PG_compound_lock. The moment we re-enable
> >-			 * irqs __split_huge_page_splitting() can
> >-			 * return and the head page can be freed from
> >-			 * under us. We can't take the PG_lock and/or
> >-			 * PG_compound_lock on a page that could be
> >-			 * freed from under us.
> >-			 */
> >-			if (page != page_head) {
> >-				get_page(page_head);
> >-				put_page(page);
> >-			}
> >-			local_irq_enable();
> >-		} else {
> >-			local_irq_enable();
> >-			goto again;
> >-		}
> >-	}
> >-#else
> >-	page_head = compound_head(page);
> >-	if (page != page_head) {
> >-		get_page(page_head);
> >-		put_page(page);
> >-	}
> 
> Hmm, any idea why this was there? Without THP, it was already sure that
> get/put_page() on tail page operates on the head page's _count, no?

I guess it's just to deal with the same page from this point forward.
Pin/unpin one page, but lock other could look strange.
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
