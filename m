Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90EAF6B0286
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:00:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id r141so287947qke.7
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:00:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z138si134930qka.226.2017.09.07.10.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 10:00:29 -0700 (PDT)
Date: Thu, 7 Sep 2017 13:00:25 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <623597181.10447378.1504803625592.JavaMail.zimbra@redhat.com>
In-Reply-To: <4f4a2196-228d-5d54-5386-72c3ffb1481b@huawei.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170904155123.GA3161@redhat.com> <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com> <20170905023826.GA4836@redhat.com> <20170905185414.GB24073@linux.intel.com> <0bc5047d-d27c-65b6-acab-921263e715c8@huawei.com> <20170906021216.GA23436@redhat.com> <4f4a2196-228d-5d54-5386-72c3ffb1481b@huawei.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

> On 2017/9/6 10:12, Jerome Glisse wrote:
> > On Wed, Sep 06, 2017 at 09:25:36AM +0800, Bob Liu wrote:
> >> On 2017/9/6 2:54, Ross Zwisler wrote:
> >>> On Mon, Sep 04, 2017 at 10:38:27PM -0400, Jerome Glisse wrote:
> >>>> On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
> >>>>> On 2017/9/4 23:51, Jerome Glisse wrote:
> >>>>>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
> >>>>>>> On 2017/8/17 8:05, J=C3=A9r=C3=B4me Glisse wrote:
> >>>>>>>> Unlike unaddressable memory, coherent device memory has a real
> >>>>>>>> resource associated with it on the system (as CPU can address
> >>>>>>>> it). Add a new helper to hotplug such memory within the HMM
> >>>>>>>> framework.
> >>>>>>>>
> >>>>>>>
> >>>>>>> Got an new question, coherent device( e.g CCIX) memory are likely
> >>>>>>> reported to OS
> >>>>>>> through ACPI and recognized as NUMA memory node.
> >>>>>>> Then how can their memory be captured and managed by HMM framewor=
k?
> >>>>>>>
> >>>>>>
> >>>>>> Only platform that has such memory today is powerpc and it is not
> >>>>>> reported
> >>>>>> as regular memory by the firmware hence why they need this helper.
> >>>>>>
> >>>>>> I don't think anyone has defined anything yet for x86 and acpi. As
> >>>>>> this is
> >>>>>
> >>>>> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
> >>>>> Table (HMAT) table defined in ACPI 6.2.
> >>>>> The HMAT can cover CPU-addressable memory types(though not non-cach=
e
> >>>>> coherent on-device memory).
> >>>>>
> >>>>> Ross from Intel already done some work on this, see:
> >>>>> https://lwn.net/Articles/724562/
> >>>>>
> >>>>> arm64 supports APCI also, there is likely more this kind of device =
when
> >>>>> CCIX
> >>>>> is out (should be very soon if on schedule).
> >>>>
> >>>> HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy"
> >>>> memory ie
> >>>> when you have several kind of memory each with different
> >>>> characteristics:
> >>>>   - HBM very fast (latency) and high bandwidth, non persistent, some=
what
> >>>>     small (ie few giga bytes)
> >>>>   - Persistent memory, slower (both latency and bandwidth) big (tera
> >>>>   bytes)
> >>>>   - DDR (good old memory) well characteristics are between HBM and
> >>>>   persistent
> >>>>
> >>>> So AFAICT this has nothing to do with what HMM is for, ie device mem=
ory.
> >>>> Note
> >>>> that device memory can have a hierarchy of memory themself (HBM, GDD=
R
> >>>> and in
> >>>> maybe even persistent memory).
> >>>>
> >>>>>> memory on PCIE like interface then i don't expect it to be reporte=
d as
> >>>>>> NUMA
> >>>>>> memory node but as io range like any regular PCIE resources. Devic=
e
> >>>>>> driver
> >>>>>> through capabilities flags would then figure out if the link betwe=
en
> >>>>>> the
> >>>>>> device and CPU is CCIX capable if so it can use this helper to hot=
plug
> >>>>>> it
> >>>>>> as device memory.
> >>>>>>
> >>>>>
> >>>>> From my point of view,  Cache coherent device memory will popular s=
oon
> >>>>> and
> >>>>> reported through ACPI/UEFI. Extending NUMA policy still sounds more
> >>>>> reasonable
> >>>>> to me.
> >>>>
> >>>> Cache coherent device will be reported through standard mecanisms
> >>>> defined by
> >>>> the bus standard they are using. To my knowledge all the standard ar=
e
> >>>> either
> >>>> on top of PCIE or are similar to PCIE.
> >>>>
> >>>> It is true that on many platform PCIE resource is manage/initialize =
by
> >>>> the
> >>>> bios (UEFI) but it is platform specific. In some case we reprogram w=
hat
> >>>> the
> >>>> bios pick.
> >>>>
> >>>> So like i was saying i don't expect the BIOS/UEFI to report device
> >>>> memory as
> >>>> regular memory. It will be reported as a regular PCIE resources and =
then
> >>>> the
> >>>> device driver will be able to determine through some flags if the li=
nk
> >>>> between
> >>>> the CPU(s) and the device is cache coherent or not. At that point th=
e
> >>>> device
> >>>> driver can use register it with HMM helper.
> >>>>
> >>>>
> >>>> The whole NUMA discussion happen several time in the past i suggest
> >>>> looking
> >>>> on mm list archive for them. But it was rule out for several reasons=
.
> >>>> Top of
> >>>> my head:
> >>>>   - people hate CPU less node and device memory is inherently CPU le=
ss
> >>>
> >>> With the introduction of the HMAT in ACPI 6.2 one of the things that =
was
> >>> added
> >>> was the ability to have an ACPI proximity domain that isn't associate=
d
> >>> with a
> >>> CPU.  This can be seen in the changes in the text of the "Proximity
> >>> Domain"
> >>> field in table 5-73 which describes the "Memory Affinity Structure". =
 One
