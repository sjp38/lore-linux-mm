Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFE036B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 21:43:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so38723543pgc.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 18:43:11 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id q5si3349527pfk.67.2017.02.28.18.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 18:43:10 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x17so3994626pgi.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 18:43:10 -0800 (PST)
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
 <20170217093159.3t5kw7rmixrzvv7c@suse.de>
 <1487645879.10535.11.camel@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <a0271d52-c60c-782a-5d0d-33c1d6d5508b@gmail.com>
Date: Wed, 1 Mar 2017 13:42:40 +1100
MIME-Version: 1.0
In-Reply-To: <1487645879.10535.11.camel@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

>>> The idea of this patchset was to introduce
>>> the concept of memory that is not necessarily system memory, but is coherent
>>> in terms of visibility/access with some restrictions
>>>
>>
>> Which should be done without special casing the page allocator, cpusets and
>> special casing how cpusets are handled. It's not necessary for any other
>> mechanism used to restrict access to portions of memory such as cpusets,
>> mempolicies or even memblock reservations.
>
> Agreed, I mentioned a limitation that we see a cpusets. I do agree that
> we should reuse any infrastructure we have, but cpusets are more static
> in nature and inheritence compared to the requirements of CDM.
>

Mel, I went back and looked at cpusets and found some limitations that
I mentioned earlier, isolating a particular node requires some amount
of laborious work in terms of isolating all tasks away from the root cpuset
and then creating a hierarchy where the root cpuset is empty and now
belong to a child cpuset that has everything but the node we intend to
ioslate. Even with hardwalling, it does not prevent allocations from
the parent cpuset.

I am trying to understand the concerns that you/Michal/Vlastimil have
so that Anshuman/I/other stake holders can respond to the concerns
in one place if that makes sense. Here are the concerns I have heard
so far

1. Lets not add any overhead to the page allocator path
2. Lets try and keep the allocator changes easy to read/parse
3. Why do we need a NUMA interface?
4. How does this compare with HMM?
5. Why can't we use cpusets?

Would that be a fair set of concerns to address?

@Anshuman/@Srikar/@Aneesh anything else you'd like to add in terms
of concerns/issues? I think it will also make a good discussion thread
for those attending LSF/MM (I am not there) on this topic.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
