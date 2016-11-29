Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7449D6B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:10:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so243380038pfg.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 21:10:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u20si58221774pfd.147.2016.11.28.21.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 21:10:26 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAT59DkH095527
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:10:25 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271367rufq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:10:25 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 29 Nov 2016 15:10:23 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 8CE4A2BB005B
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:10:20 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAT5AKKJ48496802
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:10:20 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAT5AJBs007542
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:10:20 +1100
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support additional
 page copy routines.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-2-zi.yan@sent.com>
 <dbb93172-4dd1-e88e-f65d-321ac7882999@gmail.com>
 <B5823455-07C1-46A8-8F05-A109E9935A20@cs.rutgers.edu>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 29 Nov 2016 10:40:12 +0530
MIME-Version: 1.0
In-Reply-To: <B5823455-07C1-46A8-8F05-A109E9935A20@cs.rutgers.edu>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <583D0DB4.5060201@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com

On 11/28/2016 08:43 PM, Zi Yan wrote:
> On 24 Nov 2016, at 18:56, Balbir Singh wrote:
> 
>> > On 23/11/16 03:25, Zi Yan wrote:
>>> >> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>> >>
>>> >> From: Zi Yan <ziy@nvidia.com>
>>> >>
>>> >> migrate_page_copy() and copy_huge_page() are affected.
>>> >>
>>> >> Signed-off-by: Zi Yan <ziy@nvidia.com>
>>> >> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>>> >> ---
>>> >>  fs/aio.c                |  2 +-
>>> >>  fs/hugetlbfs/inode.c    |  2 +-
>>> >>  fs/ubifs/file.c         |  2 +-
>>> >>  include/linux/migrate.h |  6 ++++--
>>> >>  mm/migrate.c            | 14 ++++++++------
>>> >>  5 files changed, 15 insertions(+), 11 deletions(-)
>>> >>
>>> >> diff --git a/fs/aio.c b/fs/aio.c
>>> >> index 428484f..a67c764 100644
>>> >> --- a/fs/aio.c
>>> >> +++ b/fs/aio.c
>>> >> @@ -418,7 +418,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
>>> >>  	 * events from being lost.
>>> >>  	 */
>>> >>  	spin_lock_irqsave(&ctx->completion_lock, flags);
>>> >> -	migrate_page_copy(new, old);
>>> >> +	migrate_page_copy(new, old, 0);
>> >
>> > Can we have a useful enum instead of 0, its harder to read and understand
>> > 0
> How about MIGRATE_SINGLETHREAD = 0 ?

Right, should be an enum declaration for all kind of single page
copy process. Now we have just two. We dont have to mention
number of threads in the multi threaded one.

MIGRATE_SINGLETHREAD
MIGRATE_MULTITHREAD

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
