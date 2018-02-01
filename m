Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7036B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 03:28:59 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id a17so16057642qta.10
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 00:28:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d15si3857712qkj.82.2018.02.01.00.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 00:28:58 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w118SsQ4061075
	for <linux-mm@kvack.org>; Thu, 1 Feb 2018 03:28:58 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fuxkf280f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Feb 2018 03:28:56 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 1 Feb 2018 08:28:42 -0000
Subject: Re: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
 <20180130075949.GN21609@dhcp22.suse.cz>
 <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
 <20180131075852.GL21609@dhcp22.suse.cz>
 <20180131121217.4c80263d68a4ad4da7b170f0@linux-foundation.org>
 <20180131203242.GB21609@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 1 Feb 2018 13:58:36 +0530
MIME-Version: 1.0
In-Reply-To: <20180131203242.GB21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <29b6db3a-f853-b81b-0632-c1841298ab87@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/01/2018 02:02 AM, Michal Hocko wrote:
> On Wed 31-01-18 12:12:17, Andrew Morton wrote:
>> On Wed, 31 Jan 2018 08:58:52 +0100 Michal Hocko <mhocko@kernel.org> wrote:
>>
>>> On Wed 31-01-18 07:55:05, Anshuman Khandual wrote:
>>>> On 01/30/2018 01:29 PM, Michal Hocko wrote:
>>>>> On Tue 30-01-18 08:37:14, Anshuman Khandual wrote:
>>>>>> alloc_contig_range() initiates compaction and eventual migration for
>>>>>> the purpose of either CMA or HugeTLB allocation. At present, reason
>>>>>> code remains the same MR_CMA for either of those cases. Lets add a
>>>>>> new reason code which will differentiate the purpose of migration
>>>>>> as HugeTLB allocation instead.
>>>>> Why do we need it?
>>>>
>>>> The same reason why we have MR_CMA (maybe some other ones as well) at
>>>> present, for reporting purpose through traces at the least. It just
>>>> seemed like same reason code is being used for two different purpose
>>>> of migration.
>>>
>>> But do we have any real user asking for this kind of information?
>>
>> It seems a reasonable cleanup: reusing MR_CMA for hugetlb just because
>> it happens to do the right thing is a bit hacky - the two things aren't
>> particularly related and a reader could be excused for feeling
>> confusion.
> 
> My bad! I thought this is a tracepoint thingy. But it seems to be only
> used as a migration reason for page_owner. Now it makes more sense.
>  
>> But the change seems incomplete:
>>
>>> +		if (migratetype == MIGRATE_CMA)
>>> +			migrate_reason = MR_CMA;
>>> +		else
>>> +			migrate_reason = MR_HUGETLB;
>>
>> If we're going to do this cleanup then shouldn't we go all the way and
>> add MIGRATE_HUGETLB?
> 
> Yes. We can expect more users of alloc_contig_range in future. Maybe we
> want to use MR_CONTIG_RANGE instead.

MR_CONTIG_RANGE can be a replacement for both MR_CMA and MR_HUGETLB.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
