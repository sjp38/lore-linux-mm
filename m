Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 691336B006E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 07:35:41 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so73711636wic.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:35:40 -0700 (PDT)
Received: from johanna2.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id k1si19284175wif.77.2015.06.22.04.35.39
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 04:35:39 -0700 (PDT)
Date: Mon, 22 Jun 2015 14:35:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 33/36] migrate_pages: try to split pages on qeueuing
Message-ID: <20150622113525.GE7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-34-git-send-email-kirill.shutemov@linux.intel.com>
 <55795477.90808@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55795477.90808@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 11, 2015 at 11:27:19AM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> >We are not able to migrate THPs. It means it's not enough to split only
> >PMD on migration -- we need to split compound page under it too.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> >  mm/mempolicy.c | 37 +++++++++++++++++++++++++++++++++----
> >  1 file changed, 33 insertions(+), 4 deletions(-)
> >
> >diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> >index 528f6c467cf1..0b1499c2f890 100644
> >--- a/mm/mempolicy.c
> >+++ b/mm/mempolicy.c
> >@@ -489,14 +489,31 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
> >  	struct page *page;
> >  	struct queue_pages *qp = walk->private;
> >  	unsigned long flags = qp->flags;
> >-	int nid;
> >+	int nid, ret;
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> >
> >-	split_huge_pmd(vma, pmd, addr);
> >-	if (pmd_trans_unstable(pmd))
> >-		return 0;
> >+	if (pmd_trans_huge(*pmd)) {
> >+		ptl = pmd_lock(walk->mm, pmd);
> >+		if (pmd_trans_huge(*pmd)) {
> >+			page = pmd_page(*pmd);
> >+			if (is_huge_zero_page(page)) {
> >+				spin_unlock(ptl);
> >+				split_huge_pmd(vma, pmd, addr);
> >+			} else {
> >+				get_page(page);
> >+				spin_unlock(ptl);
> >+				lock_page(page);
> >+				ret = split_huge_page(page);
> >+				unlock_page(page);
> >+				put_page(page);
> >+				if (ret)
> >+					return 0;
> >+			}
> >+		}
> >+	}
> >
> >+retry:
> >  	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> >  	for (; addr != end; pte++, addr += PAGE_SIZE) {
> >  		if (!pte_present(*pte))
> >@@ -513,6 +530,18 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
> >  		nid = page_to_nid(page);
> >  		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
> >  			continue;
> >+		if (PageTail(page) && PageAnon(page)) {
> 
> Hm, can it really happen that we stumble upon THP tail page here, without
> first stumbling upon it in the previous hunk above? If so, when?

The first hunk catch PMD-mapped THP and here we deal with PTE-mapped.
The scenario: fault in a THP, split PMD (not page) e.g. with mprotect()
and then try to migrate.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
