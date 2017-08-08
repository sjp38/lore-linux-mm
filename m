Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79A916B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:08:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so34126443pge.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:08:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 5si855637pfi.554.2017.08.08.06.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:08:09 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78D5HJb127052
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 09:08:08 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7byh91vj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:08:08 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 14:08:05 +0100
Subject: Re: [RFC v5 05/11] mm: fix lock dependency against
 mapping->i_mmap_rwsem
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <564749a2-a729-b927-7707-1cad897c418a@linux.vnet.ibm.com>
 <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
 <20170808124942.GD20321@quack2.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 15:08:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170808124942.GD20321@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <7fe897cd-ba24-9969-161b-943dd62de083@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 08/08/2017 14:49, Jan Kara wrote:
> On Tue 08-08-17 14:20:23, Laurent Dufour wrote:
>> On 08/08/2017 13:17, Anshuman Khandual wrote:
>>> On 06/16/2017 11:22 PM, Laurent Dufour wrote:
>>>> kworker/32:1/819 is trying to acquire lock:
>>>>  (&vma->vm_sequence){+.+...}, at: [<c0000000002f20e0>]
>>>> zap_page_range_single+0xd0/0x1a0
>>>>
>>>> but task is already holding lock:
>>>>  (&mapping->i_mmap_rwsem){++++..}, at: [<c0000000002f229c>]
>>>> unmap_mapping_range+0x7c/0x160
>>>>
>>>> which lock already depends on the new lock.
>>>>
>>>> the existing dependency chain (in reverse order) is:
>>>>
>>>> -> #2 (&mapping->i_mmap_rwsem){++++..}:
>>>>        down_write+0x84/0x130
>>>>        __vma_adjust+0x1f4/0xa80
>>>>        __split_vma.isra.2+0x174/0x290
>>>>        do_munmap+0x13c/0x4e0
>>>>        vm_munmap+0x64/0xb0
>>>>        elf_map+0x11c/0x130
>>>>        load_elf_binary+0x6f0/0x15f0
>>>>        search_binary_handler+0xe0/0x2a0
>>>>        do_execveat_common.isra.14+0x7fc/0xbe0
>>>>        call_usermodehelper_exec_async+0x14c/0x1d0
>>>>        ret_from_kernel_thread+0x5c/0x68
>>>>
>>>> -> #1 (&vma->vm_sequence/1){+.+...}:
>>>>        __vma_adjust+0x124/0xa80
>>>>        __split_vma.isra.2+0x174/0x290
>>>>        do_munmap+0x13c/0x4e0
>>>>        vm_munmap+0x64/0xb0
>>>>        elf_map+0x11c/0x130
>>>>        load_elf_binary+0x6f0/0x15f0
>>>>        search_binary_handler+0xe0/0x2a0
>>>>        do_execveat_common.isra.14+0x7fc/0xbe0
>>>>        call_usermodehelper_exec_async+0x14c/0x1d0
>>>>        ret_from_kernel_thread+0x5c/0x68
>>>>
>>>> -> #0 (&vma->vm_sequence){+.+...}:
>>>>        lock_acquire+0xf4/0x310
>>>>        unmap_page_range+0xcc/0xfa0
>>>>        zap_page_range_single+0xd0/0x1a0
>>>>        unmap_mapping_range+0x138/0x160
>>>>        truncate_pagecache+0x50/0xa0
>>>>        put_aio_ring_file+0x48/0xb0
>>>>        aio_free_ring+0x40/0x1b0
>>>>        free_ioctx+0x38/0xc0
>>>>        process_one_work+0x2cc/0x8a0
>>>>        worker_thread+0xac/0x580
>>>>        kthread+0x164/0x1b0
>>>>        ret_from_kernel_thread+0x5c/0x68
>>>>
>>>> other info that might help us debug this:
>>>>
>>>> Chain exists of:
>>>>   &vma->vm_sequence --> &vma->vm_sequence/1 --> &mapping->i_mmap_rwsem
>>>>
>>>>  Possible unsafe locking scenario:
>>>>
>>>>        CPU0                    CPU1
>>>>        ----                    ----
>>>>   lock(&mapping->i_mmap_rwsem);
>>>>                                lock(&vma->vm_sequence/1);
>>>>                                lock(&mapping->i_mmap_rwsem);
>>>>   lock(&vma->vm_sequence);
>>>>
>>>>  *** DEADLOCK ***
>>>>
>>>> To fix that we must grab the vm_sequence lock after any mapping one in
>>>> __vma_adjust().
>>>>
>>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>>
>>> Should not this be folded back into the previous patch ? It fixes an
>>> issue introduced by the previous one.
>>
>> This is an option, but the previous one was signed by Peter, and I'd prefer
>> to keep his unchanged and add this new one to fix that.
>> Again this is to ease the review.
> 
> In this particular case I disagree. We should not have buggy patches in the
> series. It breaks bisectability and the ease of review is IMO very
> questionable because the previous patch is simply buggy and thus is hard to
> validate on its own. If the resulting combo would be too complex, you could
> think of a different way how to split it up so that intermediate steps are
> not buggy...

I don't think the combo will become too large, it's just moving some calls
around. So as bisectability seems to be more important than readability,
I'll merge it into the original Peter's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
