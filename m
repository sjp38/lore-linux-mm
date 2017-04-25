Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF6F6B0317
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:16:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k57so5187984wrk.6
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:16:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v20si3609663wra.152.2017.04.25.07.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 07:16:53 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PEEUZp029789
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:16:52 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a1msacu78-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:16:52 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 15:16:48 +0100
Subject: Re: [RFC 2/2] mm: skip HWPoisoned pages when onlining pages
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1492680362-24941-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170425080052.GB18194@hori1.linux.bs1.fc.nec.co.jp>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 25 Apr 2017 16:16:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170425080052.GB18194@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <d5ea98ec-5252-daf8-7d5b-0b4b25443710@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 25/04/2017 10:00, Naoya Horiguchi wrote:
> On Thu, Apr 20, 2017 at 11:26:02AM +0200, Laurent Dufour wrote:
>> The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
>> offlining pages") skip the HWPoisoned pages when offlining pages, but
>> this should be skipped when onlining the pages too.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/memory_hotplug.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 6fa7208bcd56..20e1fadc2369 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -942,6 +942,8 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>>  	if (PageReserved(pfn_to_page(start_pfn)))
>>  		for (i = 0; i < nr_pages; i++) {
>>  			page = pfn_to_page(start_pfn + i);
>> +			if (PageHWPoison(page))
>> +				continue;
> 
> Is it OK that PageReserved (set by __offline_isolated_pages for non-buddy
> hwpoisoned pages) still remains in this path?

To be honest, I've no clue.

> If online_pages_range() is the reverse operation of __offline_isolated_pages(),
> ClearPageReserved seems needed here.

I added a call to ClearPageReserved in the if (PageHWPoison(..)) and run
some tests.
This seems to work fine as well, but I'm not sure about the side effect.

I'll add it to my next version.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
