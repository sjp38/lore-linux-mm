Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15D5B6B03DB
	for <linux-mm@kvack.org>; Mon,  8 May 2017 18:11:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o12so66725239iod.15
        for <linux-mm@kvack.org>; Mon, 08 May 2017 15:11:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 62si20272441iog.240.2017.05.08.15.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 15:11:24 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
Date: Mon, 8 May 2017 15:12:42 -0700
MIME-Version: 1.0
In-Reply-To: <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 05/08/2017 08:58 AM, Dave Hansen wrote:
>
> It depends on how you define the feature.  I think you have three choices:
>
> 1. "Error" on page fault.  Require all access to be pre-faulted.
> 2. Allow faults, but "Error" if page cache has to be allocated
> 3. Allow faults and page cache allocations, but error on filesystem
>     backing storage allocation.
>
> All of those are useful in some cases.  But the implementations probably
> happen in different places:
>
> #1 can be implemented in core mm code
> #2 can be implemented in the VFS
> #3 needs filesystem involvement


Sure it will depend on how we define the feature.
However, I am not clear about how useful are #1 & #2
as a general feature with respect to filesystems, but I
assume we could find some use cases for them.

Regarding #3 as a general feature, do we want to
consider this and the complexity associated with the
implementation?


>
>> In case of hugetlbfs it is much straight forward. Since this
>> filesystem is not like a normal filesystems and and the file sizes
>> are multiple of huge pages. The hole will be a multiple of the huge
>> page size. For this reason then should the advise be specific to
>> hugetlbfs?
> Let me paraphrase: it's simpler to implement it if it's specific to
> hugetlbfs, thus we should implement it only for hugetlbfs, and keep it
> specific to hugetlbfs.
>
> The bigger question is: do we want to continue adding to the complexity
> of hugetlbfs and increase its divergence from the core mm?

Ok,

The purpose of hugetlbfs is to enable applications to be
able to use memory in huge page sizes. Expecting that there
will be no change to its purpose other then this. The filesystem
API fallocate(), with the recent addition for hole punching support
to free pages, allows  explicit control on page
allocation  / deallocation which is useful.

It seems that the 'noautofill' feature is what is missing, with
regards to applications having explicit control on memory page
allocations using hugetlbfs. Even though the description for this
feature is not to fill holes in files, given it is filesystem semantic, but
actually the intent is to indicate not allocating pages implicitly as
the application is primarily dealing with memory allocation and
deallocation here. Is this a good enough justification?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
