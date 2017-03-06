Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 111956B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 00:48:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so58977056pgc.5
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 21:48:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n129si18031239pga.28.2017.03.05.21.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 21:48:42 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v265mcMs126918
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 00:48:41 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28ytm4d74f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Mar 2017 00:48:41 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 6 Mar 2017 11:18:31 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8ADC5E0040
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:20:18 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v265lLaF10616940
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 11:17:21 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v265mS2r026377
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 11:18:29 +0530
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
 <20170222092921.GF5753@dhcp22.suse.cz> <20170222145915.GA4852@redhat.com>
 <20170222165424.GA26472@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 6 Mar 2017 11:18:23 +0530
MIME-Version: 1.0
In-Reply-To: <20170222165424.GA26472@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6eeaddd6-9035-3728-fec8-d34e45e6ddf1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jerome Glisse <jglisse@redhat.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/22/2017 10:24 PM, Michal Hocko wrote:
> On Wed 22-02-17 09:59:15, Jerome Glisse wrote:
>> On Wed, Feb 22, 2017 at 10:29:21AM +0100, Michal Hocko wrote:
>>> On Tue 21-02-17 18:39:17, Anshuman Khandual wrote:
>>>> On 02/17/2017 07:02 PM, Mel Gorman wrote:
>>
>> [...]
>>
>>> [...]
>>>> These are the reasons which prohibit the use of HMM for coherent
>>>> addressable device memory purpose.
>>>>
>>> [...]
>>>> (3) Application cannot directly allocate into device memory from user
>>>> space using existing memory related system calls like mmap() and mbind()
>>>> as the device memory hides away in ZONE_DEVICE.
>>>
>>> Why cannot the application simply use mmap on the device file?
>>
>> This has been said before but we want to share the address space this do
>> imply that you can not rely on special allocator. For instance you can
>> have an application that use a library and the library use the GPU but
>> the application is un-aware and those any data provided by the application
>> to the library will come from generic malloc (mmap anonymous or from
>> regular file).
>>
>> Currently what happens is that the library reallocate memory through
>> special allocator and copy thing. Not only does this waste memory (the
>> new memory is often regular memory too) but you also have to paid the
>> cost of copying GB of data.
>>
>> Last bullet to this, is complex data structure (list, tree, ...) having
>> to go through special allocator means you have re-build the whole structure
>> with the duplicated memory.
>>
>>
>> Allowing to directly use memory allocated from malloc (mmap anonymous
>> private or from a regular file) avoid the copy operation and the complex
>> duplication of data structure. Moving the dataset to the GPU is then a
>> simple memory migration from kernel point of view.
>>
>> This is share address space without special allocator is mandatory in new
>> or future standard such as OpenCL, Cuda, C++, OpenMP, ... some other OS
>> already have this and the industry want it. So the questions is do we
>> want to support any of this, do we care about GPGPU ?
>>
>>
>> I believe we want to support all this new standard but maybe i am the
>> only one.
>>
>> In HMM case i have the extra painfull fact that the device memory is
>> not accessible by the CPU. For CDM on contrary, CPU can access in a
>> cache coherent way the device memory and all operation behave as regular
>> memory (thing like atomic operation for instance).
>>
>>
>> I hope this clearly explain why we can no longer rely on dedicated/
>> specialized memory allocator.
> 
> Yes this clarifies this point. Thanks for the information which would be
> really helpful in the initial description. Maybe I've just missed it,
> though.

Sure, will add this into the patch description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
