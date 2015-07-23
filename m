Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4299003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:30:26 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so177799467qkd.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:30:26 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h33si6714762qgh.17.2015.07.23.10.30.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 10:30:25 -0700 (PDT)
Message-ID: <55B1246A.9010905@oracle.com>
Date: Thu, 23 Jul 2015 10:29:14 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com> <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org> <1437603594.3298.5.camel@stgolabs.net> <20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org> <55B024C6.8010504@oracle.com> <20150723151707.GB7795@akamai.com> <55B11EEF.1070605@oracle.com> <20150723171728.GC9203@akamai.com>
In-Reply-To: <20150723171728.GC9203@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>, emunson@mgebm.net

On 07/23/2015 10:17 AM, Eric B Munson wrote:
> On Thu, 23 Jul 2015, Mike Kravetz wrote:
>
>> On 07/23/2015 08:17 AM, Eric B Munson wrote:
>>> On Wed, 22 Jul 2015, Mike Kravetz wrote:
>>>
>>>> On 07/22/2015 03:30 PM, Andrew Morton wrote:
>>>>> On Wed, 22 Jul 2015 15:19:54 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:
>>>>>
>>>>>>>
>>>>>>> I didn't know that libhugetlbfs has tests.  I wonder if that makes
>>>>>>> tools/testing/selftests/vm's hugetlbfstest harmful?
>>>>>>
>>>>>> Why harmful? Redundant, maybe(?).
>>>>>
>>>>> The presence of the in-kernel tests will cause people to add stuff to
>>>>> them when it would be better if they were to apply that effort to
>>>>> making libhugetlbfs better.  Or vice versa.
>>>>>
>>>>> Mike's work is an example.  Someone later makes a change to hugetlbfs, runs
>>>>> the kernel selftest and says "yay, everything works", unaware that they
>>>>> just broke fallocate support.
>>>>>
>>>>>> Does anyone even use selftests for
>>>>>> hugetlbfs regression testing? Lets see, we also have these:
>>>>>>
>>>>>> - hugepage-{mmap,shm}.c
>>>>>> - map_hugetlb.c
>>>>>>
>>>>>> There's probably a lot of room for improvement here.
>>>>>
>>>>> selftests is a pretty scrappy place.  It's partly a dumping ground for
>>>>> things so useful test code doesn't just get lost and bitrotted.  Partly
>>>>> a framework so people who add features can easily test them. Partly to
>>>>> provide tools to architecture maintainers when they wire up new
>>>>> syscalls and the like.
>>>>>
>>>>> Unless there's some good reason to retain the hugetlb part of
>>>>> selftests, I'm thinking we should just remove it to avoid
>>>>> distracting/misleading people.  Or possibly move the libhugetlbfs test
>>>>> code into the kernel tree and maintain it there.
>>>>
>>>> Adding Eric as he is the libhugetlbfs maintainer.
>>>>
>>>> I think removing the hugetlb selftests in the kernel and pointing
>>>> people to libhugetlbfs is the way to go.  From a very quick scan
>>>> of the selftests, I would guess libhugetlbfs covers everything
>>>> in those tests.
>>>>
>>>> I'm willing to verify the testing provided by selftests is included
>>>> in libhugetlbfs, and remove selftests if that is the direction we
>>>> want to take.
>>>
>>> I would rather see the test suite stay in the library, there are a
>>> number of tests that rely on infrastructure in the library that is not
>>> available in selftests.
>>>
>>> I am happy to help with any tests that need to be added/modified in the
>>> library to cover.
>>
>> I thought about this some more and think there are two distinct
>> groups of users that should be considered.
>> 1) Application developers who simply want to use hugetlb
>> 2) Kernel developers who are modifying hugetlb related code
>>
>> The application developers will mostly want information in the
>> man pages, hugetlbpage.txt and hugetlb selftest programs to use
>> as sample code to get started.  They can also use libhugetlbfs
>> man pages/library if they desire.  Because of this, I do not
>> really want to remove the hugetlb selftest programs.  There are
>> no equivalent simple stand alone programs in libhugetlbfs.
>>
>> Kernel developers would be more concerned about introducing
>> regressions.  The selftest programs are of limited use for this
>> purpose.  The libhugetlbfs test suite is much more suited for
>> regression testing.
>>
>> With this in mind, I suggest:
>> - Keep the mmap man page reference to Documentation/vm/hugetlbpage.txt
>> - Small modification to hugetlbpage.txt saying the selftest code is
>>    good for application development examples.  And, kernel developers
>>    should use libhugetlbfs test suite for regression testing.  In any
>>    case, the sourceforge URL for libhugetlbfs is no longer valid and
>>    needs to be updated.
>> - Modify the run_vmtests selftest script to print out a message saying
>>    libhugetlbfs should be used for hugetlb regression testing.  This
>>    would help catch people who might think the few selftests are
>>    sufficient.
>>
>> Thoughts?
>
> There are a number of tests in the libhugetlbfs suite that cover kernel
> problems, are you suggesting that we move all these tests out of
> libhugetlbfs and into selftests?  I don't think we should separate the
> responsibility for testing kernel regressions so where ever they end up,
> they should all be together.  The libhugetlbfs suite has some nice
> features for setting up the test environment (consider that a plug to
> move tests in that direction).

No, not suggesting we move anything out of libhugetlbfs.  I believe
that should be the primary test suite for hugetlb.

However, the few programs in selftest do provide some value IMO.
They are examples of hugetlb usage without any of the libhugetlbfs
infrastructure present.  Ideally, there would be some place to put
this sample code.  I can not think of an ideal location.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
