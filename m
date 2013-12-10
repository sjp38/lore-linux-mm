Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E1B6E6B005A
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:18:06 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so6581353pbb.22
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:18:06 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id pk8si8954572pab.97.2013.12.09.18.18.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:18:05 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 12:18:01 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 07E762BB0053
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:17:59 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA1xdGp10158384
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:59:39 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2HvHZ017717
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:17:58 +1100
Date: Tue, 10 Dec 2013 10:17:56 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/7] mm/migrate: correct failure handling if
 !hugepage_migration_support()
Message-ID: <52a679dd.8886420a.34d4.1b0eSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hi Joonsoo,
On Mon, Dec 09, 2013 at 06:10:43PM +0900, Joonsoo Kim wrote:
>We should remove the page from the list if we fail without ENOSYS,
>since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
>as permanent failure and it assumes that the page would be removed from
>the list. Without this patch, we could overcount number of failure.
>
>In addition, we should put back the new hugepage if
>!hugepage_migration_support(). If not, we would leak hugepage memory.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/migrate.c b/mm/migrate.c
>index c6ac87a..b1cfd01 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -1011,7 +1011,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> {
> 	int rc = 0;
> 	int *result = NULL;
>-	struct page *new_hpage = get_new_page(hpage, private, &result);
>+	struct page *new_hpage;
> 	struct anon_vma *anon_vma = NULL;
>
> 	/*
>@@ -1021,9 +1021,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> 	 * tables or check whether the hugepage is pmd-based or not before
> 	 * kicking migration.
> 	 */
>-	if (!hugepage_migration_support(page_hstate(hpage)))
>+	if (!hugepage_migration_support(page_hstate(hpage))) {
>+		putback_active_hugepage(hpage);
> 		return -ENOSYS;

The memory hotplug(do_migrate_range) and hwpoison(soft_offline_huge_page) callsets both 
will call putback_movable_pages/putback_active_hugepage for -ENOSYS case.

Regards,
Wanpeng Li 

>+	}
>
>+	new_hpage = get_new_page(hpage, private, &result);
> 	if (!new_hpage)
> 		return -ENOMEM;
>
>-- 
>1.7.9.5
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
