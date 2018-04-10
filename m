Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CECC6B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:20:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v11so8456902wri.13
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:20:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j62si1086127edd.49.2018.04.10.09.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:20:40 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AGHoL9081408
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:20:39 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h90hkrked-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:20:39 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 17:20:35 +0100
Subject: Re: [PATCH v9 17/24] mm: Protect mm_rb tree with a rwlock
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804021711090.34466@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 10 Apr 2018 18:20:25 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021711090.34466@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <8191409a-d7aa-6476-6aa9-1d1c4dced788@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 03/04/2018 02:11, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> This change is inspired by the Peter's proposal patch [1] which was
>> protecting the VMA using SRCU. Unfortunately, SRCU is not scaling well in
>> that particular case, and it is introducing major performance degradation
>> due to excessive scheduling operations.
>>
>> To allow access to the mm_rb tree without grabbing the mmap_sem, this patch
>> is protecting it access using a rwlock.  As the mm_rb tree is a O(log n)
>> search it is safe to protect it using such a lock.  The VMA cache is not
>> protected by the new rwlock and it should not be used without holding the
>> mmap_sem.
>>
>> To allow the picked VMA structure to be used once the rwlock is released, a
>> use count is added to the VMA structure. When the VMA is allocated it is
>> set to 1.  Each time the VMA is picked with the rwlock held its use count
>> is incremented. Each time the VMA is released it is decremented. When the
>> use count hits zero, this means that the VMA is no more used and should be
>> freed.
>>
>> This patch is preparing for 2 kind of VMA access :
>>  - as usual, under the control of the mmap_sem,
>>  - without holding the mmap_sem for the speculative page fault handler.
>>
>> Access done under the control the mmap_sem doesn't require to grab the
>> rwlock to protect read access to the mm_rb tree, but access in write must
>> be done under the protection of the rwlock too. This affects inserting and
>> removing of elements in the RB tree.
>>
>> The patch is introducing 2 new functions:
>>  - vma_get() to find a VMA based on an address by holding the new rwlock.
>>  - vma_put() to release the VMA when its no more used.
>> These services are designed to be used when access are made to the RB tree
>> without holding the mmap_sem.
>>
>> When a VMA is removed from the RB tree, its vma->vm_rb field is cleared and
>> we rely on the WMB done when releasing the rwlock to serialize the write
>> with the RMB done in a later patch to check for the VMA's validity.
>>
>> When free_vma is called, the file associated with the VMA is closed
>> immediately, but the policy and the file structure remained in used until
>> the VMA's use count reach 0, which may happens later when exiting an
>> in progress speculative page fault.
>>
>> [1] https://patchwork.kernel.org/patch/5108281/
>>
>> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> 
> Can __free_vma() be generalized for mm/nommu.c's delete_vma() and 
> do_mmap()?

Good question !
I guess if there is no mmu, there is no page fault, so no speculative page
fault and this patch is clearly required by the speculative page fault handler.
By the I should probably make CONFIG_SPECULATIVE_PAGE_FAULT dependent on
CONFIG_MMU.

This being said, if your idea is to extend the mm_rb tree rwlocking to the
nommu case, then this is another story, and I wondering if there is a real need
in such case. But I've to admit I'm not so familliar with kernel built for
mmuless systems.

Am I missing something ?

Thanks,
Laurent.
