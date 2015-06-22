Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1406E6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:03:07 -0400 (EDT)
Received: by wguu7 with SMTP id u7so64589575wgu.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 03:03:06 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id li12si18909045wic.91.2015.06.22.03.03.04
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 03:03:05 -0700 (PDT)
Date: Mon, 22 Jun 2015 13:02:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 01/36] mm, proc: adjust PSS calculation
Message-ID: <20150622100245.GA7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-2-git-send-email-kirill.shutemov@linux.intel.com>
 <5576DC1D.6010800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5576DC1D.6010800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 09, 2015 at 02:29:17PM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> >With new refcounting all subpages of the compound page are not nessessary
> >have the same mapcount. We need to take into account mapcount of every
> >sub-page.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> >Acked-by: Jerome Marchand <jmarchan@redhat.com>
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >---
> >  fs/proc/task_mmu.c | 48 +++++++++++++++++++++++++++++++-----------------
> >  1 file changed, 31 insertions(+), 17 deletions(-)
> >
> >diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >index 58be92e11939..f9b285761bc0 100644
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
> >+	int i, nr = compound ? HPAGE_PMD_NR : 1;
> >+	unsigned long size = nr * PAGE_SIZE;
> >
> >  	if (PageAnon(page))
> >  		mss->anonymous += size;
> >@@ -460,23 +461,36 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
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
> >+	/*
> >+	 * page_count(page) == 1 guarantees the page is mapped exactly once.
> >+	 * If any subpage of the compound page mapped with PTE it would elevate
> >+	 * page_count().
> >+	 */
> >+	if (page_count(page) == 1) {
> >  		if (dirty || PageDirty(page))
> >  			mss->private_dirty += size;
> >  		else
> >  			mss->private_clean += size;
> >-		mss->pss += (u64)size << PSS_SHIFT;
> 
> Deleting the line above was a mistake, right?

Yep :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
