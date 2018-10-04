Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEA56B000C
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:48:01 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id n8-v6so5769536ybo.9
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:48:01 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l9-v6si1345553ybo.350.2018.10.04.14.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 14:48:00 -0700 (PDT)
Subject: Re: [PATCH] mm: madvise(MADV_DODUMP) allow hugetlbfs pages
References: <20180930054629.29150-1-daniel@linux.ibm.com>
 <ecbe3fad-4ab7-6549-bafb-5f24ccc36e74@oracle.com>
 <20181003074520.460bbf17@volution>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <75dbe72a-c78f-8f99-091a-8d7cd9a1e2f8@oracle.com>
Date: Thu, 4 Oct 2018 14:47:54 -0700
MIME-Version: 1.0
In-Reply-To: <20181003074520.460bbf17@volution>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Black <daniel@linux.ibm.com>
Cc: linux-mm@kvack.org, khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>

On 10/2/18 10:47 PM, Daniel Black wrote:
> On Mon, 1 Oct 2018 15:11:32 -0700
> Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> On 9/29/18 10:46 PM, Daniel Black wrote:
>> <snip>
>> > diff --git a/mm/madvise.c b/mm/madvise.c
>> > index 972a9eaa898b..71d21df2a3f3 100644
>> > --- a/mm/madvise.c
>> > +++ b/mm/madvise.c
>> > @@ -96,7 +96,7 @@ static long madvise_behavior(struct
>> > vm_area_struct *vma, new_flags |= VM_DONTDUMP;
>> >          break;
>> >      case MADV_DODUMP:
>> > -        if (new_flags & VM_SPECIAL) {
>> > +        if (!is_vm_hugetlb_page(vma) && new_flags &
>> > VM_SPECIAL) {
>>
>> Thanks Daniel,
>>
>> This is certainly a regression.  My only question is whether this
>> condition should be more specific and test the default hugetlb vma
>> flags (VM_DONTEXPAND | VM_HUGETLB).
> 
>>  Or, whether simply checking
>> VM_HUGETLB as you have done above is sufficient.
> 
> The is_vm_hugetlb_page() function seems widely used elsewhere for that
> single purpose.
> 
>> Only reason for
>> concern is that I am not 100% certain other VM_SPECIAL flags could
>> not be set in VM_HUGETLB vma.
> 
> They might be, but being a VM_HUGETLB flag is the main criteria for
> being able to madvise(DODUMP) on the memory. It highlight its user
> memory for the user to do as they wish.
> 
> When 314e51b9851b was added, it seemed the direction was to kill of the
> VM_RESERVED, now a few years later VM_SPECIAL seems to be replacing
> this. I think it would be better to preserve the original goal and
> keep flags having a single meaning.
> 
> The purpose in 0103bd16fb90 as I surmise it, is that VM_IO | VM_PFNMAP
> | VM_MIXEDMAP are the true things that want to be prevented from having
> madvise(DO_DUMP) on them, based on frequent use of DONT_DUMP with those
> memory pages. Was VM_DONTEXPAND an intentional inclusion there it did it
> just get included with VM_SPECIAL?
> 
> Either way, I've tried to keep to the principles of the
> is_vm_hugetlb_page function being the authoritative source of a HUGETLB
> page.
> 
>> Perhaps Konstantin has an opinion as he did a bunch of the vm_flag
>> reorg.
>>
> 
> Thanks for the review.
> 

Thanks for the explanation.  I was thinking of the case where hugetlb pages
could be used for RDMA, and wanted to make sure those drivers were not doing
anything to vm_flags.  A quick look reveals nothing special happening.

You can add,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Adding Andrew on Cc:
-- 
Mike Kravetz
