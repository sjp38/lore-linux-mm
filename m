Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8057C6B004D
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 20:24:10 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 21:18:23 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 84B1D2BB004F
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:24:03 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7N07s3Q10355166
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:07:55 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7N0O2Dn006367
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:24:02 +1000
Date: Fri, 23 Aug 2013 08:24:00 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] hwpoison: always unset MIGRATE_ISOLATE before returning
 from soft_offline_page()
Message-ID: <20130823002400.GA25610@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377199247-2kdx6aoc-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377199247-2kdx6aoc-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 03:20:47PM -0400, Naoya Horiguchi wrote:
>Soft offline code expects that MIGRATE_ISOLATE is set on the target page
>only during soft offlining work. But currenly it doesn't work as expected
>when get_any_page() fails and returns negative value. In the result, end
>users can have unexpectedly isolated pages. This patch just fixes it.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> mm/memory-failure.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>index af6f61c..1cb3b7d 100644
>--- a/mm/memory-failure.c
>+++ b/mm/memory-failure.c
>@@ -1550,7 +1550,7 @@ int soft_offline_page(struct page *page, int flags)
>
> 	ret = get_any_page(page, pfn, flags);
> 	if (ret < 0)
>-		return ret;
>+		goto unset;
> 	if (ret) { /* for in-use pages */
> 		if (PageHuge(page))
> 			ret = soft_offline_huge_page(page, flags);
>@@ -1567,6 +1567,7 @@ int soft_offline_page(struct page *page, int flags)
> 			atomic_long_inc(&num_poisoned_pages);
> 		}
> 	}
>+unset:
> 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
> 	return ret;
> }
>-- 
>1.8.3.1
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
