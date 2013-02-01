Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id CF9866B000A
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 10:53:03 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] HWPOISON: fix wrong num_poisoned_pages in handling memory error on thp
Date: Fri,  1 Feb 2013 10:52:53 -0500
Message-Id: <1359733973-5686-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1359675345-23262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 31, 2013 at 06:35:45PM -0500, Naoya Horiguchi wrote:
> On Thu, Jan 31, 2013 at 11:34:16AM -0800, Andrew Morton wrote:
> > On Thu, 31 Jan 2013 10:25:58 -0500
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > num_poisoned_pages counts up the number of pages isolated by memory errors.
> > > But for thp, only one subpage is isolated because memory error handler
> > > splits it, so it's wrong to add (1 << compound_trans_order).
> > > 
> > > ...
> > >
> > > --- mmotm-2013-01-23-17-04.orig/mm/memory-failure.c
> > > +++ mmotm-2013-01-23-17-04/mm/memory-failure.c
> > > @@ -1039,7 +1039,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> > >  		return 0;
> > >  	}
> > >  
> > > -	nr_pages = 1 << compound_trans_order(hpage);
> > > +	/*
> > > +	 * If a thp is hit by a memory failure, it's supposed to be split.
> > > +	 * So we should add only one to num_poisoned_pages for that case.
> > > +	 */
> > > +	if (PageHuge(p))
> > 
> > /*
> >  * PageHuge() only returns true for hugetlbfs pages, but not for normal or
> >  * transparent huge pages.  See the PageTransHuge() documentation for more
> >  * details.
> >  */
> > int PageHuge(struct page *page)
> > {
> 
> Do you mean that my comment refers to thp but this if-condition uses
> PageHuge so it's confusing, right?
> And yes, that's right, so I want to change this comment like this:
> 
>    /*
>     * Currently errors on hugetlbfs pages are contained in hugepage
>     * unit, so nr_pages should be 1 << compound_order. OTOH when
>     * errors are on transparent hugepages, they are supposed to be
>     * split and error containment is done in normal page unit.
>     * So nr_pages should be one in this case.
>     */
> 
> > 
> > > +		nr_pages = 1 << compound_trans_order(hpage);
> 
> I should've used compound_order because this code is run only for
> hugetlbfs pages.

Hi Andrew,

Here is a revised patch, could you replace the previous version in your
tree with this one?

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 01 Feb 2013 10:45:18 -0500
Subject: [PATCH v2] HWPOISON: fix wrong num_poisoned_pages in handling memory
 error on thp

num_poisoned_pages counts up the number of pages isolated by memory errors.
But for thp, only one subpage is isolated because memory error handler
splits it, so it's wrong to add (1 << compound_trans_order).

ChangeLog v2:
 - commented more.
 - used compound_order instead of compound_trans_order.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9cab165..9b1e5e7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1039,7 +1039,17 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
-	nr_pages = 1 << compound_trans_order(hpage);
+	/*
+	 * Currently errors on hugetlbfs pages are contained in hugepage
+	 * unit, so nr_pages should be 1 << compound_order. OTOH when
+	 * errors are on transparent hugepages, they are supposed to be
+	 * split and error containment is done in normal page unit.
+	 * So nr_pages should be one in this case.
+	 */
+	if (PageHuge(p))
+		nr_pages = 1 << compound_order(hpage);
+	else /* normal page or thp */
+		nr_pages = 1;
 	atomic_long_add(nr_pages, &num_poisoned_pages);
 
 	/*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
