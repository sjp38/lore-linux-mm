Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 238036B0044
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 07:42:50 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 18:12:27 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 51CBDE004C
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 18:12:24 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBBCgfEb31916080
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 18:12:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBBCgemO031209
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 23:42:41 +1100
Date: Tue, 11 Dec 2012 20:42:39 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 1/2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121211124238.GA9959@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <50C72493.3080009@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50C72493.3080009@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 11, 2012 at 08:18:27PM +0800, Xishi Qiu wrote:
>1) move poisoned page check at the beginning of the function.
>2) add page_lock to avoid unpoison clear the flag.
>
>Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>---
> mm/memory-failure.c |   43 ++++++++++++++++++++++---------------------
> 1 files changed, 22 insertions(+), 21 deletions(-)
>
>diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>index 8b20278..9b74983 100644
>--- a/mm/memory-failure.c
>+++ b/mm/memory-failure.c
>@@ -1419,18 +1419,17 @@ static int soft_offline_huge_page(struct page *page, int flags)
> 	unsigned long pfn = page_to_pfn(page);
> 	struct page *hpage = compound_head(page);
>
>+	if (PageHWPoison(hpage)) {
>+		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
>+		return -EBUSY;
>+	}
>+
> 	ret = get_any_page(page, pfn, flags);
> 	if (ret < 0)
> 		return ret;
> 	if (ret == 0)
> 		goto done;
>
>-	if (PageHWPoison(hpage)) {
>-		put_page(hpage);
>-		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
>-		return -EBUSY;
>-	}
>-
> 	/* Keep page count to indicate a given hugepage is isolated. */
> 	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
> 				MIGRATE_SYNC);
>@@ -1441,12 +1440,14 @@ static int soft_offline_huge_page(struct page *page, int flags)
> 		return ret;
> 	}
> done:
>-	if (!PageHWPoison(hpage))
>-		atomic_long_add(1 << compound_trans_order(hpage),
>-				&mce_bad_pages);
>+	/* keep elevated page count for bad page */
>+	lock_page(hpage);
>+	atomic_long_add(1 << compound_trans_order(hpage), &mce_bad_pages);
> 	set_page_hwpoison_huge_page(hpage);
>+	unlock_page(hpage);
>+
> 	dequeue_hwpoisoned_huge_page(hpage);
>-	/* keep elevated page count for bad page */
>+
> 	return ret;
> }
>
>@@ -1488,6 +1489,11 @@ int soft_offline_page(struct page *page, int flags)
> 		}
> 	}
>
>+	if (PageHWPoison(page)) {
>+		pr_info("soft offline: %#lx page already poisoned\n", pfn);
>+		return -EBUSY;
>+	}
>+
> 	ret = get_any_page(page, pfn, flags);
> 	if (ret < 0)
> 		return ret;
>@@ -1519,19 +1525,11 @@ int soft_offline_page(struct page *page, int flags)
> 		return -EIO;
> 	}
>
>-	lock_page(page);
>-	wait_on_page_writeback(page);
>-
> 	/*
> 	 * Synchronized using the page lock with memory_failure()
> 	 */
>-	if (PageHWPoison(page)) {
>-		unlock_page(page);
>-		put_page(page);
>-		pr_info("soft offline: %#lx page already poisoned\n", pfn);
>-		return -EBUSY;
>-	}
>-
>+	lock_page(page);
>+	wait_on_page_writeback(page);
> 	/*
> 	 * Try to invalidate first. This should work for
> 	 * non dirty unmapped page cache pages.
>@@ -1582,8 +1580,11 @@ int soft_offline_page(struct page *page, int flags)
> 		return ret;
>
> done:
>+	/* keep elevated page count for bad page */
>+	lock_page(page);
> 	atomic_long_add(1, &mce_bad_pages);
> 	SetPageHWPoison(page);
>-	/* keep elevated page count for bad page */
>+	unlock_page(page);
>+

Hi Xishi,

Why add lock_page here, the comment in function unpoison_memory tell us
we don't need it.

/*
 * This test is racy because PG_hwpoison is set outside of page lock.
 * That's acceptable because that won't trigger kernel panic. Instead,
 * the PG_hwpoison page will be caught and isolated on the entrance to
 * the free buddy page pool.
 */

Futhermore, Andrew didn't like a variable called "mce_bad_pages".

- Why do we have a variable called "mce_bad_pages"?  MCE is an x86
  concept, and this code is in mm/.  Lights are flashing, bells are
  ringing and a loudspeaker is blaring "layering violation" at us!

Regards,
Wanpeng Li 

> 	return ret;
> }
>-- 
>1.7.1
>
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
