Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE816B0075
	for <linux-mm@kvack.org>; Mon, 18 May 2015 23:55:37 -0400 (EDT)
Received: by wghq2 with SMTP id q2so2724695wgh.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 20:55:37 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id eq3si2026818wjd.142.2015.05.18.20.55.35
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 20:55:35 -0700 (PDT)
Date: Tue, 19 May 2015 06:55:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 19/28] mm: store mapcount for compound page separately
Message-ID: <20150519035515.GA5795@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-20-git-send-email-kirill.shutemov@linux.intel.com>
 <5559F7F6.7060801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5559F7F6.7060801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 18, 2015 at 04:32:22PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >We're going to allow mapping of individual 4k pages of THP compound and
> >we need a cheap way to find out how many time the compound page is
> >mapped with PMD -- compound_mapcount() does this.
> >
> >We use the same approach as with compound page destructor and compound
> >order: use space in first tail page, ->mapping this time.
> >
> >page_mapcount() counts both: PTE and PMD mappings of the page.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> >---
> >  include/linux/mm.h       | 25 ++++++++++++--
> >  include/linux/mm_types.h |  1 +
> >  include/linux/rmap.h     |  4 +--
> >  mm/debug.c               |  5 ++-
> >  mm/huge_memory.c         |  2 +-
> >  mm/hugetlb.c             |  4 +--
> >  mm/memory.c              |  2 +-
> >  mm/migrate.c             |  2 +-
> >  mm/page_alloc.c          | 14 ++++++--
> >  mm/rmap.c                | 87 +++++++++++++++++++++++++++++++++++++-----------
> >  10 files changed, 114 insertions(+), 32 deletions(-)
> >
> >diff --git a/include/linux/mm.h b/include/linux/mm.h
> >index dad667d99304..33cb3aa647a6 100644
> >--- a/include/linux/mm.h
> >+++ b/include/linux/mm.h
> >@@ -393,6 +393,19 @@ static inline int is_vmalloc_or_module_addr(const void *x)
> >
> >  extern void kvfree(const void *addr);
> >
> >+static inline atomic_t *compound_mapcount_ptr(struct page *page)
> >+{
> >+	return &page[1].compound_mapcount;
> >+}
> >+
> >+static inline int compound_mapcount(struct page *page)
> >+{
> >+	if (!PageCompound(page))
> >+		return 0;
> >+	page = compound_head(page);
> >+	return atomic_read(compound_mapcount_ptr(page)) + 1;
> >+}
> >+
> >  /*
> >   * The atomic page->_mapcount, starts from -1: so that transitions
> >   * both from it and to it can be tracked, using atomic_inc_and_test
> 
> What's not shown here is the implementation of page_mapcount_reset() that's
> unchanged... is that correct from all callers?

Looks like page_mapcount_reset() is mostly use to deal with PageBuddy()
and such. We don't have this kind of tricks for compound_mapcount.

> >@@ -405,8 +418,16 @@ static inline void page_mapcount_reset(struct page *page)
> >
> >  static inline int page_mapcount(struct page *page)
> >  {
> >+	int ret;
> >  	VM_BUG_ON_PAGE(PageSlab(page), page);
> >-	return atomic_read(&page->_mapcount) + 1;
> >+	ret = atomic_read(&page->_mapcount) + 1;
> >+	/*
> >+	 * Positive compound_mapcount() offsets ->_mapcount in every page by
> >+	 * one. Let's substract it here.
> >+	 */
> 
> This could use some more detailed explanation, or at least pointers to the
> relevant rmap functions. Also in commit message.

Okay. Will do.

> 
> >+	if (compound_mapcount(page))
> >+	       ret += compound_mapcount(page) - 1;
> 
> This looks like it could uselessly duplicate-inline the code for
> compound_mapcount(). It has atomics and smp_rmb() so I'm not sure if the
> compiler can just "squash it".

Good point. I'll rework this.
>
> On the other hand, a simple atomic read that was page_mapcount() has turned
> into multiple atomic reads and flag checks. What about the stability of the
> whole result? Are all callers ok? (maybe a later page deals with it).

Urghh.. I'll look into this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
