Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA9E6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:22:27 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so71847179wic.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 03:22:27 -0700 (PDT)
Received: from johanna3.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id iz2si1358216wic.101.2015.06.22.03.22.25
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 03:22:26 -0700 (PDT)
Date: Mon, 22 Jun 2015 13:22:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 26/36] mm: rework mapcount accounting to enable 4k
 mapping of THPs
Message-ID: <20150622102206.GB7934@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-27-git-send-email-kirill.shutemov@linux.intel.com>
 <55783FDA.3080700@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55783FDA.3080700@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 10, 2015 at 03:47:06PM +0200, Vlastimil Babka wrote:
> On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> >@@ -415,8 +428,17 @@ static inline void page_mapcount_reset(struct page *page)
> >
> >  static inline int page_mapcount(struct page *page)
> >  {
> >+	int ret;
> >  	VM_BUG_ON_PAGE(PageSlab(page), page);
> >-	return atomic_read(&page->_mapcount) + 1;
> >+
> >+	ret = atomic_read(&page->_mapcount) + 1;
> >+	if (PageCompound(page)) {
> >+		page = compound_head(page);
> >+		ret += compound_mapcount(page);
> 
> compound_mapcount() means another PageCompound() and compound_head(), which
> you just did. I've tried this to see the effect on a function that "calls"
> (inlines) page_mapcount() once:
> 
> -               ret += compound_mapcount(page);
> +               ret += atomic_read(compound_mapcount_ptr(page)) + 1;
> 
> bloat-o-meter on compaction.o:
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-59 (-59)
> function                                     old     new   delta
> isolate_migratepages_block                  1769    1710     -59

Okay, fair enough.

> >diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >index 74b7cece1dfa..a8d47c1edf6a 100644
> >--- a/include/linux/page-flags.h
> >+++ b/include/linux/page-flags.h
> >@@ -127,6 +127,9 @@ enum pageflags {
> >
> >  	/* SLOB */
> >  	PG_slob_free = PG_private,
> >+
> >+	/* THP. Stored in first tail page's flags */
> >+	PG_double_map = PG_private_2,
> 
> Well, not just THP. Any user of compound pages must make sure not to use
> PG_private_2 on the first tail page. At least where the page is going to be
> user-mapped. And same thing about fields that are in union with
> compound_mapcount. Should that be documented more prominently somewhere?

I would substitute "THP" for "Compound pages".

> I guess there's no such user so far, right?

I believe so.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
