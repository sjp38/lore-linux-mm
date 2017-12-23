Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5016B027E
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 01:57:24 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d9so7542804qkg.13
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 22:57:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u57si15551491qte.85.2017.12.22.22.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 22:57:23 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBN6reJE009827
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 01:57:21 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f18srpbw0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 01:57:21 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 23 Dec 2017 06:57:18 -0000
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <2d6420f7-0a95-adfe-7390-a2aea4385ab2@linux.vnet.ibm.com>
 <20171222221330.GB25711@linux.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sat, 23 Dec 2017 12:26:37 +0530
MIME-Version: 1.0
In-Reply-To: <20171222221330.GB25711@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1bda138d-7933-35a8-fd8c-49cc6acc0942@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 12/23/2017 03:43 AM, Ross Zwisler wrote:
> On Fri, Dec 22, 2017 at 08:39:41AM +0530, Anshuman Khandual wrote:
>> On 12/14/2017 07:40 AM, Ross Zwisler wrote:
>>> ==== Quick Summary ====
>>>
>>> Platforms exist today which have multiple types of memory attached to a
>>> single CPU.  These disparate memory ranges have some characteristics in
>>> common, such as CPU cache coherence, but they can have wide ranges of
>>> performance both in terms of latency and bandwidth.
>>
>> Right.
>>
>>>
>>> For example, consider a system that contains persistent memory, standard
>>> DDR memory and High Bandwidth Memory (HBM), all attached to the same CPU.
>>> There could potentially be an order of magnitude or more difference in
>>> performance between the slowest and fastest memory attached to that CPU.
>>
>> Right.
>>
>>>
>>> With the current Linux code NUMA nodes are CPU-centric, so all the memory
>>> attached to a given CPU will be lumped into the same NUMA node.  This makes
>>> it very difficult for userspace applications to understand the performance
>>> of different memory ranges on a given CPU.
>>
>> Right but that might require fundamental changes to the NUMA representation.
>> Plugging those memory as separate NUMA nodes, identify them through sysfs
>> and try allocating from it through mbind() seems like a short term solution.
>>
>> Though if we decide to go in this direction, sysfs interface or something
>> similar is required to enumerate memory properties.
> 
> Yep, and this patch series is trying to be the sysfs interface that is
> required to the memory properties.  :)  It's a certainty that we will have
> memory-only NUMA nodes, at least on platforms that support ACPI.  Supporting
> memory-only proximity domains (which Linux turns in to memory-only NUMA nodes)
> is explicitly supported with the introduction of the HMAT in ACPI 6.2.

Yeah, even on POWER platforms can have memory only NUMA nodes.

> 
> It also turns out that the existing memory management code already deals with
> them just fine - you see this with my hmat_examples setup:
> 
> https://github.com/rzwisler/hmat_examples
> 
> Both configurations created by this repo create memory-only NUMA nodes, even
> with upstream kernels.  My patches don't change that, they just provide a
> sysfs representation of the HMAT so users can discover the memory that exists
> in the system.

Once its a NUMA node everything will work as is from MM interface
point of view. But the point is how we export these properties to
user space. My only concern is lets not do it in a way which will
be locked without first going through NUMA redesign for these new
attribute based memory, thats all.

> 
>>> We solve this issue by providing userspace with performance information on
>>> individual memory ranges.  This performance information is exposed via
>>> sysfs:
>>>
>>>   # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
>>>   mem_tgt2/firmware_id:1
>>>   mem_tgt2/is_cached:0
>>>   mem_tgt2/local_init/read_bw_MBps:40960
>>>   mem_tgt2/local_init/read_lat_nsec:50
>>>   mem_tgt2/local_init/write_bw_MBps:40960
>>>   mem_tgt2/local_init/write_lat_nsec:50
>>
>> I might have missed discussions from earlier versions, why we have this
>> kind of a "source --> target" model ? We will enlist properties for all
>> possible "source --> target" on the system ? Right now it shows only
>> bandwidth and latency properties, can it accommodate other properties
>> as well in future ?
> 
> The initiator/target model is useful in preventing us from needing a
> MAX_NUMA_NODES x MAX_NUMA_NODES sized table for each performance attribute.  I
> talked about it a little more here:

That makes it even more complex. Not only we have a memory attribute
like bandwidth specific to the range, we are also exporting it's
relative values as seen from different CPU nodes. Its again kind of
a NUMA distance table being exported in the generic sysfs path like
/sys/devices/. The problem is possible future memory attributes like
'reliability', 'density', 'power consumption' might not have a need
for a "source --> destination" kind of model as they dont change
based on which CPU node is accessing it.

> 
> https://lists.01.org/pipermail/linux-nvdimm/2017-December/013654.html
> 
>>> This allows applications to easily find the memory that they want to use.
>>> We expect that the existing NUMA APIs will be enhanced to use this new
>>> information so that applications can continue to use them to select their
>>> desired memory.
>>
>> I had presented a proposal for NUMA redesign in the Plumbers Conference this
>> year where various memory devices with different kind of memory attributes
>> can be represented in the kernel and be used explicitly from the user space.
>> Here is the link to the proposal if you feel interested. The proposal is
>> very intrusive and also I dont have a RFC for it yet for discussion here.
>>
>> https://linuxplumbersconf.org/2017/ocw//system/presentations/4656/original/Hierarchical_NUMA_Design_Plumbers_2017.pdf
> 
> I'll take a look, but my first reaction is that I agree with Dave that it
> seems hard to re-teach systems a new NUMA scheme.  This patch series doesn't
> attempt to do that - it is very unintrusive and only informs users about the
> memory-only NUMA nodes that will already exist in their ACPI-based systems.

But while not trying to address how NUMA should treat these
heterogeneous memory attribute nodes, the patch series might
be trying to lock down sysfs interfaces which might not be as
appropriate or extensible when redesigning  NUMA in future.
Sure, pass on the information to user space but not through
generic interfaces like /sys/device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
