Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 994B66B0025
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:19:04 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j2so5890669qtl.1
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:19:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z37si21272qtj.105.2018.03.22.09.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 09:19:03 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2MGJ2nq045550
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:19:02 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gvf88t8jd-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:19:02 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 22 Mar 2018 16:19:00 -0000
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
 <0442fb0e-3da3-3f23-ce4d-0f6cbc3eac9a@linux.vnet.ibm.com>
 <20180322160547.GC28468@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 22 Mar 2018 17:18:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180322160547.GC28468@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <55ac947f-fd77-3754-ebfe-30d458c54403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 22/03/2018 17:05, Matthew Wilcox wrote:
> On Thu, Mar 22, 2018 at 04:54:52PM +0100, Laurent Dufour wrote:
>> On 22/03/2018 16:40, Matthew Wilcox wrote:
>>> On Thu, Mar 22, 2018 at 04:32:00PM +0100, Laurent Dufour wrote:
>>>> Regarding the page fault, why not relying on the PTE locking ?
>>>>
>>>> When munmap() will unset the PTE it will have to held the PTE lock, so this
>>>> will serialize the access.
>>>> If the page fault occurs before the mmap(MAP_FIXED), the page mapped will be
>>>> removed when mmap(MAP_FIXED) would do the cleanup. Fair enough.
>>>
>>> The page fault handler will walk the VMA tree to find the correct
>>> VMA and then find that the VMA is marked as deleted.  If it assumes
>>> that the VMA has been deleted because of munmap(), then it can raise
>>> SIGSEGV immediately.  But if the VMA is marked as deleted because of
>>> mmap(MAP_FIXED), it must wait until the new VMA is in place.
>>
>> I'm wondering if such a complexity is required.
>> If the user space process try to access the page being overwritten through
>> mmap(MAP_FIXED) by another thread, there is no guarantee that it will
>> manipulate the *old* page or *new* one.
> 
> Right; but it must return one or the other, it can't segfault.

Good point, I missed that...

> 
>> I'd think this is up to the user process to handle that concurrency.
>> What needs to be guaranteed is that once mmap(MAP_FIXED) returns the old page
>> are no more there, which is done through the mmap_sem and PTE locking.
> 
> Yes, and allowing the fault handler to return the *old* page risks the
> old page being reinserted into the page tables after the unmapping task
> has done its work.

The PTE locking should prevent that.

> It's *really* rare to page-fault on a VMA which is in the middle of
> being replaced.  Why are you trying to optimise it?

I was not trying to optimize it, but to not wait in the page fault handler.
This could become tricky in the case the VMA is removed once mmap(MAP_FIXED) is
done and before the waiting page fault got woken up. This means that the
removed VMA structure will have to remain until all the waiters are woken up
which implies ref_count or similar.

> 
>>> I think I was wrong to describe VMAs as being *deleted*.  I think we
>>> instead need the concept of a *locked* VMA that page faults will block on.
>>> Conceptually, it's a per-VMA rwsem, but I'd use a completion instead of
>>> an rwsem since the only reason to write-lock the VMA is because it is
>>> being deleted.
>>
>> Such a lock would only makes sense in the case of mmap(MAP_FIXED) since when
>> the VMA is removed there is no need to wait. Isn't it ?
> 
> I can't think of another reason.  I suppose we could mark the VMA as
> locked-for-deletion or locked-for-replacement and have the SIGSEGV happen
> early.  But I'm not sure that optimising for SIGSEGVs is a worthwhile
> use of our time.  Just always have the pagefault sleep for a deleted VMA.
