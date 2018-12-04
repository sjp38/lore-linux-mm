Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0004B6B6F70
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 10:43:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so8414195eda.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 07:43:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l11-v6si4512797ejz.109.2018.12.04.07.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 07:43:57 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB4FhufR029109
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 10:43:56 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p5ur3k03v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 10:43:44 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Dec 2018 15:43:43 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH 1/7] node: Link memory nodes to their compute nodes
In-Reply-To: <20181116183254.GD14630@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com> <20181115135710.GD19286@bombadil.infradead.org> <20181115145920.GG11416@localhost.localdomain> <20181115203654.GA28246@bombadil.infradead.org> <20181116183254.GD14630@localhost.localdomain>
Date: Tue, 04 Dec 2018 21:13:33 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87sgzd5mca.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

Keith Busch <keith.busch@intel.com> writes:

> On Thu, Nov 15, 2018 at 12:36:54PM -0800, Matthew Wilcox wrote:
>> On Thu, Nov 15, 2018 at 07:59:20AM -0700, Keith Busch wrote:
>> > On Thu, Nov 15, 2018 at 05:57:10AM -0800, Matthew Wilcox wrote:
>> > > On Wed, Nov 14, 2018 at 03:49:14PM -0700, Keith Busch wrote:
>> > > > Memory-only nodes will often have affinity to a compute node, and
>> > > > platforms have ways to express that locality relationship.
>> > > > 
>> > > > A node containing CPUs or other DMA devices that can initiate memory
>> > > > access are referred to as "memory iniators". A "memory target" is a
>> > > > node that provides at least one phyiscal address range accessible to a
>> > > > memory initiator.
>> > > 
>> > > I think I may be confused here.  If there is _no_ link from node X to
>> > > node Y, does that mean that node X's CPUs cannot access the memory on
>> > > node Y?  In my mind, all nodes can access all memory in the system,
>> > > just not with uniform bandwidth/latency.
>> > 
>> > The link is just about which nodes are "local". It's like how nodes have
>> > a cpulist. Other CPUs not in the node's list can acces that node's memory,
>> > but the ones in the mask are local, and provide useful optimization hints.
>> 
>> So ... let's imagine a hypothetical system (I've never seen one built like
>> this, but it doesn't seem too implausible).  Connect four CPU sockets in
>> a square, each of which has some regular DIMMs attached to it.  CPU A is
>> 0 hops to Memory A, one hop to Memory B and Memory C, and two hops from
>> Memory D (each CPU only has two "QPI" links).  Then maybe there's some
>> special memory extender device attached on the PCIe bus.  Now there's
>> Memory B1 and B2 that's attached to CPU B and it's local to CPU B, but
>> not as local as Memory B is ... and we'd probably _prefer_ to allocate
>> memory for CPU A from Memory B1 than from Memory D.  But ... *mumble*,
>> this seems hard.
>
> Indeed, that particular example is out of scope for this series. The
> first objective is to aid a process running in node B's CPUs to allocate
> memory in B1. Anything that crosses QPI are their own.

But if you can extrapolate how such a system can possibly be expressed
using what is propsed here, it would help in reviewing this. Also how
do we intent to express the locality of memory w.r.t to other computing
units like GPU/FPGA?

I understand that this is looked at as ACPI HMAT in sysfs format.
But as mentioned by others in this thread, if we don't do this platform
and device independent way, we can have application portability issues
going forward?

-aneesh
