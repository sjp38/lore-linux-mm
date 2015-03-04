Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id EDE646B006C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 08:26:31 -0500 (EST)
Received: by wevm14 with SMTP id m14so46329716wev.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 05:26:31 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id co4si29080816wib.116.2015.03.04.05.26.29
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 05:26:30 -0800 (PST)
Date: Wed, 4 Mar 2015 15:26:17 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 04/24] rmap: add argument to charge compound page
Message-ID: <20150304132617.GB16452@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com>
 <54EB538B.7040308@suse.cz>
 <20150304115244.GA16452@node.dhcp.inet.fi>
 <54F6F60F.4070705@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F6F60F.4070705@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 04, 2015 at 01:09:51PM +0100, Vlastimil Babka wrote:
> On 03/04/2015 12:52 PM, Kirill A. Shutemov wrote:
> >On Mon, Feb 23, 2015 at 05:21:31PM +0100, Vlastimil Babka wrote:
> >>On 02/12/2015 05:18 PM, Kirill A. Shutemov wrote:
> >>>@@ -1052,21 +1052,24 @@ void page_add_anon_rmap(struct page *page,
> >>>   * Everybody else should continue to use page_add_anon_rmap above.
> >>>   */
> >>>  void do_page_add_anon_rmap(struct page *page,
> >>>-	struct vm_area_struct *vma, unsigned long address, int exclusive)
> >>>+	struct vm_area_struct *vma, unsigned long address, int flags)
> >>>  {
> >>>  	int first = atomic_inc_and_test(&page->_mapcount);
> >>>  	if (first) {
> >>>+		bool compound = flags & RMAP_COMPOUND;
> >>>+		int nr = compound ? hpage_nr_pages(page) : 1;
> >>
> >>hpage_nr_pages(page) is:
> >>
> >>static inline int hpage_nr_pages(struct page *page)
> >>{
> >>         if (unlikely(PageTransHuge(page)))
> >>                 return HPAGE_PMD_NR;
> >>         return 1;
> >>}
> >>
> >>and later...
> >>
> >>>  		/*
> >>>  		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
> >>>  		 * these counters are not modified in interrupt context, and
> >>>  		 * pte lock(a spinlock) is held, which implies preemption
> >>>  		 * disabled.
> >>>  		 */
> >>>-		if (PageTransHuge(page))
> >>>+		if (compound) {
> >>>+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> >>
> >>this means that we could assume that
> >>(compound == true) => (PageTransHuge(page) == true)
> >>
> >>and simplify above to:
> >>
> >>int nr = compound ? HPAGE_PMD_NR : 1;
> >>
> >>Right?
> >
> >No. HPAGE_PMD_NR is defined based on HPAGE_PMD_SHIFT which is BUILD_BUG()
> >without CONFIG_TRANSPARENT_HUGEPAGE. We will get compiler error without
> >the helper.
> 
> Oh, OK. But that doesn't mean there couldn't be another helper that would
> work in this case, or even open-coded #ifdefs in these functions. Apparently
> "compound" has to be always false for !CONFIG_TRANSPARENT_HUGEPAGE, as in
> that case PageTransHuge is defined as 0 and the VM_BUG_ON would trigger if
> compound was true. So without such ifdefs or wrappers, you are also adding
> dead code and pointless tests for !CONFIG_TRANSPARENT_HUGEPAGE?

Yeah, this definitely can be improved. I prefer to do it as follow up.
I want to get stable what I have now.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
