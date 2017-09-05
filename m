Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00DFD2803C2
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 15:20:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h15so6028141qta.4
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 12:20:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t27si1148774qkt.31.2017.09.05.12.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 12:20:54 -0700 (PDT)
Date: Tue, 5 Sep 2017 15:20:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Message-ID: <20170905192050.GC19397@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
 <20170905023826.GA4836@redhat.com>
 <c7997016-7932-649d-cf27-17caa33cd856@huawei.com>
 <20170905135017.GA19397@redhat.com>
 <20170905190013.GC24073@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170905190013.GC24073@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Bob Liu <liubo95@huawei.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Sep 05, 2017 at 01:00:13PM -0600, Ross Zwisler wrote:
> On Tue, Sep 05, 2017 at 09:50:17AM -0400, Jerome Glisse wrote:
> > On Tue, Sep 05, 2017 at 11:50:57AM +0800, Bob Liu wrote:
> > > On 2017/9/5 10:38, Jerome Glisse wrote:
> > > > On Tue, Sep 05, 2017 at 09:13:24AM +0800, Bob Liu wrote:
> > > >> On 2017/9/4 23:51, Jerome Glisse wrote:
> > > >>> On Mon, Sep 04, 2017 at 11:09:14AM +0800, Bob Liu wrote:
> > > >>>> On 2017/8/17 8:05, Jerome Glisse wrote:
> > > >>>>> Unlike unaddressable memory, coherent device memory has a real
> > > >>>>> resource associated with it on the system (as CPU can address
> > > >>>>> it). Add a new helper to hotplug such memory within the HMM
> > > >>>>> framework.
> > > >>>>>
> > > >>>>
> > > >>>> Got an new question, coherent device( e.g CCIX) memory are likely reported to OS 
> > > >>>> through ACPI and recognized as NUMA memory node.
> > > >>>> Then how can their memory be captured and managed by HMM framework?
> > > >>>>
> > > >>>
> > > >>> Only platform that has such memory today is powerpc and it is not reported
> > > >>> as regular memory by the firmware hence why they need this helper.
> > > >>>
> > > >>> I don't think anyone has defined anything yet for x86 and acpi. As this is
> > > >>
> > > >> Not yet, but now the ACPI spec has Heterogeneous Memory Attribute
> > > >> Table (HMAT) table defined in ACPI 6.2.
> > > >> The HMAT can cover CPU-addressable memory types(though not non-cache
> > > >> coherent on-device memory).
> > > >>
> > > >> Ross from Intel already done some work on this, see:
> > > >> https://lwn.net/Articles/724562/
> > > >>
> > > >> arm64 supports APCI also, there is likely more this kind of device when CCIX
> > > >> is out (should be very soon if on schedule).
> > > > 
> > > > HMAT is not for the same thing, AFAIK HMAT is for deep "hierarchy" memory ie
> > > > when you have several kind of memory each with different characteristics:
> > > >   - HBM very fast (latency) and high bandwidth, non persistent, somewhat
> > > >     small (ie few giga bytes)
> > > >   - Persistent memory, slower (both latency and bandwidth) big (tera bytes)
> > > >   - DDR (good old memory) well characteristics are between HBM and persistent
> > > > 
> > > 
> > > Okay, then how the kernel handle the situation of "kind of memory each with different characteristics"?
> > > Does someone have any suggestion?  I thought HMM can do this.
> > > Numa policy/node distance is good but perhaps require a few extending, e.g a HBM node can't be
> > > swap, can't accept DDR fallback allocation.
> > 
> > I don't think there is any consensus for this. I put forward the idea that NUMA
> > needed to be extended as with deep hierarchy it is not only the distance between
> > two nodes but also others factors like persistency, bandwidth, latency ...
> > 
> > 
> > > > So AFAICT this has nothing to do with what HMM is for, ie device memory. Note
> > > > that device memory can have a hierarchy of memory themself (HBM, GDDR and in
> > > > maybe even persistent memory).
> > > > 
> > > 
> > > This looks like a subset of HMAT when CPU can address device memory directly in cache-coherent way.
> > 
> > It is not, it is much more complex than that. Linux kernel has no idea on what is
> > going on a device and thus do not have any usefull informations to make proper
> > decission regarding device memory. Here device is real device ie something with
> > processing capability, not something like HBM or persistent memory even if the
> > latter is associated with a struct device inside linux kernel.
> > 
> > > 
> > > 
> > > >>> memory on PCIE like interface then i don't expect it to be reported as NUMA
> > > >>> memory node but as io range like any regular PCIE resources. Device driver
> > > >>> through capabilities flags would then figure out if the link between the
> > > >>> device and CPU is CCIX capable if so it can use this helper to hotplug it
> > > >>> as device memory.
> > > >>>
> > > >>
> > > >> From my point of view,  Cache coherent device memory will popular soon and
> > > >> reported through ACPI/UEFI. Extending NUMA policy still sounds more reasonable
> > > >> to me.
> > > > 
> > > > Cache coherent device will be reported through standard mecanisms defined by
> > > > the bus standard they are using. To my knowledge all the standard are either
> > > > on top of PCIE or are similar to PCIE.
> > > > 
> > > > It is true that on many platform PCIE resource is manage/initialize by the
> > > > bios (UEFI) but it is platform specific. In some case we reprogram what the
> > > > bios pick.
> > > > 
> > > > So like i was saying i don't expect the BIOS/UEFI to report device memory as
> > > 
> > > But it's happening.
> > > In my understanding, that's why HMAT was introduced.
> > > For reporting device memory as regular memory(with different characteristics).
> > 
> > That is not my understanding but only Intel can confirm. HMAT was introduced
> > for things like HBM or persistent memory. Which i do not consider as device
> > memory. Sure persistent memory is assign a device struct because it is easier
> > for integration with the block system i assume. But it does not make it a
> > device in my view. For me a device is a piece of hardware that has some
> > processing capabilities (network adapter, sound card, GPU, ...)
> > 
> > But we can argue about semantic and what a device is. For all intent and purposes
> > device in HMM context is some piece of hardware with processing capabilities and
> > local device memory.
> 
> I personally don't see a reason why we couldn't use the HMAT to describe
> device memory.  The idea of having memory-only NUMA nodes is already a realty
> post-HMAT, and the HMAT is just there to give you information on the memory
> ranges in the system.  I realize that you may need a different device driver
> to set the memory up, but once you do set it up and it's cache coherent,
> doesn't it just look like any other memory range where you can say things
> like:
> 
> My memory starts at X
> My memory has size Y
> My memory's performance from CPU Z is XXX (latency, bandwidth, read & write)
> etc?

