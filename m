Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 399766B02F4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:11:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so4370105wrd.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:11:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k1si1111422wrf.34.2017.08.08.05.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:11:54 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78C4s9u144731
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 08:11:53 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c7c2s4983-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:11:53 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 13:11:50 +0100
Subject: Re: [RFC v5 01/11] mm: Dont assume page-table invariance during
 faults
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <57cbb4ca-7f04-ac50-3321-2c34ac08307b@linux.vnet.ibm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 14:11:44 +0200
MIME-Version: 1.0
In-Reply-To: <57cbb4ca-7f04-ac50-3321-2c34ac08307b@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e1d576f4-82f9-04f1-3387-19fb72bdb161@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 08/08/2017 11:45, Anshuman Khandual wrote:
> On 06/16/2017 11:22 PM, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> One of the side effects of speculating on faults (without holding
>> mmap_sem) is that we can race with free_pgtables() and therefore we
>> cannot assume the page-tables will stick around.
>>
>> Remove the relyance on the pte pointer.
> 
> Looking into other parts of the series, it seemed like now we have
> sequence lock both at MM and VMA level but then after that we still
> need to take page table lock before handling page faults (in turn
> manipulating PTE which includes swap in paths as well). Is not that
> true ?

Page table locking is still required as several VMAs can reference the same
page table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
