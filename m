Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D94C66B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 05:59:24 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 73so15502628wrb.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 02:59:24 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id w185si6500852wmf.134.2017.03.01.02.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 02:59:22 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id v77so6661449wmv.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 02:59:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170301095546.GB4359@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de> <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
 <20170217093159.3t5kw7rmixrzvv7c@suse.de> <1487645879.10535.11.camel@gmail.com>
 <a0271d52-c60c-782a-5d0d-33c1d6d5508b@gmail.com> <20170301095546.GB4359@suse.de>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 1 Mar 2017 21:59:21 +1100
Message-ID: <CAKTCnzm+nyAaNMmPgKQVNtxdbTLoarnGtebT=MfsZaSq8Umw0w@mail.gmail.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, haren@linux.vnet.ibm.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Mar 1, 2017 at 8:55 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Mar 01, 2017 at 01:42:40PM +1100, Balbir Singh wrote:
>> >>>The idea of this patchset was to introduce
>> >>>the concept of memory that is not necessarily system memory, but is coherent
>> >>>in terms of visibility/access with some restrictions
>> >>>
>> >>
>> >>Which should be done without special casing the page allocator, cpusets and
>> >>special casing how cpusets are handled. It's not necessary for any other
>> >>mechanism used to restrict access to portions of memory such as cpusets,
>> >>mempolicies or even memblock reservations.
>> >
>> >Agreed, I mentioned a limitation that we see a cpusets. I do agree that
>> >we should reuse any infrastructure we have, but cpusets are more static
>> >in nature and inheritence compared to the requirements of CDM.
>> >
>>
>> Mel, I went back and looked at cpusets and found some limitations that
>> I mentioned earlier, isolating a particular node requires some amount
>> of laborious work in terms of isolating all tasks away from the root cpuset
>> and then creating a hierarchy where the root cpuset is empty and now
>> belong to a child cpuset that has everything but the node we intend to
>> ioslate. Even with hardwalling, it does not prevent allocations from
>> the parent cpuset.
>>
>
> That it is difficult does not in itself justify adding a third mechanism
> specific to one type of device for controlling access to memory.
>

Not only is it difficult, but there are several tasks that refuse to
change cpusets once created. I also noticed that the isolation may
begin a little too late, some allocations may end up on the node to
isolate.

I also want to eventually control whether auto-numa
balancing/kswapd/reclaim etc run on this node (something that cpusets
do not provide). The reason for these decisions is very dependent on
the properties of the node. The isolation mechanism that exists today
is insufficient. Moreover the correct abstraction for device memory
would be a class similar to N_MEMORY, but limited in what we include
(which is why I was asking if questions 3 and 4 are clear). You might
argue these are not NUMA nodes then, but these are in general sense
NUMA nodes (with non-uniform properties and access times). NUMA allows
with the right hardware expose the right programming model. Please
consider reading the full details at

https://patchwork.kernel.org/patch/9566393/
https://lkml.org/lkml/2016/11/22/339

cpusets are designed for slabs/kernel allocation and user mem
policies, we need more control for things like the ones I mentioned
above. We would definitely work with the existing framework so that we
don't duplicate code or add more complexity

>> I am trying to understand the concerns that you/Michal/Vlastimil have
>> so that Anshuman/I/other stake holders can respond to the concerns
>> in one place if that makes sense. Here are the concerns I have heard
>> so far
>>
>> 1. Lets not add any overhead to the page allocator path
>
> Yes and that includes both runtime overhead and maintenance overhead.
> Littering the allocator paths with special casing with runtime overhead
> masked by static branches would still be a maintenance burden given that
> most people will not have the hardware necessary to avoid regressions.
>

I understand that, we'll try and keep the allocator changes to 0 and
where possible reuse cpusets, after all my experiments cpusets comes
out short on some counts, cpusets uses nodes, but does not represent
node characteristics and work the way N_MEMORY works

>> 2. Lets try and keep the allocator changes easy to read/parse
>
> No, simply do not add a new mechanism for controllin access to memory
> when cpusets and memory policies already exist.
>

Same as above

>> 3. Why do we need a NUMA interface?
>> 4. How does this compare with HMM?
>
> Others discussed this topic in detail.
>
>> 5. Why can't we use cpusets?
>>
>
> That is your assertion. The concerns you have are that the work is
> laborious and that designing the administrative interfaces may be
> difficult. In itself that does not justify adding a third mechanism for
> controlling memory acecss.

Laborious and insufficient as stated above unless we make changes to
the way cpusets work.

Thanks for the feedback,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
