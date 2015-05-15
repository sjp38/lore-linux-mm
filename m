Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7133B6B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 06:56:40 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so74987812wgb.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 03:56:39 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ey9si1133759wid.37.2015.05.15.03.56.38
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 03:56:39 -0700 (PDT)
Date: Fri, 15 May 2015 13:56:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 01/28] mm, proc: adjust PSS calculation
Message-ID: <20150515105621.GA6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
 <5554AD4D.9040000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5554AD4D.9040000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 14, 2015 at 04:12:29PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >With new refcounting all subpages of the compound page are not nessessary
> >have the same mapcount. We need to take into account mapcount of every
> >sub-page.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> (some nitpicks below)
> 
> >---
> >  fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
> >  1 file changed, 22 insertions(+), 21 deletions(-)
> >
> >diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >index 956b75d61809..95bc384ee3f7 100644
> >--- a/fs/proc/task_mmu.c
> >+++ b/fs/proc/task_mmu.c
> >@@ -449,9 +449,10 @@ struct mem_size_stats {
> >  };
> >
> >  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> >-		unsigned long size, bool young, bool dirty)
> >+		bool compound, bool young, bool dirty)
> >  {
> >-	int mapcount;
> >+	int i, nr = compound ? hpage_nr_pages(page) : 1;
> 
> Why not just HPAGE_PMD_NR instead of hpage_nr_pages(page)?

Okay, makes sense. Compiler is smart enough to optimize away HPAGE_PMD_NR
for THP=n. (HPAGE_PMD_NR is BUILD_BUG() for THP=n)

> We already came here through a pmd mapping. Even if the page stopped
> being a hugepage meanwhile (I'm not sure if any locking prevents that or
> not?),

We're under ptl here. PMD will not go away under us.

> it would be more accurate to continue assuming it's a hugepage,
> otherwise we account only the base page (formerly head) and skip the 511
> formerly tail pages?
> 
> Also, is there some shortcut way to tell us that we are the only one mapping
> the whole compound page, and nobody has any base pages, so we don't need to
> loop on each tail page? I guess not under the new design, right...

No, we don't have shortcut here.

> >+	unsigned long size = nr * PAGE_SIZE;
> >
> >  	if (PageAnon(page))
> >  		mss->anonymous += size;
> >@@ -460,23 +461,23 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
> >  	/* Accumulate the size in pages that have been accessed. */
> >  	if (young || PageReferenced(page))
> >  		mss->referenced += size;
> >-	mapcount = page_mapcount(page);
> >-	if (mapcount >= 2) {
> >-		u64 pss_delta;
> >
> >-		if (dirty || PageDirty(page))
> >-			mss->shared_dirty += size;
> >-		else
> >-			mss->shared_clean += size;
> >-		pss_delta = (u64)size << PSS_SHIFT;
> >-		do_div(pss_delta, mapcount);
> >-		mss->pss += pss_delta;
> >-	} else {
> >-		if (dirty || PageDirty(page))
> >-			mss->private_dirty += size;
> >-		else
> >-			mss->private_clean += size;
> >-		mss->pss += (u64)size << PSS_SHIFT;
> >+	for (i = 0; i < nr; i++) {
> >+		int mapcount = page_mapcount(page + i);
> >+
> >+		if (mapcount >= 2) {
> >+			if (dirty || PageDirty(page + i))
> >+				mss->shared_dirty += PAGE_SIZE;
> >+			else
> >+				mss->shared_clean += PAGE_SIZE;
> >+			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> >+		} else {
> >+			if (dirty || PageDirty(page + i))
> >+				mss->private_dirty += PAGE_SIZE;
> >+			else
> >+				mss->private_clean += PAGE_SIZE;
> >+			mss->pss += PAGE_SIZE << PSS_SHIFT;
> >+		}
> 
> That's 3 instances of "page + i", why not just use page and do a page++ in
> the for loop?

Okay.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
