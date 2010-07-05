Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A782E6B01AC
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 04:47:45 -0400 (EDT)
Date: Mon, 5 Jul 2010 17:46:29 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/7] hugetlb: add allocate function for hugepage migration
Message-ID: <20100705084629.GC29648@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100702090854.GD12221@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100702090854.GD12221@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 11:08:54AM +0200, Andi Kleen wrote:
> On Fri, Jul 02, 2010 at 02:47:22PM +0900, Naoya Horiguchi wrote:
> > We can't use existing hugepage allocation functions to allocate hugepage
> > for page migration, because page migration can happen asynchronously with
> > the running processes and page migration users should call the allocation
> > function with physical addresses (not virtual addresses) as arguments.
> 
> I looked through this patch and didn't see anything bad. Some more
> eyes familiar with hugepages would be good though.

Yes.

> Since there are now so many different allocation functions some
> comments on when they should be used may be useful too

OK. How about this?

+/*
+ * This allocation function is useful in the context where vma is irrelevant.
+ * E.g. soft-offlining uses this function because it only cares physical
+ * address of error page.
+ */
+struct page *alloc_huge_page_node(struct hstate *h, int nid)
+{

BTW, I don't like this function name very much.
Since the most significant difference of this function to alloc_huge_page()
is lack of vma argument, so I'm going to change the name to
alloc_huge_page_no_vma_node() in the next version if it is no problem.

Or, since the postfix like "_no_vma" is verbose, I think it might be
a good idea to rename present alloc_huge_page() to alloc_huge_page_vma().
Is this worthwhile?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
