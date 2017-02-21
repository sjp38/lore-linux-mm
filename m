Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 182386B03A5
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:40:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v30so1479620wrc.4
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:40:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 198si16513622wml.100.2017.02.21.05.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 05:40:34 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LDXchV090652
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:40:33 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28rkfn0f79-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:40:33 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 21 Feb 2017 23:40:27 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6A2762CE8057
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:40:24 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1LDeG4w24903708
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:40:24 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1LDdpd7023052
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:39:52 +1100
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 21 Feb 2017 19:09:18 +0530
MIME-Version: 1.0
In-Reply-To: <20170221111107.GJ15595@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/21/2017 04:41 PM, Michal Hocko wrote:
> On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
> [...]
>> * User space using mbind() to get CDM memory is an additional benefit
>>   we get by making the CDM plug in as a node and be part of the buddy
>>   allocator. But the over all idea from the user space point of view
>>   is that the application can allocate any generic buffer and try to
>>   use the buffer either from the CPU side or from the device without
>>   knowing about where the buffer is really mapped physically. That
>>   gives a seamless and transparent view to the user space where CPU
>>   compute and possible device based compute can work together. This
>>   is not possible through a driver allocated buffer.
> 
> But how are you going to define any policy around that. Who is allowed

The user space VMA can define the policy with a mbind(MPOL_BIND) call
with CDM/CDMs in the nodemask.

> to allocate and how much of this "special memory". Is it possible that

Any user space application with mbind(MPOL_BIND) call with CDM/CDMs in
the nodemask can allocate from the CDM memory. "How much" gets controlled
by how we fault from CPU and the default behavior of the buddy allocator.

> we will eventually need some access control mechanism? If yes then mbind

No access control mechanism is needed. If an application wants to use
CDM memory by specifying in the mbind() it can. Nothing prevents it
from using the CDM memory.

> is really not suitable interface to (ab)use. Also what should happen if
> the mbind mentions only CDM memory and that is depleted?

IIUC *only CDM* cannot be requested from user space as there are no user
visible interface which can translate to __GFP_THISNODE. MPOL_BIND with
CDM in the nodemask will eventually pick a FALLBACK zonelist which will
have zones of the system including CDM ones. If the resultant CDM zones
run out of memory, we fail the allocation request as usual.

> 
> Could you also explain why the transparent view is really better than
> using a device specific mmap (aka CDM awareness)?

Okay with a transparent view, we can achieve a control flow of application
like the following.

(1) Allocate a buffer:		alloc_buffer(buf, size)
(2) CPU compute on buffer:	cpu_compute(buf, size)
(3) Device compute on buffer:	device_compute(buf, size)
(4) CPU compute on buffer:	cpu_compute(buf, size)
(5) Release the buffer:		release_buffer(buf, size)

With assistance from a device specific driver, the actual page mapping of
the buffer can change between system RAM and device memory depending on
which side is accessing at a given point. This will be achieved through
driver initiated migrations.

>  
>> * The placement of the memory on the buffer can happen on system memory
>>   when the CPU faults while accessing it. But a driver can manage the
>>   migration between system RAM and CDM memory once the buffer is being
>>   used from CPU and the device interchangeably. As you have mentioned
>>   driver will have more information about where which part of the buffer
>>   should be placed at any point of time and it can make it happen with
>>   migration. So both allocation and placement are decided by the driver
>>   during runtime. CDM provides the framework for this can kind device
>>   assisted compute and driver managed memory placements.
>>
>> * If any application is not using CDM memory for along time placed on
>>   its buffer and another application is forced to fallback on system
>>   RAM when it really wanted is CDM, the driver can detect these kind
>>   of situations through memory access patterns on the device HW and
>>   take necessary migration decisions.
> 
> Is this implemented or at least designed?

Yeah, its being designed.

> 
> Btw. I believe that sending new versions of the patchset with minor
> changes is not really helping the review process. I believe the
> highlevel concerns about the API are not resolved yet and that is the
> number 1 thing to deal with currently.

Got it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
