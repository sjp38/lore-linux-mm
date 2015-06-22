Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 03D786B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 07:14:49 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so71737464wib.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:14:48 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id o19si34460568wjr.59.2015.06.22.04.14.46
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 04:14:47 -0700 (PDT)
Date: Mon, 22 Jun 2015 14:14:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 29/36] thp: implement split_huge_pmd()
Message-ID: <20150622111434.GC7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-30-git-send-email-kirill.shutemov@linux.intel.com>
 <557959BC.5000303@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <557959BC.5000303@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 11, 2015 at 11:49:48AM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> >Original split_huge_page() combined two operations: splitting PMDs into
> >tables of PTEs and splitting underlying compound page. This patch
> >implements split_huge_pmd() which split given PMD without splitting
> >other PMDs this page mapped with or underlying compound page.
> >
> >Without tail page refcounting, implementation of split_huge_pmd() is
> >pretty straight-forward.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> [...]
> 
> >+
> >+	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
> >+		/* Last compound_mapcount is gone. */
> >+		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> >+		if (PageDoubleMap(page)) {
> >+			/* No need in mapcount reference anymore */
> >+			ClearPageDoubleMap(page);
> >+			for (i = 0; i < HPAGE_PMD_NR; i++)
> >+				atomic_dec(&page[i]._mapcount);
> >+		}
> >+	} else if (!TestSetPageDoubleMap(page)) {
> >+		/*
> >+		 * The first PMD split for the compound page and we still
> >+		 * have other PMD mapping of the page: bump _mapcount in
> >+		 * every small page.
> >+		 * This reference will go away with last compound_mapcount.
> >+		 */
> >+		for (i = 0; i < HPAGE_PMD_NR; i++)
> >+			atomic_inc(&page[i]._mapcount);
> 
> The order of actions here means that between TestSetPageDoubleMap() and the
> atomic incs, anyone calling page_mapcount() on one of the pages not
> processed by the for loop yet, will see a value lower by 1 from what he
> should see. I wonder if that can cause any trouble somewhere, especially if
> there's only one other compound mapping and page_mapcount() will return 0
> instead of 1?

Good catch. Thanks.

What about this?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0f1f5731a893..cd0e6addb662 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2636,15 +2636,25 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
                        for (i = 0; i < HPAGE_PMD_NR; i++)
                                atomic_dec(&page[i]._mapcount);
                }
-       } else if (!TestSetPageDoubleMap(page)) {
+       } else if (!PageDoubleMap(page)) {
                /*
                 * The first PMD split for the compound page and we still
                 * have other PMD mapping of the page: bump _mapcount in
                 * every small page.
+                *
                 * This reference will go away with last compound_mapcount.
+                *
+                * Note, we need to increment mapcounts before setting
+                * PG_double_map to avoid false-negative page_mapped().
                 */
                for (i = 0; i < HPAGE_PMD_NR; i++)
                        atomic_inc(&page[i]._mapcount);
+
+               if (TestSetPageDoubleMap(page)) {
+                       /* Race with another  __split_huge_pmd() for the page */
+                       for (i = 0; i < HPAGE_PMD_NR; i++)
+                               atomic_dec(&page[i]._mapcount);
+               }
        }
 
        smp_wmb(); /* make pte visible before pmd */

> Conversely, when clearing PageDoubleMap() above (or in one of those rmap
> functions IIRC), one could see mapcount inflated by one. But I guess that's
> less dangerous.

I think it's safe.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
