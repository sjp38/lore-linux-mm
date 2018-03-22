Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58F0E6B002D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:55:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o23so4555716wrc.9
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:55:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 33si855021ede.244.2018.03.22.08.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 08:54:59 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2MFs9mg141154
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:54:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gvcfpswn3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:54:58 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 22 Mar 2018 15:54:56 -0000
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
 <20180321224631.GB3969@bombadil.infradead.org>
 <18a727fd-f006-9fae-d9ca-74b9004f0a8b@linux.vnet.ibm.com>
 <20180322154055.GB28468@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 22 Mar 2018 16:54:52 +0100
MIME-Version: 1.0
In-Reply-To: <20180322154055.GB28468@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <0442fb0e-3da3-3f23-ce4d-0f6cbc3eac9a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 22/03/2018 16:40, Matthew Wilcox wrote:
> On Thu, Mar 22, 2018 at 04:32:00PM +0100, Laurent Dufour wrote:
>> On 21/03/2018 23:46, Matthew Wilcox wrote:
>>> On Wed, Mar 21, 2018 at 02:45:44PM -0700, Yang Shi wrote:
>>>> Marking vma as deleted sounds good. The problem for my current approach is
>>>> the concurrent page fault may succeed if it access the not yet unmapped
>>>> section. Marking deleted vma could tell page fault the vma is not valid
>>>> anymore, then return SIGSEGV.
>>>>
>>>>> does not care; munmap will need to wait for the existing munmap operation
>>>>
>>>> Why mmap doesn't care? How about MAP_FIXED? It may fail unexpectedly, right?
>>>
>>> The other thing about MAP_FIXED that we'll need to handle is unmapping
>>> conflicts atomically.  Say a program has a 200GB mapping and then
>>> mmap(MAP_FIXED) another 200GB region on top of it.  So I think page faults
>>> are also going to have to wait for deleted vmas (then retry the fault)
>>> rather than immediately raising SIGSEGV.
>>
>> Regarding the page fault, why not relying on the PTE locking ?
>>
>> When munmap() will unset the PTE it will have to held the PTE lock, so this
>> will serialize the access.
>> If the page fault occurs before the mmap(MAP_FIXED), the page mapped will be
>> removed when mmap(MAP_FIXED) would do the cleanup. Fair enough.
> 
> The page fault handler will walk the VMA tree to find the correct
> VMA and then find that the VMA is marked as deleted.  If it assumes
> that the VMA has been deleted because of munmap(), then it can raise
> SIGSEGV immediately.  But if the VMA is marked as deleted because of
> mmap(MAP_FIXED), it must wait until the new VMA is in place.

I'm wondering if such a complexity is required.
If the user space process try to access the page being overwritten through
mmap(MAP_FIXED) by another thread, there is no guarantee that it will
manipulate the *old* page or *new* one.
I'd think this is up to the user process to handle that concurrency.
What needs to be guaranteed is that once mmap(MAP_FIXED) returns the old page
are no more there, which is done through the mmap_sem and PTE locking.

> I think I was wrong to describe VMAs as being *deleted*.  I think we
> instead need the concept of a *locked* VMA that page faults will block on.
> Conceptually, it's a per-VMA rwsem, but I'd use a completion instead of
> an rwsem since the only reason to write-lock the VMA is because it is
> being deleted.

Such a lock would only makes sense in the case of mmap(MAP_FIXED) since when
the VMA is removed there is no need to wait. Isn't it ?
