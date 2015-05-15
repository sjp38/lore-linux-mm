Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 393E56B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:14:54 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so57718994wic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:14:53 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id g7si2171886wjy.213.2015.05.15.04.14.52
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 04:14:52 -0700 (PDT)
Date: Fri, 15 May 2015 14:14:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 02/28] rmap: add argument to charge compound page
Message-ID: <20150515111438.GB6250@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-3-git-send-email-kirill.shutemov@linux.intel.com>
 <5554C854.6020900@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5554C854.6020900@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 14, 2015 at 06:07:48PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >We're going to allow mapping of individual 4k pages of THP compound
> >page. It means we cannot rely on PageTransHuge() check to decide if
> >map/unmap small page or THP.
> >
> >The patch adds new argument to rmap functions to indicate whether we want
> >to operate on whole compound page or only the small page.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> But I wonder about one thing:
> 
> >-void page_remove_rmap(struct page *page)
> >+void page_remove_rmap(struct page *page, bool compound)
> >  {
> >+	int nr = compound ? hpage_nr_pages(page) : 1;
> >+
> >  	if (!PageAnon(page)) {
> >+		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
> >  		page_remove_file_rmap(page);
> >  		return;
> >  	}
> 
> The function continues by:
> 
>         /* page still mapped by someone else? */
>         if (!atomic_add_negative(-1, &page->_mapcount))
>                 return;
> 
>         /* Hugepages are not counted in NR_ANON_PAGES for now. */
>         if (unlikely(PageHuge(page)))
>                 return;
> 
> The handling of compound parameter for PageHuge() pages feels just weird.
> You use hpage_nr_pages() for them which tests PageTransHuge(). It doesn't
> break anything and the value of nr is effectively ignored anyway, but
> still...
> 
> So I wonder, if all callers of page_remove_rmap() for PageHuge() pages are
> the two in mm/hugetlb.c, why not just create a special case function?

It's fair question. I think we shouldn't do this. It makes hugetlb even
more special place, alien to rest of mm.

And this is out of scope of the patchset in question.

> Or are some callers elsewhere, not aware whether they are calling this
> on a PageHuge()? So compound might be even false for those?

Caller sets compound==true based on whether the page is mapped with
PMD/PUD or not. It's nothing to do with what page type it is.

> If that's all possible and legal, then maybe explain it in a comment to
> reduce confusion of further readers. And move the 'nr' assignment to a
> place where we are sure it's not a PageHuge(), i.e. right above the
> place the value is used, perhaps?

I'll rework code a bit in v6.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
