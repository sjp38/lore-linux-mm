Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 557346B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 19:46:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 13 Sep 2013 05:06:24 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2DB90E0058
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 05:16:59 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8CNm7Sc29491200
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 05:18:10 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8CNk3od028257
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 05:16:03 +0530
Date: Fri, 13 Sep 2013 07:46:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hwpoison: move set_migratetype_isolate() outside
 get_any_page()
Message-ID: <20130912234601.GA21487@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378998704-d94o0a30-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378998704-d94o0a30-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 12, 2013 at 11:11:44AM -0400, Naoya Horiguchi wrote:
>Chen Gong pointed out that set/unset_migratetype_isolate() was done in
>different functions in mm/memory-failure.c, which makes the code less
>readable/maintenable. So this patch makes it done in soft_offline_page().
>
>With this patch, we get to hold lock_memory_hotplug() longer but it's not
>a problem because races between memory hotplug and soft offline are very rare.
>
>This patch is against next-20130910.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Reviewed-by: Chen, Gong <gong.chen@linux.intel.com>
>---
> mm/memory-failure.c | 36 +++++++++++++++++-------------------
> 1 file changed, 17 insertions(+), 19 deletions(-)
>
>diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>index 947ed54..702e1e1 100644
>--- a/mm/memory-failure.c
>+++ b/mm/memory-failure.c
>@@ -1421,19 +1421,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
> 		return 1;
>
> 	/*
>-	 * The lock_memory_hotplug prevents a race with memory hotplug.
>-	 * This is a big hammer, a better would be nicer.
>-	 */
>-	lock_memory_hotplug();
>-
>-	/*
>-	 * Isolate the page, so that it doesn't get reallocated if it
>-	 * was free. This flag should be kept set until the source page
>-	 * is freed and PG_hwpoison on it is set.
>-	 */
>-	if (get_pageblock_migratetype(p) != MIGRATE_ISOLATE)
>-		set_migratetype_isolate(p, true);
>-	/*
> 	 * When the target page is a free hugepage, just remove it
> 	 * from free hugepage list.
> 	 */
>@@ -1453,7 +1440,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
> 		/* Not a free page */
> 		ret = 1;
> 	}
>-	unlock_memory_hotplug();
> 	return ret;
> }
>
>@@ -1652,15 +1638,28 @@ int soft_offline_page(struct page *page, int flags)
> 		}
> 	}
>
>+	/*
>+	 * The lock_memory_hotplug prevents a race with memory hotplug.
>+	 * This is a big hammer, a better would be nicer.
>+	 */
>+	lock_memory_hotplug();
>+
>+	/*
>+	 * Isolate the page, so that it doesn't get reallocated if it
>+	 * was free. This flag should be kept set until the source page
>+	 * is freed and PG_hwpoison on it is set.
>+	 */
>+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>+		set_migratetype_isolate(page, true);
>+
> 	ret = get_any_page(page, pfn, flags);
>-	if (ret < 0)
>-		goto unset;
>-	if (ret) { /* for in-use pages */
>+	unlock_memory_hotplug();
>+	if (ret > 0) { /* for in-use pages */
> 		if (PageHuge(page))
> 			ret = soft_offline_huge_page(page, flags);
> 		else
> 			ret = __soft_offline_page(page, flags);
>-	} else { /* for free pages */
>+	} else if (ret == 0) { /* for free pages */
> 		if (PageHuge(page)) {
> 			set_page_hwpoison_huge_page(hpage);
> 			dequeue_hwpoisoned_huge_page(hpage);
>@@ -1671,7 +1670,6 @@ int soft_offline_page(struct page *page, int flags)
> 			atomic_long_inc(&num_poisoned_pages);
> 		}
> 	}
>-unset:
> 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
> 	return ret;
> }
>-- 
>1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
