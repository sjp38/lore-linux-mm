Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 1543F6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 17:42:55 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, soft offline: split thp at the beginning of soft_offline_page()
Date: Tue, 27 Nov 2012 17:42:43 -0500
Message-Id: <1354056163-30558-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121127135458.4b7369f7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 27, 2012 at 01:54:58PM -0800, Andrew Morton wrote:
> On Tue, 27 Nov 2012 16:05:31 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we try to soft-offline a thp tail page, put_page() is called on the
> > tail page unthinkingly and VM_BUG_ON is triggered in put_compound_page().
> > This patch splits thp before going into the main body of soft-offlining.
> > 
> > The interface of soft-offlining is open for userspace, so this bug can
> > lead to DoS attack and should be fixed immedately.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: stable@vger.kernel.org
> > ---
> >  mm/memory-failure.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git v3.7-rc7.orig/mm/memory-failure.c v3.7-rc7/mm/memory-failure.c
> > index 8fe3640..e48e235 100644
> > --- v3.7-rc7.orig/mm/memory-failure.c
> > +++ v3.7-rc7/mm/memory-failure.c
> > @@ -1548,9 +1548,17 @@ int soft_offline_page(struct page *page, int flags)
> >  {
> >  	int ret;
> >  	unsigned long pfn = page_to_pfn(page);
> > +	struct page *hpage = compound_trans_head(page);
> >  
> >  	if (PageHuge(page))
> >  		return soft_offline_huge_page(page, flags);
> > +	if (PageTransHuge(hpage)) {
> > +		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
> > +			pr_info("soft offline: %#lx: failed to split THP\n",
> > +				pfn);
> > +			return -EBUSY;
> > +		}
> > +	}
> 
> We can use PageTransCompound() here, as we know it isn't a hugetlbfs
> page.  This will then permit the PageAnon() test to be omitted, methinks?

Using PageTransCompound() is OK for me. But without this PageAnon() test,
we can trigger BUG_ON(!PageAnon) inside split_huge_page() when soft
offlining is kicked on non-huge compound pages.

The point about telling thp from hugetlbfs pages and non-huge compound
pages was discussed last month over 7a71932d5676b7410 ("kpageflags: fix
wrong KPF_THP on non-huge compound pages"), where we used a bit tricky
workaround of using PageTransCompound(page) && PageLRU(compound_trans_head(page)).

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
