Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D3F8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 23:09:14 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id v62-v6so2736520ota.11
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 20:09:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p55-v6si1137918ote.317.2018.09.13.20.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 20:09:13 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8E344kW111588
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 23:09:12 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mfxa1mu6c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 23:09:12 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 13 Sep 2018 21:09:11 -0600
Subject: Re: [Bug 201085] New: Kernel allows mlock() on pages in CMA without
 migrating pages out of CMA first
References: <bug-201085-27@https.bugzilla.kernel.org/>
 <20180912124727.fccccf432d2d8163ead79288@linux-foundation.org>
 <6d38e089-6df4-ead7-4a9d-7277a2db5d7c@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 14 Sep 2018 08:39:01 +0530
MIME-Version: 1.0
In-Reply-To: <6d38e089-6df4-ead7-4a9d-7277a2db5d7c@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e04af13c-7237-c430-032b-29c4ebb4058a@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, tpearson@raptorengineering.com

On 9/13/18 3:49 AM, Mike Kravetz wrote:
> On 09/12/2018 12:47 PM, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Tue, 11 Sep 2018 03:59:11 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=201085
>>>
>>>              Bug ID: 201085
>>>             Summary: Kernel allows mlock() on pages in CMA without
>>>                      migrating pages out of CMA first
>>>             Product: Memory Management
>>>             Version: 2.5
>>>      Kernel Version: 4.18
>>>            Hardware: All
>>>                  OS: Linux
>>>                Tree: Mainline
>>>              Status: NEW
>>>            Severity: normal
>>>            Priority: P1
>>>           Component: Page Allocator
>>>            Assignee: akpm@linux-foundation.org
>>>            Reporter: tpearson@raptorengineering.com
>>>          Regression: No
>>>
>>> Pages allocated in CMA are not migrated out of CMA when non-CMA memory is
>>> available and locking is attempted via mlock().  This can result in rapid
>>> exhaustion of the CMA pool if memory locking is used by an application with
>>> large memory requirements such as QEMU.
>>>
>>> To reproduce, on a dual-CPU (NUMA) POWER9 host try to launch a VM with mlock=on
>>> and 1/2 or more of physical memory allocated to the guest.  Observe full CMA
>>> pool depletion occurs despite plenty of normal free RAM available.
>>>
>>> -- 
>>> You are receiving this mail because:
>>> You are the assignee for the bug.
> 
> IIRC, Aneesh is working on some powerpc IOMMU patches for a similar issue
> (long term pinning of cma pages).  Added him on Cc:
> https://lkml.kernel.org/r/20180906054342.25094-2-aneesh.kumar@linux.ibm.com
> 
> This report seems to be suggesting a more general solution/change.  Wondering
> if there is any overlap with this and Aneesh's work.
> 

This is a related issue. I am looking at doing something similar to what 
I did with IOMMU patches. That is migrate pages out of CMA region bfore 
mlock.

The problem mentioned is similar to vfio. With VFIO we do pin the guest 
pages and that is similar with -realtime mlock=on option of Qemu.

We can endup backing guest RAM with pages from CMA area and these are 
different qemu options that do pin these guest pages for the lifetime of 
the guest.

-aneesh
