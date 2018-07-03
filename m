Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61C4F6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 01:23:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r15-v6so431970edq.22
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 22:23:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g16-v6si537237edp.450.2018.07.02.22.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 22:23:22 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w635ENm2024706
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 01:23:20 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k02d7s2nb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 01:23:20 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 3 Jul 2018 06:23:17 +0100
Subject: Re: [PATCHi v2] mm: do not drop unused pages when userfaultd is
 running
References: <20180702075049.9157-1-borntraeger@de.ibm.com>
 <20180702140638.eb3edfaa611ba9fa018f92eb@linux-foundation.org>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 3 Jul 2018 07:23:12 +0200
MIME-Version: 1.0
In-Reply-To: <20180702140638.eb3edfaa611ba9fa018f92eb@linux-foundation.org>
Content-Language: en-US
Message-Id: <f40c57df-d8ea-d317-891b-89959ebf6353@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, David Hildenbrand <david@redhat.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>



On 07/02/2018 11:06 PM, Andrew Morton wrote:
> On Mon,  2 Jul 2018 09:50:49 +0200 Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> 
>> KVM guests on s390 can notify the host of unused pages. This can result
>> in pte_unused callbacks to be true for KVM guest memory.
>>
>> If a page is unused (checked with pte_unused) we might drop this page
>> instead of paging it. This can have side-effects on userfaultd, when the
>> page in question was already migrated:
>>
>> The next access of that page will trigger a fault and a user fault
>> instead of faulting in a new and empty zero page. As QEMU does not
>> expect a userfault on an already migrated page this migration will fail.
>>
>> The most straightforward solution is to ignore the pte_unused hint if a
>> userfault context is active for this VMA.
>>
>> ...
>>
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -64,6 +64,7 @@
>>  #include <linux/backing-dev.h>
>>  #include <linux/page_idle.h>
>>  #include <linux/memremap.h>
>> +#include <linux/userfaultfd_k.h>
>>  
>>  #include <asm/tlbflush.h>
>>  
>> @@ -1481,7 +1482,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  				set_pte_at(mm, address, pvmw.pte, pteval);
>>  			}
>>  
>> -		} else if (pte_unused(pteval)) {
>> +		} else if (pte_unused(pteval) && !userfaultfd_armed(vma)) {


>>  			/*
>>  			 * The guest indicated that the page content is of no
>>  			 * interest anymore. Simply discard the pte, vmscan
> 
> A reader of this code will wonder why we're checking
> userfaultfd_armed().  So the writer of this code should add a comment
> which explains this to them ;)  Please.
> 
Something like:                    /*
                         * The guest indicated that the page content is of no
                         * interest anymore. Simply discard the pte, vmscan
                         * will take care of the rest.
			 * A future reference will then fault in a new zero
			 * page. When userfaultfd is active, we must not drop
			 * this page though, as its main user (postcopy
			 * migration) will not expect userfaults on already
			 * copied pages.
                         */

?
