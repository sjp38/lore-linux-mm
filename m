Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3D06B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:55:42 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id i66so31357382yba.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 23:55:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k21si4061747iok.15.2017.02.22.23.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 23:55:41 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N7rlr1120084
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:55:41 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28sqms8dt0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:55:40 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 17:55:37 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 307612CE8054
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:55:19 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1N7tARW52953106
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:55:18 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1N7skLX029827
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:54:46 +1100
Subject: Re: [RFC PATCH 04/14] mm/migrate: Add new migrate mode MIGRATE_MT
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-5-zi.yan@sent.com>
 <20170223065429.GB7336@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 13:24:19 +0530
MIME-Version: 1.0
In-Reply-To: <20170223065429.GB7336@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <68afbd19-32c7-9b36-a744-866f6fa29ef3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On 02/23/2017 12:24 PM, Naoya Horiguchi wrote:
> On Fri, Feb 17, 2017 at 10:05:41AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> This change adds a new migration mode called MIGRATE_MT to enable multi
>> threaded page copy implementation inside copy_huge_page() function by
>> selectively calling copy_pages_mthread() when requested. But it still
>> falls back using the regular page copy mechanism instead the previous
>> multi threaded attempt fails. It also attempts multi threaded copy for
>> regular pages.
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  include/linux/migrate_mode.h |  1 +
>>  mm/migrate.c                 | 25 ++++++++++++++++++-------
>>  2 files changed, 19 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
>> index 89c170060e5b..d344ad60f499 100644
>> --- a/include/linux/migrate_mode.h
>> +++ b/include/linux/migrate_mode.h
>> @@ -12,6 +12,7 @@ enum migrate_mode {
>>  	MIGRATE_SYNC_LIGHT	= 1<<1,
>>  	MIGRATE_SYNC		= 1<<2,
>>  	MIGRATE_ST		= 1<<3,
>> +	MIGRATE_MT		= 1<<4,
> 
> Could you update the comment above this definition to cover the new flags.

Sure, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
