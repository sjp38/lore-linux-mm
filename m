Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A358C6B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:31:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so11273315pga.4
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 20:31:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m188si25601743pfc.211.2016.11.21.20.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 20:31:08 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM4SwBQ102680
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:31:08 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26v7h1gkkb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:31:07 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 14:31:04 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A682A2CE8059
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:31:02 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM4V2Wg52494426
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:31:02 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM4V2Hn007398
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:31:02 +1100
Subject: Re: [HMM v13 03/18] mm/ZONE_DEVICE/free_hot_cold_page: catch
 ZONE_DEVICE pages
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-4-git-send-email-jglisse@redhat.com>
 <5832ADD2.5000507@linux.vnet.ibm.com> <20161121125029.GG2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 10:00:54 +0530
MIME-Version: 1.0
In-Reply-To: <20161121125029.GG2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833C9FE.4030506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 06:20 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 01:48:26PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
>>> Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
>>> happen as ZONE_DEVICE page must always have an elevated refcount.
>>>
>>> This is to catch refcounting issues in a sane way for ZONE_DEVICE pages.
>>>
>>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>>> ---
>>>  mm/page_alloc.c | 10 ++++++++++
>>>  1 file changed, 10 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 0fbfead..09b2630 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -2435,6 +2435,16 @@ void free_hot_cold_page(struct page *page, bool cold)
>>>  	unsigned long pfn = page_to_pfn(page);
>>>  	int migratetype;
>>>  
>>> +	/*
>>> +	 * This should never happen ! Page from ZONE_DEVICE always must have an
>>> +	 * active refcount. Complain about it and try to restore the refcount.
>>> +	 */
>>> +	if (is_zone_device_page(page)) {
>>> +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
>>> +		page_ref_inc(page);
>>> +		return;
>>> +	}
>>
>> This fixes an issue in the existing ZONE_DEVICE code, should not this
>> patch be sent separately not in this series ?
>>
> 
> Well this is more like a safetynet feature, i can send it separately from the
> series. It is not an issue per say as a trap to catch bugs. I had refcounting
> bugs while working on this patchset and having this safetynet was helpful to
> quickly pin-point issues.

Sure at the least move them up in the series as ZONE_DEVICE preparatory
fixes before expanding ZONE_DEVICE framework to accommodate the new
un-addressable memory representation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
