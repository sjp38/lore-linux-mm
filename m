Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D277B280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 12:18:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l74so5577953oih.5
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 09:18:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u206sor187331oie.215.2017.09.05.09.18.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Sep 2017 09:18:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170905135017.GA19397@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com> <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com> <20170905023826.GA4836@redhat.com>
 <c7997016-7932-649d-cf27-17caa33cd856@huawei.com> <20170905135017.GA19397@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 5 Sep 2017 09:18:55 -0700
Message-ID: <CAPcyv4iAspsatNmv=z-jAsTycwPrkh8XsWENyBOL9-1WuhGQWw@mail.gmail.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 5, 2017 at 6:50 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Sep 05, 2017 at 11:50:57AM +0800, Bob Liu wrote:
>> On 2017/9/5 10:38, Jerome Glisse wrote:
>> > On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
>> >> On 2017/9/4 23:51, Jerome Glisse wrote:
>> >>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
>> >>>> On 2017/8/17 8:05, J=C3=A9r=C3=B4me Glisse wrote:
>> >>>>> Unlike unaddressable memory, coherent device memory has a real
>> >>>>> resource associated with it on the system (as CPU can address
>> >>>>> it). Add a new helper to hotplug such memory within the HMM
>> >>>>> framework.
>> >>>>>
>> >>>>
>> >>>> Got an new question, coherent device( e.g CCIX) memory are likely r=
eported to OS
>> >>>> through ACPI and recognized as NUMA memory node.
>> >>>> Then how can their memory be captured and managed by HMM framework?
>> >>>>
>> >>>
>> >>> Only platform that has such memory today is powerpc and it is not re=
ported
>> >>> as regular memory by the firmware hence why they need this helper.
>> >>>
>> >>> I don't think anyone has defined anything yet for x86 and acpi. As t=
his is
>> >>
>> >> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
>> >> Table (HMAT) table defined in ACPI 6.2.
>> >> The HMAT can cover CPU-addressable memory types(though not non-cache
>> >> coherent on-device memory).
>> >>
>> >> Ross from Intel already done some work on this, see:
>> >> https://lwn.net/Articles/724562/
>> >>
>> >> arm64 supports APCI also, there is likely more this kind of device wh=
en CCIX
>> >> is out (should be very soon if on schedule).
>> >
>> > HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy" mem=
ory ie
>> > when you have several kind of memory each with different characteristi=
cs:
>> >   - HBM very fast (latency) and high bandwidth, non persistent, somewh=
at
>> >     small (ie few giga bytes)
>> >   - Persistent memory, slower (both latency and bandwidth) big (tera b=
ytes)
>> >   - DDR (good old memory) well characteristics are between HBM and per=
sistent
>> >
>>
>> Okay, then how the kernel handle the situation of "kind of memory each w=
ith different characteristics"?
>> Does someone have any suggestion?  I thought HMM can do this.
>> Numa policy/node distance is good but perhaps require a few extending, e=
.g a HBM node can't be
>> swap, can't accept DDR fallback allocation.
>
> I don't think there is any consensus for this. I put forward the idea tha=
t NUMA
> needed to be extended as with deep hierarchy it is not only the distance =
between
> two nodes but also others factors like persistency, bandwidth, latency ..=
.
>
>
>> > So AFAICT this has nothing to do with what HMM is for, ie device memor=
y. Note
>> > that device memory can have a hierarchy of memory themself (HBM, GDDR =
and in
>> > maybe even persistent memory).
>> >
>>
>> This looks like a subset of HMAT when CPU can address device memory dire=
ctly in cache-coherent way.
>
> It is not, it is much more complex than that. Linux kernel has no idea on=
 what is
> going on a device and thus do not have any usefull informations to make p=
roper
> decission regarding device memory. Here device is real device ie somethin=
g with
> processing capability, not something like HBM or persistent memory even i=
f the
> latter is associated with a struct device inside linux kernel.
>
>>
>>
>> >>> memory on PCIE like interface then i don't expect it to be reported =
as NUMA
>> >>> memory node but as io range like any regular PCIE resources. Device =
driver
>> >>> through capabilities flags would then figure out if the link between=
 the
>> >>> device and CPU is CCIX capable if so it can use this helper to hotpl=
ug it
>> >>> as device memory.
>> >>>
>> >>
>> >> From my point of view,  Cache coherent device memory will popular soo=
n and
>> >> reported through ACPI/UEFI. Extending NUMA policy still sounds more r=
easonable
>> >> to me.
>> >
>> > Cache coherent device will be reported through standard mecanisms defi=
ned by
>> > the bus standard they are using. To my knowledge all the standard are =
either
>> > on top of PCIE or are similar to PCIE.
>> >
>> > It is true that on many platform PCIE resource is manage/initialize by=
 the
>> > bios (UEFI) but it is platform specific. In some case we reprogram wha=
t the
>> > bios pick.
>> >
>> > So like i was saying i don't expect the BIOS/UEFI to report device mem=
ory as
>>
>> But it's happening.
>> In my understanding, that's why HMAT was introduced.
>> For reporting device memory as regular memory(with different characteris=
tics).
>
> That is not my understanding but only Intel can confirm. HMAT was introdu=
ced
> for things like HBM or persistent memory. Which i do not consider as devi=
ce
> memory. Sure persistent memory is assign a device struct because it is ea=
sier
> for integration with the block system i assume. But it does not make it a
> device in my view. For me a device is a piece of hardware that has some
> processing capabilities (network adapter, sound card, GPU, ...)
>
> But we can argue about semantic and what a device is. For all intent and =
purposes
> device in HMM context is some piece of hardware with processing capabilit=
ies and
> local device memory.

I would say that device memory at its base-level is a memory range
whose availability is dependent on a device-driver. HMM layers some
additional functionality on top, but ZONE_DEVICE should only be seen
as the device-driver controlled lifetime and not conflated with the
incremental HMM functionality.

HMAT simply allows you to associate a memory range with a numa-node /
proximity-domain number that represents a set of performance / feature
characteristics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
