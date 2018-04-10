Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC1956B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:32:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i4so8481798wrh.4
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:32:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i4si1472087edd.139.2018.04.10.09.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:30:25 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AGQ8Vg134713
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:30:24 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h90f29a1a-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:30:24 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 17:30:21 +0100
Subject: Re: [PATCH v9 16/24] mm: Introduce __page_add_new_anon_rmap()
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-17-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804021655100.253461@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 10 Apr 2018 18:30:12 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021655100.253461@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <0a19747c-8516-d322-9c4f-b6ec41b4dea7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 03/04/2018 01:57, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> When dealing with speculative page fault handler, we may race with VMA
>> being split or merged. In this case the vma->vm_start and vm->vm_end
>> fields may not match the address the page fault is occurring.
>>
>> This can only happens when the VMA is split but in that case, the
>> anon_vma pointer of the new VMA will be the same as the original one,
>> because in __split_vma the new->anon_vma is set to src->anon_vma when
>> *new = *vma.
>>
>> So even if the VMA boundaries are not correct, the anon_vma pointer is
>> still valid.
>>
>> If the VMA has been merged, then the VMA in which it has been merged
>> must have the same anon_vma pointer otherwise the merge can't be done.
>>
>> So in all the case we know that the anon_vma is valid, since we have
>> checked before starting the speculative page fault that the anon_vma
>> pointer is valid for this VMA and since there is an anon_vma this
>> means that at one time a page has been backed and that before the VMA
>> is cleaned, the page table lock would have to be grab to clean the
>> PTE, and the anon_vma field is checked once the PTE is locked.
>>
>> This patch introduce a new __page_add_new_anon_rmap() service which
>> doesn't check for the VMA boundaries, and create a new inline one
>> which do the check.
>>
>> When called from a page fault handler, if this is not a speculative one,
>> there is a guarantee that vm_start and vm_end match the faulting address,
>> so this check is useless. In the context of the speculative page fault
>> handler, this check may be wrong but anon_vma is still valid as explained
>> above.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> 
> I'm indifferent on this: it could be argued both sides that the new 
> function and its variant for a simple VM_BUG_ON() isn't worth it and it 
> would should rather be done in the callers of page_add_new_anon_rmap().  
> It feels like it would be better left to the caller and add a comment to 
> page_add_anon_rmap() itself in mm/rmap.c.

Well there are 11 calls to page_add_new_anon_rmap() which will need to be
impacted and future ones too.

By introducing __page_add_new_anon_rmap() my goal was to make clear that this
call is *special* and that calling it is not the usual way. This also implies
that most of the time the check is done (when build with the right config) and
that we will not miss some.