Does HMAT support device hotplug ? I am unfamiliar with the whole inner working
of ACPI versus PCIE. Anyway i don't see any issue with device memory also showing
through HMAT but like i said device driver for the device will want to be in total
control of that memory.

Like i said issue here is that core kernel is unaware of the device activity ie
on what part of memory the device is actively working. So core mm can not make
inform decision on what should be migrated to device memory. Also we do not want
regular memory allocation to end in device memory unless explicitly ask for.
Few reasons for that. First this memory might not only be use for compute task
but also for graphic and in that case they are hard constraint on physically
contiguous memory allocation that require the GPU to move thing around to make
room for graphic object (can't allow GUP).

Second reasons, the device memory is inherently unreliable. If there is a bug
in the device driver or the user manage to trigger a faulty condition on GPU
the device might need a hard reset (ie cut PCIE power to device) which leads
to loss of memory content. While GPU are becoming more and more resilient they
are still prone to lockup.

Finaly for GPU there is a common pattern of memory over-commit. You pretend to
each application as if they were the only one and allow each of them to allocate
all of the device memory or more than could with strict sharing. As GPU have
long timeslice between switching to different context/application they can
easily move out and in large chunk of the process memory at context/application
switching. This is have proven to be a key aspect to allow maximum performances
accross several concurrent application/context.

To implement this easiest solution is for the device to lie about how much memory
it has and use the system memory as an overflow.


I am not saying that NUMA is not the way forward, i am saying that as it is today
it is not suited for this. It is lacking metric, it is lacking logic, it is lacking
features. We could add all this but it is a lot of work and i don't feel that we
have enough real world experience to do so now. I would rather have each devices
grow proper infrastructure in their driver through device specific API.

Then identify common pattern and from there try to build a sane API (if any such
thing exist :)) rather than trying today to build the whole house from the ground
up with just a foggy idea of how it should looks in the end.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
