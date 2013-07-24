Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2CB866B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 02:27:13 -0400 (EDT)
Date: Wed, 24 Jul 2013 02:26:50 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374647210-ac6q11s5-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <51ef6fd0.1019310a.5683.345bSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <51ef6fd0.1019310a.5683.345bSMTPIN_ADDED_BROKEN@mx.google.com>
Subject: Re: [PATCH 7/8] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 24, 2013 at 02:10:07PM +0800, Wanpeng Li wrote:
...
> >diff --git v3.11-rc1.orig/mm/page_isolation.c v3.11-rc1/mm/page_isolation.c
> >index 383bdbb..cf48ef6 100644
> >--- v3.11-rc1.orig/mm/page_isolation.c
> >+++ v3.11-rc1/mm/page_isolation.c
> >@@ -6,6 +6,7 @@
> > #include <linux/page-isolation.h>
> > #include <linux/pageblock-flags.h>
> > #include <linux/memory.h>
> >+#include <linux/hugetlb.h>
> > #include "internal.h"
> >
> > int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
> >@@ -252,6 +253,10 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
> > {
> > 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> >
> >+	if (PageHuge(page))
> >+		return alloc_huge_page_node(page_hstate(compound_head(page)),
> >+					    numa_node_id());
> >+
> 
> Why specify current node? Maybe current node is under remove.

Yes. One difficulty is that this function doesn't have vma and we can't
rely on mempolicy for node choice. I think that simply choosing the next
node by incrementing node id can be a work around, though it's not the
best solution.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
