Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC61831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:04:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so47227542pgc.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:04:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l16si2624701pfi.295.2017.03.08.01.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 01:04:18 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2893d4H044746
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 04:04:17 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292dfekguk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:04:17 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Mar 2017 14:34:13 +0530
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2894Cub29556940
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 14:34:12 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2894BAM010984
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 14:34:12 +0530
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
 <20170217093159.3t5kw7rmixrzvv7c@suse.de>
 <1487645879.10535.11.camel@gmail.com>
 <a0271d52-c60c-782a-5d0d-33c1d6d5508b@gmail.com>
 <20170301095546.GB4359@suse.de>
 <CAKTCnzm+nyAaNMmPgKQVNtxdbTLoarnGtebT=MfsZaSq8Umw0w@mail.gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 8 Mar 2017 14:34:05 +0530
MIME-Version: 1.0
In-Reply-To: <CAKTCnzm+nyAaNMmPgKQVNtxdbTLoarnGtebT=MfsZaSq8Umw0w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Mel Gorman <mgorman@suse.de>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, haren@linux.vnet.ibm.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On 03/01/2017 04:29 PM, Balbir Singh wrote:
> On Wed, Mar 1, 2017 at 8:55 PM, Mel Gorman <mgorman@suse.de> wrote:
>> On Wed, Mar 01, 2017 at 01:42:40PM +1100, Balbir Singh wrote:
>>>>>> The idea of this patchset was to introduce
>>>>>> the concept of memory that is not necessarily system memory, but is coherent
>>>>>> in terms of visibility/access with some restrictions
>>>>>>
>>>>> Which should be done without special casing the page allocator, cpusets and
>>>>> special casing how cpusets are handled. It's not necessary for any other
>>>>> mechanism used to restrict access to portions of memory such as cpusets,
>>>>> mempolicies or even memblock reservations.
>>>> Agreed, I mentioned a limitation that we see a cpusets. I do agree that
>>>> we should reuse any infrastructure we have, but cpusets are more static
>>>> in nature and inheritence compared to the requirements of CDM.
>>>>
>>> Mel, I went back and looked at cpusets and found some limitations that
>>> I mentioned earlier, isolating a particular node requires some amount
>>> of laborious work in terms of isolating all tasks away from the root cpuset
>>> and then creating a hierarchy where the root cpuset is empty and now
>>> belong to a child cpuset that has everything but the node we intend to
>>> ioslate. Even with hardwalling, it does not prevent allocations from
>>> the parent cpuset.
>>>
>> That it is difficult does not in itself justify adding a third mechanism
>> specific to one type of device for controlling access to memory.
>>
> Not only is it difficult, but there are several tasks that refuse to
> change cpusets once created. I also noticed that the isolation may
> begin a little too late, some allocations may end up on the node to
> isolate.
> 
> I also want to eventually control whether auto-numa
> balancing/kswapd/reclaim etc run on this node (something that cpusets
> do not provide). The reason for these decisions is very dependent on
> the properties of the node. The isolation mechanism that exists today
> is insufficient. Moreover the correct abstraction for device memory
> would be a class similar to N_MEMORY, but limited in what we include
> (which is why I was asking if questions 3 and 4 are clear). You might
> argue these are not NUMA nodes then, but these are in general sense
> NUMA nodes (with non-uniform properties and access times). NUMA allows
> with the right hardware expose the right programming model. Please
> consider reading the full details at
> 
> https://patchwork.kernel.org/patch/9566393/
> https://lkml.org/lkml/2016/11/22/339

As explained by Balbir, right now cpuset mechanism gives only isolation
and is insufficient for creating other properties required for full
fledged CDM representation. NUMA representation is the close match for
CDM memory which represents non uniform attributes instead of distance
as the only differentiating property. Once represented as a NUMA node
in the kernel, we can achieve the isolation requirement either through
buddy allocator changes as proposed in this series or can look into
some alternative approaches as well. As I had mentioned in the last
RFC there is another way to achieve isolation through zonelist rebuild
process changes and mbind() implementation changes. Please find those
two relevant commits here.

https://github.com/akhandual/linux/commit/da1093599db29c31d12422a34d4e0cbf4683618f
https://github.com/akhandual/linux/commit/faadab4e9dc9685ab7a564a84d4a06bde8fc79d8

Will post these commits on this thread for further discussion. Do let
me know your views and suggestions on this approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
