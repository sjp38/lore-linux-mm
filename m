Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2726B000D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:16:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 65so761406wrn.7
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 01:16:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g25si2243184edf.328.2018.03.28.01.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 01:16:02 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2S888Kr117579
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:16:00 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h06q5jrfp-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:16:00 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 09:15:57 +0100
Subject: Re: [PATCH v9 05/24] mm: Introduce pte_spinlock for
 FAULT_FLAG_SPECULATIVE
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803251446180.80485@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 10:15:47 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803251446180.80485@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <56b596fe-f235-7033-348b-b0d6c9481f2c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 25/03/2018 23:50, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> When handling page fault without holding the mmap_sem the fetch of the
>> pte lock pointer and the locking will have to be done while ensuring
>> that the VMA is not touched in our back.
>>
>> So move the fetch and locking operations in a dedicated function.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/memory.c | 15 +++++++++++----
>>  1 file changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 8ac241b9f370..21b1212a0892 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2288,6 +2288,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>>  }
>>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>>  
>> +static bool pte_spinlock(struct vm_fault *vmf)
> 
> inline?

You're right.
Indeed this was done in the patch 18 : "mm: Provide speculative fault
infrastructure", but this has to be done there too, I'll fix that.

> 
>> +{
>> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	spin_lock(vmf->ptl);
>> +	return true;
>> +}
>> +
>>  static bool pte_map_lock(struct vm_fault *vmf)
>>  {
>>  	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> 
> Shouldn't pte_unmap_same() take struct vm_fault * and use the new 
> pte_spinlock()?

done in the next patch, but you already acked it..
