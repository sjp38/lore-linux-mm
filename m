Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC5B96B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:38:04 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g49so21587105qta.8
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:38:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f17si7852140qki.464.2017.12.22.06.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 06:38:03 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBMEaRtO001498
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:38:02 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f11xh78wp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:38:02 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 22 Dec 2017 14:37:58 -0000
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
 <34EF90DF7C7F0647A403B771519912C7F5382CF3@irsmsx111.ger.corp.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 22 Dec 2017 20:07:31 +0530
MIME-Version: 1.0
In-Reply-To: <34EF90DF7C7F0647A403B771519912C7F5382CF3@irsmsx111.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c3930c61-0fe4-960e-2b55-dbd281dfb148@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, "devel@acpica.org" <devel@acpica.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On 12/22/2017 04:01 PM, Kogut, Jaroslaw wrote:
>> ... first thinking about redesigning the NUMA for
>> heterogeneous memory may not be a good idea. Will look into this further.
> I agree with comment that first a direction should be defined how to handle heterogeneous memory system.
> 
>> https://linuxplumbersconf.org/2017/ocw//system/presentations/4656/original/
>> Hierarchical_NUMA_Design_Plumbers_2017.pdf
> I miss in the presentation a user perspective of the new approach, e.g.
> - How does application developer see/understand the heterogeneous memory system?

>From user perspective

- Each memory node (with or without CPU) is a NUMA node with attributes
- User should detect these NUMA nodes from sysfs (not part of proposal)
- User allocates/operates/destroys VMA with new sys calls (_mattr based)

> - How does app developer use the heterogeneous memory system?

- Through existing and new system calls

> - What are modification in API/sys interfaces?

- The presentation has possible addition of new system calls with 'u64
  _mattr' representation for memory attributes which can be used while
  requesting different kinds of memory from the kernel

> 
> In other hand, if we assume that separate memory NUMA node has different memory capabilities/attributes from stand point of particular CPU, it is easy to explain for user how to describe/handle heterogeneous memory. 
> 
> Of course, current numa design is not sufficient in kernel in following areas today:
> - Exposing memory attributes that describe heterogeneous memory system
> - Interfaces to use the heterogeneous memory system, e.g. more sophisticated policies
> - Internal mechanism in memory management, e.g. automigration, maybe something else.

Right, we would need

- Representation of NUMA with attributes
- APIs/syscalls for accessing the intended memory from user space
- Memory management policies and algorithms navigating trough all these
  new attributes in various situations

IMHO, we should not consider sysfs interfaces for heterogeneous memory
(which will be an ABI going forward and hence cannot be changed easily)
before we get the NUMA redesign right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
