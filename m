Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A04E06B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 22:10:05 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id l18so2447837qkk.23
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:10:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x64si1215264qke.189.2017.12.21.19.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 19:10:04 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBM39FLi006326
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 22:10:04 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2f0pvu73d5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 22:10:03 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 22 Dec 2017 03:10:01 -0000
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 22 Dec 2017 08:39:41 +0530
MIME-Version: 1.0
In-Reply-To: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 12/14/2017 07:40 AM, Ross Zwisler wrote:
> ==== Quick Summary ====
> 
> Platforms exist today which have multiple types of memory attached to a
> single CPU.  These disparate memory ranges have some characteristics in
> common, such as CPU cache coherence, but they can have wide ranges of
> performance both in terms of latency and bandwidth.

Right.

> 
> For example, consider a system that contains persistent memory, standard
> DDR memory and High Bandwidth Memory (HBM), all attached to the same CPU.
> There could potentially be an order of magnitude or more difference in
> performance between the slowest and fastest memory attached to that CPU.

Right.

> 
> With the current Linux code NUMA nodes are CPU-centric, so all the memory
> attached to a given CPU will be lumped into the same NUMA node.  This makes
> it very difficult for userspace applications to understand the performance
> of different memory ranges on a given CPU.

Right but that might require fundamental changes to the NUMA representation.
Plugging those memory as separate NUMA nodes, identify them through sysfs
and try allocating from it through mbind() seems like a short term solution.

Though if we decide to go in this direction, sysfs interface or something
similar is required to enumerate memory properties.

> 
> We solve this issue by providing userspace with performance information on
> individual memory ranges.  This performance information is exposed via
> sysfs:
> 
>   # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
>   mem_tgt2/firmware_id:1
>   mem_tgt2/is_cached:0
>   mem_tgt2/local_init/read_bw_MBps:40960
>   mem_tgt2/local_init/read_lat_nsec:50
>   mem_tgt2/local_init/write_bw_MBps:40960
>   mem_tgt2/local_init/write_lat_nsec:50

I might have missed discussions from earlier versions, why we have this
kind of a "source --> target" model ? We will enlist properties for all
possible "source --> target" on the system ? Right now it shows only
bandwidth and latency properties, can it accommodate other properties
as well in future ?

> 
> This allows applications to easily find the memory that they want to use.
> We expect that the existing NUMA APIs will be enhanced to use this new
> information so that applications can continue to use them to select their
> desired memory.

I had presented a proposal for NUMA redesign in the Plumbers Conference this
year where various memory devices with different kind of memory attributes
can be represented in the kernel and be used explicitly from the user space.
Here is the link to the proposal if you feel interested. The proposal is
very intrusive and also I dont have a RFC for it yet for discussion here.

https://linuxplumbersconf.org/2017/ocw//system/presentations/4656/original/Hierarchical_NUMA_Design_Plumbers_2017.pdf

Problem is, designing the sysfs interface for memory attribute detection
from user space without first thinking about redesigning the NUMA for
heterogeneous memory may not be a good idea. Will look into this further.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
