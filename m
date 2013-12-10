Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EF1816B00AE
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:27:50 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so6960671pde.20
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:27:50 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id sj5si9934823pab.52.2013.12.10.01.27.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 01:27:49 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 14:57:34 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 443EDE0057
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:59:50 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA9RSi91769894
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:57:28 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA9RU13027113
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:57:31 +0530
Date: Tue, 10 Dec 2013 17:27:28 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/7] mm/migrate: correct failure handling if
 !hugepage_migration_support()
Message-ID: <52a6de95.2590420a.170c.1019SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-3-git-send-email-iamjoonsoo.kim@lge.com>
 <52a679dd.8886420a.34d4.1b0eSMTPIN_ADDED_BROKEN@mx.google.com>
 <20131210084507.GC24992@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131210084507.GC24992@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, Dec 10, 2013 at 05:45:07PM +0900, Joonsoo Kim wrote:
>On Tue, Dec 10, 2013 at 10:17:56AM +0800, Wanpeng Li wrote:
>> Hi Joonsoo,
>> On Mon, Dec 09, 2013 at 06:10:43PM +0900, Joonsoo Kim wrote:
>> >We should remove the page from the list if we fail without ENOSYS,
>> >since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
>> >as permanent failure and it assumes that the page would be removed from
>> >the list. Without this patch, we could overcount number of failure.
>> >
>> >In addition, we should put back the new hugepage if
>> >!hugepage_migration_support(). If not, we would leak hugepage memory.
>> >
>> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> >
>> >diff --git a/mm/migrate.c b/mm/migrate.c
>> >index c6ac87a..b1cfd01 100644
>> >--- a/mm/migrate.c
>> >+++ b/mm/migrate.c
>> >@@ -1011,7 +1011,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>> > {
>> > 	int rc = 0;
>> > 	int *result = NULL;
>> >-	struct page *new_hpage = get_new_page(hpage, private, &result);
>> >+	struct page *new_hpage;
>> > 	struct anon_vma *anon_vma = NULL;
>> >
>> > 	/*
>> >@@ -1021,9 +1021,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>> > 	 * tables or check whether the hugepage is pmd-based or not before
>> > 	 * kicking migration.
>> > 	 */
>> >-	if (!hugepage_migration_support(page_hstate(hpage)))
>> >+	if (!hugepage_migration_support(page_hstate(hpage))) {
>> >+		putback_active_hugepage(hpage);
>> > 		return -ENOSYS;
>> 
>> The memory hotplug(do_migrate_range) and hwpoison(soft_offline_huge_page) callsets both 
>> will call putback_movable_pages/putback_active_hugepage for -ENOSYS case.
>
>Hello Wanpeng.
>
>Yes, those callsite handle error case, but error case handling should be done
>in unmap_and_move_huge_page(). It is mentioned on patch 1. If we defer to
>remove the pages from the list, nr_failed can be overcounted.
>

I see. 

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
