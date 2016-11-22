Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08B816B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:48:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so1915719wms.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 20:48:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id jp8si23723719wjc.10.2016.11.21.20.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 20:48:36 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM4hoMC079796
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:48:35 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vcp5nhjw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:48:35 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 14:48:32 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0C0BE3578053
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:48:30 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM4mUqH3604818
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:48:30 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM4mTjg025071
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:48:29 +1100
Subject: Re: [HMM v13 06/18] mm/ZONE_DEVICE/unaddressable: add special swap
 for unaddressable
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-7-git-send-email-jglisse@redhat.com>
 <5832D33C.6030403@linux.vnet.ibm.com> <20161121124218.GF2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 10:18:27 +0530
MIME-Version: 1.0
In-Reply-To: <20161121124218.GF2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833CE1B.6030104@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 06:12 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 04:28:04PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
>>> To allow use of device un-addressable memory inside a process add a
>>> special swap type. Also add a new callback to handle page fault on
>>> such entry.
>>
>> IIUC this swap type is required only for the mirror cases and its
>> not a requirement for migration. If it's required for mirroring
>> purpose where we intercept each page fault, the commit message
>> here should clearly elaborate on that more.
> 
> It is only require for un-addressable memory. The mirroring has nothing to do
> with it. I will clarify commit message.

One thing though. I dont recall how persistent memory ZONE_DEVICE
pages are handled inside the page tables, point here is it should
be part of the same code block. We should catch that its a device
memory page and then figure out addressable or not and act
accordingly. Because persistent memory are CPU addressable, there
might not been special code block but dealing with device pages 
should be handled in a more holistic manner.

> 
> [...]
> 
>>> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>>> index b6f03e9..d584c74 100644
>>> --- a/include/linux/memremap.h
>>> +++ b/include/linux/memremap.h
>>> @@ -47,6 +47,11 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>>>   */
>>>  struct dev_pagemap {
>>>  	void (*free_devpage)(struct page *page, void *data);
>>> +	int (*fault)(struct vm_area_struct *vma,
>>> +		     unsigned long addr,
>>> +		     struct page *page,
>>> +		     unsigned flags,
>>> +		     pmd_t *pmdp);
>>
>> We are extending the dev_pagemap once again to accommodate device driver
>> specific fault routines for these pages. Wondering if this extension and
>> the new swap type should be in the same patch.
> 
> It make sense to have it in one single patch as i also change page fault code
> path to deal with the new special swap entry and those make use of this new
> callback.
> 

Okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
