Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26D9A6B734D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:13:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x125so19080279qka.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:13:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m27si725239qta.366.2018.12.05.00.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 00:13:51 -0800 (PST)
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
 <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
 <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
 <CAPcyv4i=FL4f34H2_1mgWMk=UyyaXFaKPh5zJSnFNyN3cBoJhA@mail.gmail.com>
 <2a3f70b011b56de2289e2f304b3d2d617c5658fb.camel@linux.intel.com>
 <CAPcyv4hPDjHzKd4wTh8Ujv-xL8YsJpcFXOp5ocJ-5fVJZ3=vRw@mail.gmail.com>
 <30ab5fa569a6ede936d48c18e666bc6f718d50db.camel@linux.intel.com>
 <CAPcyv4izGr4dLs_Xpa1wbqJRrHZVEKFWQNb2Qo2Ej_xbEXhbTg@mail.gmail.com>
 <dd7296db5996f15cc3e666d008f209f5f24fa98e.camel@linux.intel.com>
 <20181204182428.11bec385@gnomeregan.cam.corp.google.com>
 <bb141157ac8bc4a99883800d757aa037a7402b10.camel@linux.intel.com>
 <CAPcyv4ix4aHyivwCiw0YNMxLjRJeqDX3x3m1q1JhyMPCEMOJtQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ee8cc068-903c-d87e-f418-ade46786249e@redhat.com>
Date: Wed, 5 Dec 2018 09:13:47 +0100
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ix4aHyivwCiw0YNMxLjRJeqDX3x3m1q1JhyMPCEMOJtQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, alexander.h.duyck@linux.intel.com
Cc: Barret Rhoden <brho@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 05.12.18 01:26, Dan Williams wrote:
> On Tue, Dec 4, 2018 at 4:01 PM Alexander Duyck
> <alexander.h.duyck@linux.intel.com> wrote:
>>
>> On Tue, 2018-12-04 at 18:24 -0500, Barret Rhoden wrote:
>>> Hi -
>>>
>>> On 2018-12-04 at 14:51 Alexander Duyck
>>> <alexander.h.duyck@linux.intel.com> wrote:
>>>
>>> [snip]
>>>
>>>>> I think the confusion arises from the fact that there are a few MMIO
>>>>> resources with a struct page and all the rest MMIO resources without.
>>>>> The problem comes from the coarse definition of pfn_valid(), it may
>>>>> return 'true' for things that are not System-RAM, because pfn_valid()
>>>>> may be something as simplistic as a single "address < X" check. Then
>>>>> PageReserved is a fallback to clarify the pfn_valid() result. The
>>>>> typical case is that MMIO space is not caught up in this linear map
>>>>> confusion. An MMIO address may or may not have an associated 'struct
>>>>> page' and in most cases it does not.
>>>>
>>>> Okay. I think I understand this somewhat now. So the page might be
>>>> physically there, but with the reserved bit it is not supposed to be
>>>> touched.
>>>>
>>>> My main concern with just dropping the bit is that we start seeing some
>>>> other uses that I was not certain what the impact would be. For example
>>>> the functions like kvm_set_pfn_accessed start going in and manipulating
>>>> things that I am not sure should be messed with for a DAX page.
>>>
>>> One thing regarding the accessed and dirty bits is that we might want
>>> to have DAX pages marked dirty/accessed, even if we can't LRU-reclaim
>>> or swap them.  I don't have a real example and I'm fairly ignorant
>>> about the specifics here.  But one possibility would be using the A/D
>>> bits to detect changes to a guest's memory for VM migration.  Maybe
>>> there would be issues with KSM too.
>>>
>>> Barret
>>
>> I get that, but the issue is that the code associated with those bits
>> currently assumes you are working with either an anonymous swap backed
>> page or a page cache page. We should really be updating that logic now,
>> and then enabling DAX to access it rather than trying to do things the
>> other way around which is how this feels.
> 
> Agree. I understand the concern about unintended side effects of
> dropping PageReserved for dax pages, but they simply don't fit the
> definition of the intended use of PageReserved. We've already had
> fallout from legacy code paths doing the wrong thing with dax pages
> where PageReserved wouldn't have helped. For example, see commit
> 6e2608dfd934 "xfs, dax: introduce xfs_dax_aops", or commit
> 6100e34b2526 "mm, memory_failure: Teach memory_failure() about
> dev_pagemap pages". So formerly teaching kvm about these page
> semantics and dropping the reliance on a side effect of PageReserved()
> seems the right direction.
> 
> That said, for mark_page_accessed(), it does not look like it will
> have any effect on dax pages. PageLRU will be false,
> __lru_cache_activate_page() will not find a page on a percpu pagevec,
> and workingset_activation() won't find an associated memcg. I would
> not be surprised if mark_page_accessed() is already being called today
> via the ext4 + dax use case.
> 

I agree to what Dan says here. I'd vote for getting rid of the
PageReserved bit for these pages and rather fixing the fallout from that
(if any, I also doubt that there will be much). One thing I already
mentioned in another thread is hindering hibernation code from touching
ZONE_DEVICE memory is one thing to take care of.

PageReserved as part of a user space process can mean many things (and I
still have a patch pending for submission to document that). It can mean
zero pages, VDSO pages, MMIO pages and right now DAX pages. For the
first three, we don't want to touch the struct page ever
(->PageReserved). For DAX it should not harm (-> no need for PageReserved).

-- 

Thanks,

David / dhildenb
