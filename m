Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 224C06B0003
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 02:19:05 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l6so6005961qtj.0
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 23:19:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 131si900609qkh.482.2018.01.27.23.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jan 2018 23:19:03 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0S7J1oG082640
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 02:19:02 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fs7x8jt77-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 02:19:02 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 28 Jan 2018 07:18:56 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [LSF/MM TOPIC] Rethinking NUMA
Date: Sun, 28 Jan 2018 12:48:48 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <1358d17c-f126-6a8a-df48-cda9e90b7c13@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>

In last couple of years, after going through various patch series
related to HMM, HMM-CDM, NUMA CDM, ACPI HMAT representation in sysfs
etc,it is the right time to take a closer look at existing NUMA
representation and how it can evolve in the long term to accommodate
coherent memory with multiple attributes. There are various possible
directions which need to be discussed, evaluated and try build a
consensus among all stakeholders in the community. This is an attempt
to kick start that discussion around the topic.

People:

Mel Gorman <mgorman@suse.de>
Michal Hocko <mhocko@kernel.org>
Vlastimil Babka <vbabka@suse.cz>
Jerome Glisse <jglisse@redhat.com>
John Hubbard <jhubbard@nvidia.com>
Dave Hansen <dave.hansen@intel.com>
Ross Zwisler <ross.zwisler@linux.intel.com>

Process Address Space Evolution
===============================

Different attribute based memory mapped into the process address space
will give new capabilities and opportunities which were never possible
before.

1. Explore new programming and problem solving capabilities
2. Save energy with big working set which is resident longer but
   accessed rarely
3. Optimal placement of data structures depending upon various user
   space requirements like access speed (latency or bandwidth) and
   residency time span etc

With advent of new attribute based memory this is inevitable in the
long run.

Mapping Attribute Memory Into Process Address Space
===================================================

Attribute memory can be mapped into any process address space through
it's page table in two distinct ways with their own advantages and
disadvantages.

1. Device Driver

a. Driver is required, kernel is not aware about it's presence at all
b. Driver manages allocation/free into attribute memory not the kernel
c. Driver loading and initialization of attribute memory is required
d. User specifies the required attributes through ioctl flags
e. Lower level of integration into MM, hence less features available
	
2. Core MM system calls

a. No driver is required, its integrated into kernel
b. Kernel manages allocation/free for the attribute memory
c. Driver loading and initialization is not required
d. User specifies the attributes through system call flags
e. Higher integration into MM, hence more features applicable

	
A. Driver IOCTL Mapping
=======================

If we are going in this direction where device driver manages everything

1. Nothing else needs to be done in kernel

2. Moreover HMM and HMM-CDM solutions provides more functionality like
   migration etc along with better integration with core MM through
   ZONE_DEVICE

Why this is not a long term solution

1. Passing over different attribute memory representation to drivers

2. Kernel relinquishing it's responsibilities to device drivers

3. Multiple attribute memory provided by multiple device vendors will
   have their own drivers and the user space will have to deal with all
   these drivers to get different memory which is neither optimal nor
   elegant
   
4. Interoperability between these memory or with system RAM like
   migration will be complicated as all of drivers need to export
   supporting functions

5. HMM, HMM-CDM or any traditional driver based solutions had a bit
   complication because there was a need to have a device driver which
   sometimes was a closed source one to manage the device itself. So the
   proposition that driver should also take care of the memory as well
   was somewhat logical and justified

But going forward when these devices will be managed by open source
drivers and their memory available for representation in the kernel
then that argument just goes away. Like any other memory, kernel will
have to represent this attribute memory and can no longer hand over
the responsibility to device drivers.

B. MM System Calls 
==================

B.1 Attribute Memory as distinct NUMA nodes:
--------------------------------------------

User space can access any attribute memory with simply doing mbind
(MPOL_BIND...) after identifying the right node. There will be sysfs
interface which will help. The view of memory attributes will be two
dimensional. Each broadly will have these kind of attribute values.
Accuracy and completeness of this list can be debated later and
agreed upon.

1. Bandwidth
2. Latency
3. Reliability
4. Power
5. Density

More over these attributes can be 'as seen from' different compute
nodes having CPUs. This will require a two dimensional structure of
attribute values to be exported for user space. IIUC, HMAT export
because of the new ACPI standard was one such attempt.

https://lkml.org/lkml/2017/12/13/968

But lack of clarity on the directions of NUMA will prevent us from
deliberating on how the use interface for attributes should look like
going forward.

Distinct NUMA representation can be achieved with or without changing
the core MM.

B.1.1 Without changing core MM

Just plug the attribute memory as a distinct NUMA node with
ZONE_MOVEABLE (just to prevent kernel allocations into it) with a
higher NUMA distance reducing the chances of implicit allocation leaks
into it. This is the simplest solution in the category when attribute
memory needs to be represented as NUMA nodes. But it has a single
fundamental drawback.

* Allocation leaks which can not be prevented with just high NUMA
  distance

All other complexities like memory fallback options can be handled in
the user space. But if the attribute values are 'as seen' basis, then
user space needs to rebind appropriately as and when the tasks move
around the system which might be overwhelming.

B.1.2 With changing core MM

Representing attribute memory as NUMA nodes but with some changes in the
core MM will have the following benefits.

1. There wont be implicit memory leaks into the attribute memory
2. Allocation fallback options can be handled precisely in the kernel
3. Enforcement of the memory policy in kernel even when the tasks move
   around

CDM implementation last year demonstrated by changing zonelist creation
how the implicit allocation leaks into the device memory can be
prevented.

https://lkml.org/lkml/2017/2/15/224

B.2 Attribute Memory Inside Existing NUMA nodes:
------------------------------------------------

Some attribute memory might be connected directly to the compute nodes
lacking their own NUMA distance. Separate NUMA node representation will
not make sense in those situations. Even otherwise, these attribute
memory can be represented in the the compute nodes having CPU. NUMA
view of the buddy allocator needs to contains all of these memory now
either as

1. Separate zones for attribute memory
2. Separate MIGRATE_TYPE page blocks for attribute memory
3. Separate free_area[] for attribute memory

One such very high level proposal can be found here which changes
in free_area[] to accommodate attribute memory.

http://linuxplumbersconf.org/2017/ocw//system/presentations/4656/original/Hierarchical_NUMA_Design_Plumbers_2017.pdf

Any of these changes as stated above will require significant changes
to core MM. Also there are draw backs with these kind of representations
as well.

1. In absence of node info, struct page will lack identity as attribute
   memory

2. struct page will need a single bit specifying it as a attribute
   memory though specific differentiation can be handled once this bit
   is set

3. User cannot specify attribute memory through mbind(MPOL_BIND...)
   any more. It will need new flags with madvise() or new system calls
   altogether
   
But these changes will also have the following benefits (similar to
method B.1.2 With changing core MM)

1. There wont be implicit memory leaks into the attribute memory
2. Allocation fallback options can be handled precisely in the kernel
3. Enforcement of the memory policy in kernel even when the tasks move
   around

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
