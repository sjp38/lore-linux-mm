Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9156B7274
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 23:36:30 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so10384228pgv.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 20:36:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b11si18921692pfo.240.2018.12.04.20.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 20:36:29 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB54YuKP039049
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 23:36:28 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p64vynu6t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 23:36:28 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Dec 2018 04:36:27 -0000
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 5 Dec 2018 10:06:02 +0530
MIME-Version: 1.0
In-Reply-To: <20181204182421.GC2937@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <72f1141b-ffb5-71cb-8404-b55510b30267@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

On 12/4/18 11:54 PM, Jerome Glisse wrote:
> On Tue, Dec 04, 2018 at 09:06:59AM -0800, Andi Kleen wrote:
>> jglisse@redhat.com writes:
>>
>>> +
>>> +To help with forward compatibility each object as a version value and
>>> +it is mandatory for user space to only use target or initiator with
>>> +version supported by the user space. For instance if user space only
>>> +knows about what version 1 means and sees a target with version 2 then
>>> +the user space must ignore that target as if it does not exist.
>>
>> So once v2 is introduced all applications that only support v1 break.
>>
>> That seems very un-Linux and will break Linus' "do not break existing
>> applications" rule.
>>
>> The standard approach that if you add something incompatible is to
>> add new field, but keep the old ones.
> 
> No that's not how it is suppose to work. So let says it is 2018 and you
> have v1 memory (like your regular main DDR memory for instance) then it
> will always be expose a v1 memory.
> 
> Fast forward 2020 and you have this new type of memory that is not cache
> coherent and you want to expose this to userspace through HMS. What you
> do is a kernel patch that introduce the v2 type for target and define a
> set of new sysfs file to describe what v2 is. On this new computer you
> report your usual main memory as v1 and your new memory as v2.
> 
> So the application that only knew about v1 will keep using any v1 memory
> on your new platform but it will not use any of the new memory v2 which
> is what you want to happen. You do not have to break existing application
> while allowing to add new type of memory.
> 

So the knowledge that v1 is coherent and v2 is non-coherent is within 
the application? That seems really complicated from application point of 
view. Rill that v1 and v2 definition be arch and system dependent?

if we want to encode properties of a target and initiator we should do 
that as files within these directory. Something like 'is_cache_coherent'
in the target director can be used to identify whether the target is 
cache coherent or not?

-aneesh