> >>> of
> >>> the major features of the HMAT was the separation of "Initiator"
> >>> proximity
> >>> domains (CPUs, devices that initiate memory transfers), and "target"
> >>> proximity
> >>> domains (memory regions, be they attached to a CPU or some other devi=
ce).
> >>>
> >>> ACPI proximity domains map directly to Linux NUMA nodes, so I think w=
e're
> >>> already in a place where we have to support CPU-less NUMA nodes.
> >>>
> >>>>   - device driver want total control over memory and thus to be isol=
ated
> >>>>   from
> >>>>     mm mecanism and doing all those special cases was not welcome
> >>>
> >>> I agree that the kernel doesn't have enough information to be able to
> >>> accurately handle all the use cases for the various types of
> >>> heterogeneous
> >>> memory.   The goal of my HMAT enabling is to allow that memory to be
> >>> reserved
> >>> from kernel use via the "Reservation Hint" in the HMAT's Memory Subsy=
stem
> >>> Address Range Structure, then provide userspace with enough informati=
on
> >>> to be
> >>> able to distinguish between the various types of memory in the system=
 so
> >>> it
> >>> can allocate & utilize it appropriately.
> >>>
> >>
> >> Does this mean require an user space memory management library to deal
> >> with all
> >> alloc/free/defragment.. But how to do with virtual <-> physical addres=
s
> >> mapping
> >> from userspace?
> >=20
> > For HMM each process give hint (somewhat similar to mbind) for range of
> > virtual
> > address to the device kernel driver (through some API like OpenCL or CU=
DA
> > for GPU
> > for instance). All this being device driver specific ioctl.
> >=20
> > The kernel device driver have an overall view of all the process that u=
se
> > the device
> > and each of the memory advise they gave. From that informations the ker=
nel
> > device
> > driver decide what part of each process address space to migrate to dev=
ice
> > memory.
>=20
> Oh, I mean CDM-HMM.  I'm fine with HMM.
>=20
> > This obviously dynamic and likely to change over the process lifetime.
> >=20
> >=20
> > My understanding is that HMAT want similar API to allow process to give
> > direction on
> > where each range of virtual address should be allocated. It is expected
> > that most
>=20
> Right, but not clear who should manage the physical memory allocation and
> setup the
> pagetable mapping. An new driver or the kernel?
>=20
> > software can easily infer what part of its address will need more
> > bandwidth, smaller
> > latency versus what part is sparsely accessed ...
> >=20
> > For HMAT i think first target is HBM and persistent memory and device
> > memory might
> > be added latter if that make sense.
> >=20
>=20
> Okay, so there are two potential ways for CPU-addressable cache-coherent
> device memory
> (or cpu-less numa memory or "target domain" memory in ACPI spec )?
> 1. CDM-HMM
> 2. HMAT
>=20
> --
> Regards,
> Bob Liu
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
