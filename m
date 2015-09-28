Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB906B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 07:03:11 -0400 (EDT)
Received: by laer8 with SMTP id r8so26485425lae.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 04:03:10 -0700 (PDT)
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com. [209.85.215.53])
        by mx.google.com with ESMTPS id b9si7998966laf.10.2015.09.28.04.03.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 04:03:09 -0700 (PDT)
Received: by lahh2 with SMTP id h2so155523264lah.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 04:03:08 -0700 (PDT)
Date: Mon, 28 Sep 2015 14:03:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/16] page-flags: introduce page flags policies wrt
 compound pages
Message-ID: <20150928110305.GA4721@node>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1443106264-78075-4-git-send-email-kirill.shutemov@linux.intel.com>
 <56053E1D.7050001@yandex-team.ru>
 <20150925191307.GA25711@node.dhcp.inet.fi>
 <5609102B.5020704@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5609102B.5020704@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 28, 2015 at 01:02:19PM +0300, Konstantin Khlebnikov wrote:
> On 25.09.2015 22:13, Kirill A. Shutemov wrote:
> >On Fri, Sep 25, 2015 at 03:29:17PM +0300, Konstantin Khlebnikov wrote:
> >>On 24.09.2015 17:50, Kirill A. Shutemov wrote:
> >>>This patch adds a third argument to macros which create function
> >>>definitions for page flags.  This argument defines how page-flags helpers
> >>>behave on compound functions.
> >>>
> >>>For now we define four policies:
> >>>
> >>>- PF_ANY: the helper function operates on the page it gets, regardless
> >>>   if it's non-compound, head or tail.
> >>>
> >>>- PF_HEAD: the helper function operates on the head page of the compound
> >>>   page if it gets tail page.
> >>>
> >>>- PF_NO_TAIL: only head and non-compond pages are acceptable for this
> >>>   helper function.
> >>>
> >>>- PF_NO_COMPOUND: only non-compound pages are acceptable for this helper
> >>>   function.
> >>>
> >>>For now we use policy PF_ANY for all helpers, which matches current
> >>>behaviour.
> >>>
> >>>We do not enforce the policy for TESTPAGEFLAG, because we have flags
> >>>checked for random pages all over the kernel.  Noticeable exception to
> >>>this is PageTransHuge() which triggers VM_BUG_ON() for tail page.
> >>>
> >>>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >>>---
> >>>  include/linux/page-flags.h | 154 ++++++++++++++++++++++++++-------------------
> >>>  1 file changed, 90 insertions(+), 64 deletions(-)
> >>>
> >>>diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >>>index 713d3f2c2468..1b3babe5ff69 100644
> >>>--- a/include/linux/page-flags.h
> >>>+++ b/include/linux/page-flags.h
> >>>@@ -154,49 +154,68 @@ static inline int PageCompound(struct page *page)
> >>>  	return test_bit(PG_head, &page->flags) || PageTail(page);
> >>>  }
> >>>
> >>>+/* Page flags policies wrt compound pages */
> >>>+#define PF_ANY(page, enforce)	page
> >>>+#define PF_HEAD(page, enforce)	compound_head(page)
> >>>+#define PF_NO_TAIL(page, enforce) ({					\
> >>>+		if (enforce)						\
> >>>+			VM_BUG_ON_PAGE(PageTail(page), page);		\
> >>>+		else							\
> >>>+			page = compound_head(page);			\
> >>>+		page;})
> >>>+#define PF_NO_COMPOUND(page, enforce) ({					\
> >>>+		if (enforce)						\
> >>>+			VM_BUG_ON_PAGE(PageCompound(page), page);	\
> >>
> >>Linux next-20150925 crashes here (at least in lkvm)
> >>if CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
> >
> >Hm. I don't see the crash in qemu. Could you share your config?
> 
> see in attachment

Still don't see it. Have you tried patch from my previous mail?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
