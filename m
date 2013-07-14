From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [v5][PATCH 4/6] mm: vmscan: break out mapping "freepage" code
Date: Mon, 15 Jul 2013 07:49:36 +0800
Message-ID: <16424.157904885$1373845793@news.gmane.org>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200207.7402753F@viggo.jf.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UyW2z-000617-PQ
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Jul 2013 01:49:46 +0200
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C2ECD6B004D
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:49:43 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 05:14:08 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 85B4C394004D
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:19:34 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ENoIHu32964820
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:20:18 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ENnbfI009438
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:49:37 +1000
Content-Disposition: inline
In-Reply-To: <20130603200207.7402753F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org, Dave Hansen <dave@sr71.net>

On Mon, Jun 03, 2013 at 01:02:07PM -0700, Dave Hansen wrote:
>
>From: Dave Hansen <dave.hansen@linux.intel.com>
>
>__remove_mapping() only deals with pages with mappings, meaning
>page cache and swap cache.
>
>At this point, the page has been removed from the mapping's radix
>tree, and we need to ensure that any fs-specific (or swap-
>specific) resources are freed up.
>
>We will be using this function from a second location in a
>following patch.
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>Acked-by: Mel Gorman <mgorman@suse.de>
>Reviewed-by: Minchan Kim <minchan@kernel.org>
>---

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>
> linux.git-davehans/mm/vmscan.c |   27 ++++++++++++++++++---------
> 1 file changed, 18 insertions(+), 9 deletions(-)
>
>diff -puN mm/vmscan.c~free_mapping_page mm/vmscan.c
>--- linux.git/mm/vmscan.c~free_mapping_page	2013-06-03 12:41:31.155740124 -0700
>+++ linux.git-davehans/mm/vmscan.c	2013-06-03 12:41:31.159740301 -0700
>@@ -496,6 +496,23 @@ static int __remove_mapping(struct addre
> 	return 1;
> }
>
>+/*
>+ * Release any resources the mapping had tied up in the page.
>+ */
>+static void mapping_release_page(struct address_space *mapping,
>+				 struct page *page)
>+{
>+	if (PageSwapCache(page)) {
>+		swapcache_free_page_entry(page);
>+	} else {
>+		void (*freepage)(struct page *);
>+		freepage = mapping->a_ops->freepage;
>+		mem_cgroup_uncharge_cache_page(page);
>+		if (freepage != NULL)
>+			freepage(page);
>+	}
>+}
>+
> static int lock_remove_mapping(struct address_space *mapping, struct page *page)
> {
> 	int ret;
>@@ -509,15 +526,7 @@ static int lock_remove_mapping(struct ad
> 	if (!ret)
> 		return 0;
>
>-	if (PageSwapCache(page)) {
>-		swapcache_free_page_entry(page);
>-	} else {
>-		void (*freepage)(struct page *);
>-		freepage = mapping->a_ops->freepage;
>-		mem_cgroup_uncharge_cache_page(page);
>-		if (freepage != NULL)
>-			freepage(page);
>-	}
>+	mapping_release_page(mapping, page);
> 	return ret;
> }
>
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
